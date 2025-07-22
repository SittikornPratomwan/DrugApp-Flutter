import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class DispensaryPage extends StatefulWidget {
  const DispensaryPage({super.key});

  @override
  State<DispensaryPage> createState() => _DispensaryPageState();
}

class _DispensaryPageState extends State<DispensaryPage> {
  final TextEditingController staffController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isSaving = false;

  List<dynamic> drugList = [];
  List<dynamic> itemList = [];
  String? selectedDrugId;
  String? selectedDrugName;
  int? selectedDrugStock;

  @override
  void initState() {
    super.initState();
    fetchDrugs();
  }

  Future<void> fetchDrugs() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.drugsProductEndpoint),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          drugList = data;
        });
      }
      // ดึง item stock
      final itemRes = await http.get(
        Uri.parse(ApiConfig.drugsProductItemEndpoint),
        headers: {'Content-Type': 'application/json'},
      );
      if (itemRes.statusCode == 200) {
        final List<dynamic> itemData = jsonDecode(itemRes.body);
        setState(() {
          itemList = itemData;
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  Future<void> _saveDispense() async {
    final staff = staffController.text.trim();
    final drug = selectedDrugId;
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    if (staff.isEmpty || drug == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'), backgroundColor: Colors.red),
      );
      return;
    }
    // หา stock ปัจจุบันจาก item
    final item = itemList.firstWhere((i) => i['productId'].toString() == drug, orElse: () => null);
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูล item ของยา'), backgroundColor: Colors.red),
      );
      return;
    }
    final currentStock = (item['stock'] is int) ? item['stock'] : int.tryParse(item['stock'].toString()) ?? 0;
    if (amount > currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('จำนวนในคลังไม่พอ (เหลือ $currentStock)'), backgroundColor: Colors.red),
      );
      return;
    }
    final newStock = currentStock - amount;
    setState(() { isSaving = true; });
    try {
      // 1. บันทึกการจ่ายยา
      final response = await http.post(
        Uri.parse(ApiConfig.dispenseDrugEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: '{"staff": "$staff", "drug": "$drug", "amount": "$amount"}',
      );
      // 2. อัปเดต stock ใน item
      if (response.statusCode == 200 || response.statusCode == 201) {
        final updateRes = await http.put(
          Uri.parse(ApiConfig.drugsProductItemEndpoint + '/${item['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: '{"stock": $newStock}',
        );
        if (updateRes.statusCode == 200 || updateRes.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('บันทึกการจ่ายยาและอัปเดตจำนวน item สำเร็จ'), backgroundColor: Colors.green),
          );
          staffController.clear();
          amountController.clear();
          setState(() { selectedDrugName = null; });
          fetchDrugs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('บันทึกการจ่ายยาสำเร็จ แต่ปรับ stock item ไม่สำเร็จ: ${updateRes.statusCode}'), backgroundColor: Colors.orange),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกไม่สำเร็จ: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จ่ายยา')), 
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ชื่อพนักงาน', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: staffController,
              decoration: const InputDecoration(hintText: 'กรอกชื่อพนักงาน', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('ชื่อยา', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDrugId,
              items: drugList.map<DropdownMenuItem<String>>((drug) {
                return DropdownMenuItem<String>(
                  value: drug['id'].toString(),
                  child: Text(drug['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDrugId = value;
                  final drug = drugList.firstWhere((d) => d['id'].toString() == value, orElse: () => null);
                  selectedDrugName = drug != null ? drug['name'] : null;
                  // หา stock จาก itemList โดยใช้ productId
                  final item = itemList.firstWhere((i) => i['product_id'].toString() == value, orElse: () => null);
                  if (item != null && item['stock'] != null)
                    selectedDrugStock = int.tryParse(item['stock'].toString());
                  else
                    selectedDrugStock = null;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'เลือกยา'),
            ),
            if (selectedDrugStock != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('จำนวนคงเหลือ: $selectedDrugStock', style: const TextStyle(color: Colors.blue)),
              ),
            const SizedBox(height: 16),
            const Text('จำนวน', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'กรอกจำนวน', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.medical_services),
                label: const Text('บันทึกการจ่ายยา'),
                onPressed: isSaving ? null : _saveDispense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

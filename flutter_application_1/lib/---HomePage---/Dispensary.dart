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
        // Debug: แสดงข้อมูล drug
        if (data.isNotEmpty) {
          print('=== DRUG LIST DEBUG ===');
          print('Total drugs: ${data.length}');
          print('First drug: ${data.first}');
          print('Drug fields: ${data.first.keys.toList()}');
        }
      }
      // ดึง item stock
      final itemRes = await http.get(
        Uri.parse(ApiConfig.drugsProductItemEndpoint),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('=== ITEM API RESPONSE ===');
      print('Item API URL: ${ApiConfig.drugsProductItemEndpoint}');
      print('Item Response status: ${itemRes.statusCode}');
      print('Item Response body: ${itemRes.body}');
      
      if (itemRes.statusCode == 200) {
        final List<dynamic> itemData = jsonDecode(itemRes.body);
        setState(() {
          itemList = itemData;
        });
        // Debug: แสดงข้อมูล item
        if (itemData.isNotEmpty) {
          print('=== ITEM LIST DEBUG ===');
          print('Total items: ${itemData.length}');
          print('First item: ${itemData.first}');
          print('Item fields: ${itemData.first.keys.toList()}');
        } else {
          print('Item list is empty!');
        }
      } else {
        print('Failed to fetch items: ${itemRes.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
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
    print('=== FINDING ITEM DEBUG ===');
    print('Looking for drug ID: $drug');
    print('ItemList length: ${itemList.length}');
    if (itemList.isNotEmpty) {
      print('Sample item fields: ${itemList.first.keys.toList()}');
      for (var i in itemList.take(3)) {
        print('Item: productId=${i['productId']}, product_id=${i['product_id']}, id=${i['id']}');
      }
    }
    
    final item = itemList.firstWhere((i) => 
      i['productId']?.toString() == drug || 
      i['product_id']?.toString() == drug ||
      i['id']?.toString() == drug, 
      orElse: () => null);
    
    print('Found item: $item');
    
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
                  final item = itemList.firstWhere((i) => 
                    i['productId']?.toString() == value || 
                    i['product_id']?.toString() == value ||
                    i['id']?.toString() == value, 
                    orElse: () => null);
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

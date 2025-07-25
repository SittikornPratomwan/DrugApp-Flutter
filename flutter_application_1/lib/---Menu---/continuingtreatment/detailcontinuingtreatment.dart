import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailContinuingTreatmentPage extends StatelessWidget {
  final Map<String, dynamic> treatment;
  const DetailContinuingTreatmentPage({super.key, required this.treatment});

  IconData _getIconForField(String field) {
    switch (field.toLowerCase()) {
      case 'user_id':
        return Icons.person;
      case 'fever_type':
        return Icons.thermostat;
      case 'drug_name':
        return Icons.medication;
      case 'dosage':
        return Icons.medical_information;
      case 'status':
        return Icons.check_circle;
      case 'date':
        return Icons.calendar_today;
      case 'note':
        return Icons.note;
      default:
        return Icons.info;
    }
  }

  String _formatFieldName(String field) {
    switch (field.toLowerCase()) {
      case 'user_id':
        return 'รหัสผู้ป่วย';
      case 'fever_type':
        return 'ประเภทไข้';
      case 'drug_name':
        return 'ชื่อยา';
      case 'dosage':
        return 'ปริมาณยา';
      case 'status':
        return 'สถานะ';
      case 'date':
        return 'วันที่';
      case 'note':
        return 'หมายเหตุ';
      default:
        return field;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'active':
      case 'กำลังรักษา':
        return Colors.green;
      case 'completed':
      case 'เสร็จสิ้น':
        return Colors.blue;
      case 'pending':
      case 'รอดำเนินการ':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _scheduleNewAppointment(BuildContext context) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'เลือกวันนัดหมายใหม่',
      confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
    );

    if (newDate != null) {
      // แปลงวันที่เป็น ddMMyyyy
      String formattedDate =
          '${newDate.day.toString().padLeft(2, '0')}${newDate.month.toString().padLeft(2, '0')}${newDate.year}';

      try {
        final response = await http.patch(
          Uri.parse('http://192.168.56.111:8516/drugs/product/exp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': treatment['drug_id'] ?? treatment['product_id'] ?? treatment['id'],
            'receiveTime': formattedDate,
          }),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เปลี่ยนวันนัดใหม่สำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เปลี่ยนวันนัดใหม่ไม่สำเร็จ: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _endTreatment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('สิ้นสุดการรักษา'),
          content: const Text('คุณต้องการสิ้นสุดการรักษานี้หรือไม่?\nการกระทำนี้ไม่สามารถยกเลิกได้'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Call API to end treatment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('สิ้นสุดการรักษาเรียบร้อยแล้ว'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.pop(context); // กลับไปหน้าก่อนหน้า
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('สิ้นสุด'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'รายละเอียดการรักษาต่อเนื่อง',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.medical_services_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ข้อมูลการรักษา',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'รายละเอียดครบถ้วน',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Details Cards
                  ...treatment.entries.map((entry) {
                    final key = entry.key;
                    final value = entry.value;
                    final displayValue = value?.toString() ?? '-';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIconForField(key),
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatFieldName(key),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    
                                    // Special handling for status
                                    if (key.toLowerCase() == 'status')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(displayValue).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getStatusColor(displayValue),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          displayValue,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(displayValue),
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        displayValue,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ข้อมูลนี้อัปเดตล่าสุดจากระบบ กรุณาติดต่อเจ้าหน้าที่หากมีข้อสงสัย',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // เพิ่มพื้นที่ให้ปุ่มด้านล่าง
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ปุ่มนัดวันใหม่ (ซ้าย) - เปลี่ยนจากขวามาซ้าย
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scheduleNewAppointment(context),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('นัดวันใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // ปุ่มสิ้นสุดการรักษา (ขวา) - เปลี่ยนจากซ้ายมาขวา
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _endTreatment(context),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('สิ้นสุดการรักษา'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
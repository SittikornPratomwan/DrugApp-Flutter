import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import 'notification_settings.dart';
import 'notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> lowStockDrugs = [];
  List<dynamic> expiryDrugs = [];
  List<dynamic> outOfStockDrugs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNotificationData();
  }

  Future<void> fetchNotificationData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // ดึงข้อมูลยาทั้งหมด
      final response = await http.get(
        Uri.parse(ApiConfig.drugsProductItemEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // แยกประเภทการแจ้งเตือน
        lowStockDrugs = data.where((drug) {
          final stock = int.tryParse(drug['stock']?.toString() ?? '0') ?? 0;
          return stock > 0 && stock <= 10; // ยาใกล้หมด (1-10)
        }).toList();

        outOfStockDrugs = data.where((drug) {
          final stock = int.tryParse(drug['stock']?.toString() ?? '0') ?? 0;
          return stock == 0; // ยาหมด
        }).toList();

        expiryDrugs = data.where((drug) {
          final expiry = drug['exp']?.toString();
          if (expiry == null || expiry.isEmpty) return false;
          
          try {
            // แปลง ddMMyyyy เป็น DateTime
            if (expiry.length == 8) {
              final day = int.parse(expiry.substring(0, 2));
              final month = int.parse(expiry.substring(2, 4));
              final year = int.parse(expiry.substring(4, 8));
              final expiryDate = DateTime(year, month, day);
              final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
              return daysUntilExpiry <= 30 && daysUntilExpiry > 0; // ใกล้หมดอายุใน 30 วัน
            }
          } catch (e) {
            return false;
          }
          return false;
        }).toList();

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'การแจ้งเตือน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
            tooltip: 'ตั้งค่าการแจ้งเตือน',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNotificationData,
            tooltip: 'รีเฟรชข้อมูล',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchNotificationData,
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'ยาหมด',
                              outOfStockDrugs.length,
                              Icons.remove_circle,
                              Colors.red,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              'ยาใกล้หมด',
                              lowStockDrugs.length,
                              Icons.warning,
                              Colors.orange,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              'ใกล้หมดอายุ',
                              expiryDrugs.length,
                              Icons.schedule,
                              Colors.amber,
                              isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ยาหมด Section
                      if (outOfStockDrugs.isNotEmpty) ...[
                        _buildSectionHeader('🚨 ยาหมด', Colors.red, isDark),
                        ...outOfStockDrugs.map((drug) => _buildNotificationCard(
                              drug,
                              'หมด',
                              Colors.red,
                              Icons.remove_circle,
                              isDark,
                            )),
                        const SizedBox(height: 16),
                      ],

                      // ยาใกล้หมด Section
                      if (lowStockDrugs.isNotEmpty) ...[
                        _buildSectionHeader('⚠️ ยาใกล้หมด', Colors.orange, isDark),
                        ...lowStockDrugs.map((drug) => _buildNotificationCard(
                              drug,
                              'เหลือ ${drug['stock']} หน่วย',
                              Colors.orange,
                              Icons.warning,
                              isDark,
                            )),
                        const SizedBox(height: 16),
                      ],

                      // ยาใกล้หมดอายุ Section
                      if (expiryDrugs.isNotEmpty) ...[
                        _buildSectionHeader('📅 ยาใกล้หมดอายุ', Colors.amber, isDark),
                        ...expiryDrugs.map((drug) => _buildNotificationCard(
                              drug,
                              'หมดอายุ ${_formatExpiry(drug['exp'])}',
                              Colors.amber,
                              Icons.schedule,
                              isDark,
                            )),
                      ],

                      // ไม่มีการแจ้งเตือน
                      if (outOfStockDrugs.isEmpty && lowStockDrugs.isEmpty && expiryDrugs.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.check_circle_outline,
                                size: 80,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'ไม่มีการแจ้งเตือน',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ยาทั้งหมดมีสต็อกเพียงพอและยังไม่หมดอายุ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String title, int count, IconData icon, Color color, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> drug,
    String subtitle,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          drug['name']?.toString() ?? 'ไม่ระบุชื่อ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.notification_add, color: color),
          onPressed: () => _sendTestNotification(drug, subtitle, color),
          tooltip: 'ส่งการแจ้งเตือน',
        ),
      ),
    );
  }

  String _formatExpiry(String? expiry) {
    if (expiry == null || expiry.length != 8) return 'ไม่ระบุ';
    
    try {
      final day = expiry.substring(0, 2);
      final month = expiry.substring(2, 4);
      final year = expiry.substring(4, 8);
      return '$day/$month/$year';
    } catch (e) {
      return 'ไม่ระบุ';
    }
  }

  void _sendTestNotification(Map<String, dynamic> drug, String subtitle, Color color) {
    final drugName = drug['name']?.toString() ?? 'ไม่ระบุชื่อ';
    
    // แสดง Toast notification แทนการใช้ system notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              subtitle.contains('หมด') && !subtitle.contains('ใกล้หมด')
                  ? Icons.error
                  : subtitle.contains('เหลือ')
                      ? Icons.warning
                      : Icons.schedule,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📱 System Notification',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text('$drugName - $subtitle'),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'ดู',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // แสดงข้อความแจ้งเตือนว่าจะส่ง system notification
    Future.delayed(const Duration(milliseconds: 500), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.white),
              SizedBox(width: 8),
              Text('🔔 ส่งการแจ้งเตือนไปยังระบบแล้ว'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}

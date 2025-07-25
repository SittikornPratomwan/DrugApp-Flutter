import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool notificationsEnabled = true;
  bool lowStockAlerts = true;
  bool expiryAlerts = true;
  bool appointmentReminders = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  
  int lowStockThreshold = 10;
  int expiryWarningDays = 30;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      lowStockAlerts = prefs.getBool('low_stock_alerts') ?? true;
      expiryAlerts = prefs.getBool('expiry_alerts') ?? true;
      appointmentReminders = prefs.getBool('appointment_reminders') ?? true;
      soundEnabled = prefs.getBool('sound_enabled') ?? true;
      vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      lowStockThreshold = prefs.getInt('low_stock_threshold') ?? 10;
      expiryWarningDays = prefs.getInt('expiry_warning_days') ?? 30;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('low_stock_alerts', lowStockAlerts);
    await prefs.setBool('expiry_alerts', expiryAlerts);
    await prefs.setBool('appointment_reminders', appointmentReminders);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setBool('vibration_enabled', vibrationEnabled);
    await prefs.setInt('low_stock_threshold', lowStockThreshold);
    await prefs.setInt('expiry_warning_days', expiryWarningDays);

    // ใช้ NotificationService เพื่อแจ้งเตือนการบันทึก
    await NotificationService.showNotification(
      id: 998,
      title: '✅ บันทึกสำเร็จ',
      body: 'การตั้งค่าการแจ้งเตือนถูกบันทึกแล้ว',
      payload: 'settings_saved',
    );

    // แสดง SnackBar แล้วกลับไปหน้า Settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ บันทึกการตั้งค่าแล้ว'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );

    // รอให้ SnackBar แสดงเสร็จแล้วกลับไปหน้า Settings
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ตั้งค่าการแจ้งเตือน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Settings
          _buildSectionHeader('การตั้งค่าทั่วไป', Icons.settings, isDark),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'เปิดใช้งานการแจ้งเตือน',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('เปิด/ปิดการแจ้งเตือนทั้งหมด'),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                  secondary: Icon(
                    notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                    color: notificationsEnabled ? Colors.green : Colors.grey,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(
                    'เสียงแจ้งเตือน',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('เปิด/ปิดเสียงเมื่อมีการแจ้งเตือน'),
                  value: soundEnabled,
                  onChanged: notificationsEnabled ? (value) {
                    setState(() {
                      soundEnabled = value;
                    });
                  } : null,
                  secondary: Icon(
                    soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: soundEnabled && notificationsEnabled ? Colors.blue : Colors.grey,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(
                    'การสั่นแจ้งเตือน',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('เปิด/ปิดการสั่นเมื่อมีการแจ้งเตือน'),
                  value: vibrationEnabled,
                  onChanged: notificationsEnabled ? (value) {
                    setState(() {
                      vibrationEnabled = value;
                    });
                  } : null,
                  secondary: Icon(
                    vibrationEnabled ? Icons.vibration : Icons.phone_android,
                    color: vibrationEnabled && notificationsEnabled ? Colors.purple : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Alert Types
          _buildSectionHeader('ประเภทการแจ้งเตือน', Icons.category, isDark),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'แจ้งเตือนยาใกล้หมด',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('แจ้งเตือนเมื่อยามีจำนวนน้อย'),
                  value: lowStockAlerts,
                  onChanged: notificationsEnabled ? (value) {
                    setState(() {
                      lowStockAlerts = value;
                    });
                  } : null,
                  secondary: Icon(
                    Icons.inventory_2,
                    color: lowStockAlerts && notificationsEnabled ? Colors.orange : Colors.grey,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(
                    'แจ้งเตือนยาหมดอายุ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('แจ้งเตือนเมื่อยาใกล้หมดอายุ'),
                  value: expiryAlerts,
                  onChanged: notificationsEnabled ? (value) {
                    setState(() {
                      expiryAlerts = value;
                    });
                  } : null,
                  secondary: Icon(
                    Icons.schedule,
                    color: expiryAlerts && notificationsEnabled ? Colors.red : Colors.grey,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(
                    'แจ้งเตือนการนัดหมาย',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('แจ้งเตือนการนัดรักษา'),
                  value: appointmentReminders,
                  onChanged: notificationsEnabled ? (value) {
                    setState(() {
                      appointmentReminders = value;
                    });
                  } : null,
                  secondary: Icon(
                    Icons.event,
                    color: appointmentReminders && notificationsEnabled ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Threshold Settings
          _buildSectionHeader('การตั้งค่าขีดจำกัด', Icons.tune, isDark),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.orange),
                  title: const Text(
                    'ขีดจำกัดยาใกล้หมด',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('แจ้งเตือนเมื่อยาเหลือ $lowStockThreshold หน่วยหรือน้อยกว่า'),
                  trailing: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: TextEditingController(text: lowStockThreshold.toString()),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      enabled: notificationsEnabled && lowStockAlerts,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onChanged: (value) {
                        final intValue = int.tryParse(value) ?? 10;
                        setState(() {
                          lowStockThreshold = intValue;
                        });
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.red),
                  title: const Text(
                    'ขีดจำกัดวันหมดอายุ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('แจ้งเตือนเมื่อยาจะหมดอายุใน $expiryWarningDays วัน'),
                  trailing: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: TextEditingController(text: expiryWarningDays.toString()),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      enabled: notificationsEnabled && expiryAlerts,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onChanged: (value) {
                        final intValue = int.tryParse(value) ?? 30;
                        setState(() {
                          expiryWarningDays = intValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('ทดสอบการแจ้งเตือน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: notificationsEnabled ? _testNotification : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกการตั้งค่า'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _saveSettings,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info Card
          Card(
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'ข้อมูลเพิ่มเติม',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• การแจ้งเตือนจะทำงานในเบื้องหลัง\n'
                    '• คุณสามารถปรับแต่งการตั้งค่าได้ตามต้องการ\n'
                    '• การแจ้งเตือนจะแสดงแม้เมื่อแอปไม่ได้เปิด',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
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

  void _testNotification() async {
    // ใช้ NotificationService แทน SnackBar
    await NotificationService.showNotification(
      id: 999,
      title: '🔔 ทดสอบการแจ้งเตือน',
      body: 'ยาเพนิซิลลินใกล้หมด (เหลือ 5 หน่วย)',
      payload: 'test_notification',
    );
    
    // แสดง SnackBar เพื่อยืนยันว่าส่งการแจ้งเตือนแล้ว
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ ส่งการแจ้งเตือนระบบแล้ว'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class NotificationService {
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // ...existing code...

    print('🔔 SYSTEM NOTIFICATION (ID: $id)');
    print('   📋 Title: $title');
    print('   📝 Body: $body');

    // ...existing code...
  }
}

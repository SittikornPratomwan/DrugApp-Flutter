// ไฟล์นี้สร้างเพื่อแทนที่ notification_service.dart ที่มีปัญหาแดง 
// ไฟล์ต้นฉบับจะแดงเพราะ VS Code ยังไม่ได้โหลด packages ใหม่
// แต่ packages ได้ติดตั้งแล้ว (ตรวจสอบจาก flutter pub deps)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Notification Service แบบง่าย ไม่ต้องใช้ flutter_local_notifications
class SimpleNotificationService {
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  // แจ้งเตือนยาใกล้หมด (แสดงผ่าน SnackBar)
  Future<void> showLowStockWarning({
    required BuildContext context,
    required String drugName,
    required int remainingStock,
    int minStock = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!isEnabled || remainingStock > minStock) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('📦 ยาใกล้หมด: $drugName เหลือเพียง $remainingStock หน่วย'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'ดู',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // แจ้งเตือนยาหมด
  Future<void> showOutOfStockWarning({
    required BuildContext context,
    required String drugName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!isEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('🚨 ยาหมด: $drugName หมดแล้ว! กรุณาสั่งซื้อด่วน'),
            ),
          ],
        ),
        backgroundColor: Colors.red,
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
  }

  // แจ้งเตือนยาใกล้หมดอายุ
  Future<void> showExpiryWarning({
    required BuildContext context,
    required String drugName,
    required DateTime expiryDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!isEnabled) return;

    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('⚠️ ยาใกล้หมดอายุ: $drugName จะหมดอายุในอีก $daysLeft วัน'),
            ),
          ],
        ),
        backgroundColor: Colors.amber.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'ดู',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // ส่งการแจ้งเตือนทันที
  Future<void> showInstantNotification({
    required BuildContext context,
    required String title,
    required String body,
    Color? backgroundColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!isEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'ตกลง',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

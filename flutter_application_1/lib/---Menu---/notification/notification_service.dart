class NotificationService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    _initialized = true;
    print('✅ NotificationService initialized for system notifications');
  }

  static Future<bool> requestPermissions() async {
    print('📱 Notification permissions requested');
    return true;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    // This simulates a system notification
    print('🔔 SYSTEM NOTIFICATION (ID: $id)');
    print('   📋 Title: $title');
    print('   📝 Body: $body');
    if (payload != null) print('   🏷️  Payload: $payload');
    print('   ⏰ Time: ${DateTime.now().toString().substring(11, 19)}');
    print('   ─────────────────────────────────');
    
    // In a real app, this would show as a native Android notification
    // For now, this console output shows the notification was "sent"
  }

  static Future<void> showStockAlert({
    required String drugName,
    required int stock,
    bool isOutOfStock = false,
  }) async {
    final title = isOutOfStock ? '🚨 ยาหมด!' : '⚠️ ยาใกล้หมด!';
    final body = isOutOfStock 
        ? '$drugName หมดแล้ว กรุณาเติมสต็อก'
        : '$drugName เหลือเพียง $stock หน่วย';

    await showNotification(
      id: drugName.hashCode,
      title: title,
      body: body,
      payload: 'stock_alert:$drugName',
    );
  }

  static Future<void> showExpiryAlert({
    required String drugName,
    required String expiryDate,
  }) async {
    await showNotification(
      id: drugName.hashCode + 1000,
      title: '📅 ยาใกล้หมดอายุ!',
      body: '$drugName หมดอายุ $expiryDate',
      payload: 'expiry_alert:$drugName',
    );
  }

  static Future<void> cancelNotification(int id) async {
    print('Cancelled notification with ID: $id');
  }

  static Future<void> cancelAllNotifications() async {
    print('Cancelled all notifications');
  }
}

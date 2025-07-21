import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../---Translate---/locale_manager.dart';
import '../---Translate---/vocabulary.dart';

Future<void> logout(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.56.107:8514/drugs/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      // ถ้ามี token ให้เพิ่มใน headers เช่น
      // 'Authorization': 'Bearer $token',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ลบ token/session ที่เก็บไว้ (ถ้ามี)
      // ตัวอย่าง: await storage.delete(key: 'token');
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout ไม่สำเร็จ: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')));
  }
}

void showLogoutDialog(BuildContext context) {
  final String currentLanguage = localeManager.currentLocale.languageCode;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.get('logout', currentLanguage)),
        content: Text(currentLanguage == 'th'
            ? 'คุณต้องการออกจากระบบหรือไม่?'
            : 'Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(currentLanguage == 'th' ? 'ยกเลิก' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              logout(context);
            },
            child: Text(
              AppLocalizations.get('logout', currentLanguage),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

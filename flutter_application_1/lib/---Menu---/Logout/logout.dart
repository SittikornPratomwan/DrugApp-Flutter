import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> logout(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.56.106:8514/drugs/auth/logout'),
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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              logout(context);
            },
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

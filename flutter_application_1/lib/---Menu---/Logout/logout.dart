import 'package:flutter/material.dart';

void logout(BuildContext context) {
  // สามารถเพิ่ม logic เคลียร์ token หรือ session ได้ที่นี่
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/',
    (route) => false,
  );
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

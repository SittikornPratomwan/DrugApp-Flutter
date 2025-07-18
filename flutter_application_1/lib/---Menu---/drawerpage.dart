import 'package:flutter/material.dart';
import '../---Menu---/Logout/logout.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 176, 208, 240),
                  Color.fromARGB(255, 144, 184, 228),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color.fromARGB(255, 176, 208, 240),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'ผู้ใช้งาน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Drug Management System',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.medication, color: Colors.green),
            title: const Text('จัดการยา'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to drug management page
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.orange),
            title: const Text('คลังยา'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to inventory page
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.purple),
            title: const Text('รายงาน'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to reports page
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('ตั้งค่า'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings page
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('ช่วยเหลือ'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help page
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ'),
            onTap: () {
              Navigator.pop(context);
              showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

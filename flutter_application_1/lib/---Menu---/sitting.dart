import 'package:flutter/material.dart';
import '../../main.dart';

class SittingPage extends StatefulWidget {
  const SittingPage({super.key});

  @override
  State<SittingPage> createState() => _SittingPageState();
}

class _SittingPageState extends State<SittingPage> {
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('โหมดกลางคืน (Dark Mode)'),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (val) {
              themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              setState(() {});
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('เกี่ยวกับแอปพลิเคชัน'),
            subtitle: Text('Drug Management System v1.0'),
          ),
        ],
      ),
    );
  }
}

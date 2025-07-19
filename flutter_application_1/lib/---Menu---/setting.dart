import 'package:flutter/material.dart';
import '../../main.dart';
import '../---Translate---/locale_manager.dart';
import '../---Translate---/vocabulary.dart';

class SittingPage extends StatefulWidget {
  const SittingPage({super.key});

  @override
  State<SittingPage> createState() => _SittingPageState();
}

class _SittingPageState extends State<SittingPage> {
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
  String get currentLanguage => localeManager.currentLocale.languageCode;
  
  // เพิ่มตัวแปรสำหรับการแจ้งเตือน
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.get('settings', currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 32, left: 0, right: 0, bottom: 0),
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.get('dark_mode', currentLanguage)),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (val) {
              themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              setState(() {});
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(AppLocalizations.get('notifications', currentLanguage)),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
              // TODO: บันทึกการตั้งค่าการแจ้งเตือน
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.get('language', currentLanguage)),
            subtitle: Text(currentLanguage == 'th' 
              ? AppLocalizations.get('thai', currentLanguage)
              : AppLocalizations.get('english', currentLanguage)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.get('about_app', currentLanguage)),
            subtitle: Text(AppLocalizations.get('drug_management_system', currentLanguage)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.get('language', currentLanguage)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: Text(AppLocalizations.get('thai', currentLanguage)),
                trailing: currentLanguage == 'th' ? const Icon(Icons.check) : null,
                onTap: () {
                  localeManager.setLocale(const Locale('th', 'TH'));
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(AppLocalizations.get('english', currentLanguage)),
                trailing: currentLanguage == 'en' ? const Icon(Icons.check) : null,
                onTap: () {
                  localeManager.setLocale(const Locale('en', 'US'));
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

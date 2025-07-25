import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../main.dart';
import '../../---Translate---/locale_manager.dart';
import '../../---Translate---/vocabulary.dart';

class SittingPage extends StatefulWidget {
  const SittingPage({super.key});

  @override
  State<SittingPage> createState() => _SittingPageState();
}

class _SittingPageState extends State<SittingPage> {
  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
  String get currentLanguage => localeManager.currentLocale.languageCode;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkNotificationPermission();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load dark mode
    final isDark = prefs.getBool('dark_mode') ?? false;
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // Load notification setting
    final notificationEnabled = prefs.getBool('notifications_enabled') ?? true;
    setState(() {
      _notificationsEnabled = notificationEnabled;
    });
    
    // Load language
    final lang = prefs.getString('language_code');
    if (lang != null && lang != currentLanguage) {
      localeManager.setLocale(lang == 'th' ? const Locale('th', 'TH') : const Locale('en', 'US'));
    }
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // ขอ permission การแจ้งเตือน
      final status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() {
          _notificationsEnabled = true;
        });
        await _saveNotificationSetting(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.get('notifications_enabled', currentLanguage)),
            backgroundColor: Colors.green,
          ),
        );
      } else if (status.isPermanentlyDenied) {
        // ถ้าถูกปฏิเสธถาวร ให้เปิด settings
        _showPermissionDialog();
      } else {
        setState(() {
          _notificationsEnabled = false;
        });
        await _saveNotificationSetting(false);
      }
    } else {
      // ปิดการแจ้งเตือนและเปิด app settings
      setState(() {
        _notificationsEnabled = false;
      });
      await _saveNotificationSetting(false);
      
      // เปิด app settings ให้ user ปิดการแจ้งเตือนเอง
      await openAppSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('please_disable_notifications_in_settings', currentLanguage)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.get('notification_permission', currentLanguage)),
          content: Text(AppLocalizations.get('notification_permission_message', currentLanguage)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.get('cancel', currentLanguage)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text(AppLocalizations.get('open_settings', currentLanguage)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> _saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }

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
            onChanged: (val) async {
              themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              await _saveDarkMode(val);
              setState(() {});
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(AppLocalizations.get('notifications', currentLanguage)),
            subtitle: Text(
              _notificationsEnabled 
                ? AppLocalizations.get('notifications_on', currentLanguage)
                : AppLocalizations.get('notifications_off', currentLanguage),
              style: TextStyle(
                color: _notificationsEnabled ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
            secondary: Icon(
              _notificationsEnabled ? Icons.notifications : Icons.notifications_off,
              color: _notificationsEnabled ? Colors.green : Colors.red,
            ),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
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
                onTap: () async {
                  localeManager.setLocale(const Locale('th', 'TH'));
                  await _saveLanguage('th');
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(AppLocalizations.get('english', currentLanguage)),
                trailing: currentLanguage == 'en' ? const Icon(Icons.check) : null,
                onTap: () async {
                  localeManager.setLocale(const Locale('en', 'US'));
                  await _saveLanguage('en');
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

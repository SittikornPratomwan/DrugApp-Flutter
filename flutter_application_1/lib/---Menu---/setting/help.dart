import 'package:flutter/material.dart';
import '../../---Translate---/locale_manager.dart';
import '../../---Translate---/vocabulary.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String get currentLanguage => localeManager.currentLocale.languageCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.get('help', currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: Text(AppLocalizations.get('user_guide', currentLanguage)),
              subtitle: Text(
                currentLanguage == 'th' 
                  ? 'วิธีการใช้งานระบบจัดการยา' 
                  : 'How to use Drug Management System'
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showContentDialog(context, 
                  AppLocalizations.get('user_guide', currentLanguage),
                  AppLocalizations.get('user_guide_content', currentLanguage)
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.quiz, color: Colors.orange),
              title: Text(AppLocalizations.get('faq', currentLanguage)),
              subtitle: Text(
                currentLanguage == 'th'
                  ? 'คำถามที่พบบ่อยและคำตอบ'
                  : 'Frequently Asked Questions'
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showContentDialog(context,
                  AppLocalizations.get('faq', currentLanguage),
                  AppLocalizations.get('faq_content', currentLanguage)
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.contact_support, color: Colors.green),
              title: Text(AppLocalizations.get('contact_support', currentLanguage)),
              subtitle: Text(
                currentLanguage == 'th'
                  ? 'ติดต่อทีมสนับสนุน'
                  : 'Contact our support team'
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showContentDialog(context,
                  AppLocalizations.get('contact_support', currentLanguage),
                  AppLocalizations.get('contact_info', currentLanguage)
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.purple),
              title: Text(AppLocalizations.get('app_version', currentLanguage)),
              subtitle: const Text('v1.0.0'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                _showVersionInfo(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showContentDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                currentLanguage == 'th' ? 'ปิด' : 'Close',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.get('app_version', currentLanguage)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.get('drug_management_system', currentLanguage)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Version: 1.0.0'),
              const Text('Build: 100'),
              const SizedBox(height: 8),
              Text(
                currentLanguage == 'th'
                  ? 'พัฒนาโดย: เด็กฝึกงานจรูญรัตน์'
                  : 'Developed by: Internship at Jaroonrat',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                currentLanguage == 'th' ? 'ปิด' : 'Close',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}

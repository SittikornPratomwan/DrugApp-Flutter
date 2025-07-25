import 'package:flutter/material.dart';
import 'package:flutter_application_1/---Menu---/continuingtreatment/addcontinuingtreatment.dart';
import 'package:flutter_application_1/---Menu---/continuingtreatment/continuingtreatment.dart';
import 'package:flutter_application_1/---Menu---/drug/drugstock.dart';
import 'package:flutter_application_1/---Menu---/setting/logout.dart';
import 'drug/adddrug.dart';
import 'setting/setting.dart';
import 'setting/help.dart';
import '../---Translate---/locale_manager.dart';
import '../---Translate---/vocabulary.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  String get currentLanguage => localeManager.currentLocale.languageCode;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 176, 208, 240),
                  Color.fromARGB(255, 144, 184, 228),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color.fromARGB(255, 176, 208, 240),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.get('username', currentLanguage),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.get('drug_management_system', currentLanguage),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Menu Items
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: Text(AppLocalizations.get('Add Continuing treatment', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContinuingTreatmentPage(),
                ),
              );
            },
          ),

                    ListTile(
            leading: const Icon(Icons.medical_services_outlined, color: Colors.blue),
            title: Text(AppLocalizations.get('Continuing treatment', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContinuingTreatmentPage(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.medication, color: Colors.green),
            title: Text(AppLocalizations.get('add_drug', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDrugPage()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.orange),
            title: Text(AppLocalizations.get('inventory', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrugStockPage(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.purple),
            title: Text(AppLocalizations.get('reports', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to reports page
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: Text(AppLocalizations.get('settings', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SittingPage()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: Text(AppLocalizations.get('help', currentLanguage)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(AppLocalizations.get('logout', currentLanguage)),
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

import 'package:flutter/material.dart';
import '---HomePage---/homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '---Translate---/locale_manager.dart';
import '---Translate---/vocabulary.dart';

class Authen extends StatefulWidget {
  const Authen({super.key});

  @override
  State<Authen> createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  late double screenWidth, screenHeight;
  bool redEye = true;
  String? selectedLocation;
  int? selectedLocationId;
  bool isLoading = false;
  String get currentLanguage => localeManager.currentLocale.languageCode;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final Map<String, int> locationIdMap = {
    'LamLukKa': 1,
    'BanBueng': 2,
    'HeadOffice': 3,
  };

  @override//222
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 176, 208, 240), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset('images/logo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildTextField(
                    controller: usernameController,
                    labelText: AppLocalizations.get('username', currentLanguage),
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  buildPasswordField(),
                  const SizedBox(height: 30),
                  buildLocationRadio(),
                  const SizedBox(height: 30),
                  buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return Container(
      width: screenWidth * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, color: Colors.blue),
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      width: screenWidth * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: passwordController,
        obscureText: redEye,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                redEye = !redEye;
              });
            },
            icon: Icon(
              redEye ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue,
            ),
          ),
          labelText: AppLocalizations.get('password', currentLanguage),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildLocationRadio() {
    final List<Map<String, dynamic>> locations = [
      {'id': 1, 'name': 'LamLukKa', 'displayKey': 'lam_luk_ka'},
      {'id': 2, 'name': 'BanBueng', 'displayKey': 'ban_bueng'},
      {'id': 3, 'name': 'HeadOffice', 'displayKey': 'head_office'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.get('location', currentLanguage)}:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          ...locations.map(
            (loc) => RadioListTile<int>(
              title: Text(AppLocalizations.get(loc['displayKey'], currentLanguage)),
              value: loc['id'],
              groupValue: selectedLocationId,
              onChanged: (int? value) {
                setState(() {
                  selectedLocationId = value;
                  selectedLocation = loc['name'];
                });
              },
              activeColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginButton() {
    return Container(
      width: screenWidth * 0.6,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: isLoading ? null : handleLogin,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                AppLocalizations.get('login', currentLanguage),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> handleLogin() async {
    if (usernameController.text.isEmpty) {
      showSnackbar(
        '${AppLocalizations.get('please_enter', currentLanguage)} ${AppLocalizations.get('username', currentLanguage)}', 
        backgroundColor: Colors.red
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      showSnackbar(
        '${AppLocalizations.get('please_enter', currentLanguage)} ${AppLocalizations.get('password', currentLanguage)}', 
        backgroundColor: Colors.red
      );
      return;
    }
    if (selectedLocationId == null) {
      showSnackbar(
        AppLocalizations.get('please_select_location', currentLanguage), 
        backgroundColor: Colors.red
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.106:8514/drugs/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
          'location_id': selectedLocationId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          showSnackbar(AppLocalizations.get('login_success', currentLanguage), backgroundColor: Colors.blue);
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(location: selectedLocation ?? ''),
            ),
          );
          }
        } else {
          showSnackbar(
            data['message'] ?? AppLocalizations.get('login_failed', currentLanguage),
            backgroundColor: Colors.red,
          );
        }
      } else {
        showSnackbar(
          '${AppLocalizations.get('error_occurred', currentLanguage)}: ${response.statusCode}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Login error: $e'); // เพิ่มบรรทัดนี้
      showSnackbar(AppLocalizations.get('network_error', currentLanguage), backgroundColor: Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

  void showSnackbar(String message, {Color backgroundColor = Colors.blue}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}

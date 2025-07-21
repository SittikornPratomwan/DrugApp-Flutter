
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authen.dart';
import '---Translate---/locale_manager.dart';


final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadInitialSettings();
  runApp(MyApp());
}

Future<void> _loadInitialSettings() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Load dark mode setting
  final isDark = prefs.getBool('dark_mode') ?? false;
  themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  
  // Load language setting
  final langCode = prefs.getString('language_code') ?? 'th';
  localeManager.setLocale(langCode == 'th' 
    ? const Locale('th', 'TH') 
    : const Locale('en', 'US'));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeManager.localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('th', 'TH'),
                Locale('en', 'US'),
              ],
              theme: ThemeData(
                primarySwatch: Colors.blue,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.blue,
              ),
              themeMode: mode,
              home: const Authen(),
            );
          },
        );
      },
    );
  }
}
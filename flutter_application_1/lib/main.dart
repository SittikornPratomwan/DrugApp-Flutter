
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'authen.dart';
import '---Translate---/locale_manager.dart';


final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(MyApp());
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
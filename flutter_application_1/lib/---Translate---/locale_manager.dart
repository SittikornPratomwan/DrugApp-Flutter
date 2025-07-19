import 'package:flutter/material.dart';

class LocaleManager {
  static final LocaleManager _instance = LocaleManager._internal();
  factory LocaleManager() => _instance;
  LocaleManager._internal();

  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale('th', 'TH'));
  
  ValueNotifier<Locale> get localeNotifier => _localeNotifier;
  
  Locale get currentLocale => _localeNotifier.value;
  
  void setLocale(Locale locale) {
    _localeNotifier.value = locale;
  }
  
  void toggleLanguage() {
    if (_localeNotifier.value.languageCode == 'th') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('th', 'TH'));
    }
  }
}

// สร้าง instance global
final localeManager = LocaleManager();

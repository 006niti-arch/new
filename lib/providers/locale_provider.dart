// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    _saveLocale(locale);
    notifyListeners();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language_code', locale.languageCode);
  }
}

// A helper class to manage our supported languages
class L10n {
  static final all = [
    const Locale('en'), // English
    const Locale('es'), // Spanish
    const Locale('pt'), // Portuguese
    const Locale('ar'), // Arabic
  ];
}
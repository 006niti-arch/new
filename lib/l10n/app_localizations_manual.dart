// lib/l10n/app_localizations_manual.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizationsManual {
  final Locale locale;
  AppLocalizationsManual(this.locale);

  static AppLocalizationsManual of(BuildContext context) {
    return Localizations.of<AppLocalizationsManual>(context, AppLocalizationsManual)!;
  }

  static const LocalizationsDelegate<AppLocalizationsManual> delegate = _AppLocalizationsManualDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // THIS IS THE CORRECTED FILE PATH (without the extra 'assets/')
    String jsonString = await rootBundle.loadString('l10n/app_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsManualDelegate extends LocalizationsDelegate<AppLocalizationsManual> {
  const _AppLocalizationsManualDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'pt', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizationsManual> load(Locale locale) async {
    AppLocalizationsManual localizations = AppLocalizationsManual(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsManualDelegate old) => false;
}
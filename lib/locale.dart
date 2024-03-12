import 'dart:io';
import 'dart:ui';
import 'package:cellscan/settings.dart';
import 'package:flutter_translate/flutter_translate.dart';

late LocalizationDelegate localizationDelegate;

Locale getSystemLocale() => Locale(Platform.localeName.split('_')[0]);

Locale languageToLocale(Language language) {
  switch (language) {
    case Language.system: return getSystemLocale();
    case Language.english: return const Locale('en');
    case Language.chinese: return const Locale('zh');
    default: return localizationDelegate.fallbackLocale;
  }
}
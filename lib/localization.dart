import 'dart:io';
import 'dart:ui';
import 'package:cellscan/settings.dart';
import 'package:flutter_translate/flutter_translate.dart';



class CellScanLocale {

  late final LocalizationDelegate localizationDelegate;

  CellScanLocale._privateConstructor();
  static final CellScanLocale _instance = CellScanLocale._privateConstructor();
  factory CellScanLocale() => _instance;

  Future<void> init() async {
    localizationDelegate = await LocalizationDelegate.create(fallbackLocale: 'en', supportedLocales: ['en', 'zh']);
  }

  Locale getSystemLocale() => Locale(Platform.localeName.split('_')[0]);

  Language getSystemLanguage() {
    Locale systemLocale = getSystemLocale();
    switch (systemLocale.languageCode) {
      case 'en': return Language.english;
      case 'zh': return Language.chinese;
      default: return Language.english;
    }
  }

  Locale languageToLocale(Language language) {
    switch (language) {
      case Language.system: return getSystemLocale();
      case Language.english: return const Locale('en');
      case Language.chinese: return const Locale('zh');
      default: return localizationDelegate.fallbackLocale;
    }
  }

}
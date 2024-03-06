
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum CTheme {
  system,
  light,
  dark,
}

enum Language {
  system,
  english,
  chinese,
}

class Settings extends ChangeNotifier {

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Settings._privateConstructor();

  static final Settings _instance = Settings._privateConstructor();
  factory Settings() => _instance;


  late final SharedPreferences _prefs;

  static const _themeKey = 'theme';
  static const _languageKey = 'language';


  Language getLanguage() {
    final index = _prefs.getInt(_languageKey);
    return index == null ? Language.system : Language.values[index];
  }

  CTheme getTheme() {
    final index = _prefs.getInt(_themeKey);
    return index == null ? CTheme.system : CTheme.values[index];
  }

  Future<void> setLanguage(Language language) async {
    await _prefs.setInt(_languageKey, language.index);
    notifyListeners();
  }

  Future<void> setTheme(CTheme theme) async {
    await _prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }

}
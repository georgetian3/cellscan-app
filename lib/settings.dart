
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language {
  system,
  english,
  chinese,
}

class Settings extends ChangeNotifier {

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setPrefix('cellscan');
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

  ThemeMode getTheme() {
    final index = _prefs.getInt(_themeKey);
    return index == null ? ThemeMode.system : ThemeMode.values[index];
  }

  Future<void> setLanguage(Language language) async {
    await _prefs.setInt(_languageKey, language.index);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }

}
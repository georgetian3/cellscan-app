
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language {
  system, english, chinese;

  @override String toString() {
    switch (this) {
      case Language.system: return translate('settings.system');
      case Language.english: return translate('English');
      case Language.chinese: return translate('简体中文');
    }
  }
}

String themeToString(ThemeMode theme) {
  switch (theme) {
    case ThemeMode.system: return translate('settings.system');
    case ThemeMode.light: return translate('settings.light');
    case ThemeMode.dark: return translate('settings.dark');
  }
}

class Settings extends ChangeNotifier {

  Future<void> init() async {
    SharedPreferences.setPrefix('cellscan');
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  Settings._privateConstructor();
  static final Settings _instance = Settings._privateConstructor();
  factory Settings() => _instance;


  SharedPreferences? _prefs;

  static const _themeKey = 'theme';
  static const _languageKey = 'language';
  static const _uploadCountKey = 'uploads';
  static const _intervalKey = 'interval';


  Language getLanguage() {
    final index = _prefs?.getInt(_languageKey);
    return index == null ? Language.system : Language.values[index];
  }

  ThemeMode getTheme() {
    final index = _prefs?.getInt(_themeKey);
    return index == null ? ThemeMode.system : ThemeMode.values[index];
  }

  int getInterval() {
    return _prefs?.getInt(_intervalKey) ?? 10;
  }

  int getUploadCount() {
    final uploadCount = _prefs?.getInt(_uploadCountKey);
    return uploadCount ?? 0;
  }

  Future<void> incrementUploadCount(int increment) async {
    await _prefs?.setInt(_uploadCountKey, getUploadCount() + increment);
  }


  Future<void> setLanguage(Language language) async {
    await _prefs?.setInt(_languageKey, language.index);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _prefs?.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  Future<void> setInterval(int interval) async {
    if (interval <= 0) {
      return;
    }
    await _prefs?.setInt(_intervalKey, interval);
  }

}
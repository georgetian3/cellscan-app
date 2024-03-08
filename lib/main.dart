import 'dart:io';

import 'package:cellscan/database.dart';
import 'package:cellscan/main_page.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CellScanDatabase().init();
  await Settings().init();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettings = await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    )
  );

  final delegate = await LocalizationDelegate.create(fallbackLocale: 'en', supportedLocales: ['en', 'zh']);
  runApp(LocalizedApp(delegate, const CellScan()));

}

class CellScan extends StatefulWidget {
  const CellScan({super.key});
  @override createState() => _CellScanState();
}

class _CellScanState extends State<CellScan> {
  @override void initState() {
    super.initState();
    updateTheme();
    updateLanguage();
    Settings().addListener(updateTheme);
    Settings().addListener(updateLanguage);
  }

  late ThemeMode _theme;
  void updateTheme() => setState(() => _theme = Settings().getTheme());
  late Language _language;
  void updateLanguage() => setState(() => _language = Settings().getLanguage());

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'CellScan',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: _language == Language.system ? Locale(Platform.localeName)
              : _language == Language.english ? const Locale('en')
              : _language == Language.chinese ? const Locale('zh')
              : localizationDelegate.fallbackLocale,
        theme: ThemeData(useMaterial3: true),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        themeMode: _theme,
        home: const MainPage()
      )
    );
  }
}
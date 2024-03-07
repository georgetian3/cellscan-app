import 'package:cellscan/main_page.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';


void main() async {
  await Settings().init();


  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettings = await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    )
  );

  final delegate = await LocalizationDelegate.create(fallbackLocale: 'en_US', supportedLocales: ['en_US', 'zh_CN']);
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
    Settings().addListener(updateTheme);
  }

  late ThemeMode _theme;
  void updateTheme() => setState(() => _theme = Settings().getTheme());

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
        locale: localizationDelegate.currentLocale,
        theme: ThemeData(useMaterial3: true),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        themeMode: _theme,
        home: const MainPage()
        ),
      );

  }
}
import 'package:cellscan/cellscan.dart';
import 'package:cellscan/database.dart';
import 'package:cellscan/notifications.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_translate/flutter_translate.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await FlutterBackground.initialize(androidConfig: const FlutterBackgroundAndroidConfig(
      notificationTitle: "flutter_background example app",
      notificationText: "Background notification for keeping the example app running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
  ));
  await FlutterBackground.enableBackgroundExecution();

  await Settings().init();
  await Notifications().init();
  await CellScanDatabase().init();
  
  runApp(
    LocalizedApp(
      await LocalizationDelegate.create(fallbackLocale: 'en', supportedLocales: ['en', 'zh']),
      const CellScan()
    )
  );

}
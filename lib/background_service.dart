import 'dart:async';
import 'dart:ui';

import 'package:cellscan/database.dart';
import 'package:cellscan/localization.dart';
import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_translate/flutter_translate.dart';


const channelId = 'CellScan';
const channelName = 'Status';
const notificationId = 0;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // service.on('stop').listen((event) {
  //   print('Background service stopping');
  //   service.stopSelf();
  // });

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const notificationDetails = NotificationDetails(android: AndroidNotificationDetails(
    channelId, channelName, icon: '@mipmap/ic_launcher', ongoing: true,
  ));

  await Settings().init();
  await CellScanDatabase().init();
  await CellScanLocale().init();

  // Notifications
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    String title;
    String body = '';
    if (!await PrerequisiteManager().allPrerequisitesSatisfied()) {
      title = translate('notifications.grant');
    } else {
      title = translate('notifications.scanningOn');
      
      if (Scanner().latestMeasurement != null && !Scanner().latestMeasurement!.hasLocation()) {
        title += ' - ${translate('notifications.noGPS')}';
        body = translate('gpsHint');
      }
    }    
    flutterLocalNotificationsPlugin.show(
      notificationId, title, body, notificationDetails,
    );
  });

  // Scan
  Timer.periodic(Scanner.measurementInterval, (timer) async {
    try {
      await Scanner().scan();
    } on Exception catch (e) {
      print('scan error:' + e.toString());
    }
  });
}


class BackgroundService {

  final _service = FlutterBackgroundService();

  BackgroundService._privateConstructor();
  static final BackgroundService _instance = BackgroundService._privateConstructor();
  factory BackgroundService() => _instance;

  Future<void> init() async {

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    const notificationChannel = AndroidNotificationChannel(
      channelId, channelName, importance: Importance.defaultImportance,
    );

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'))
    );
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);


    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, autoStart: true, isForegroundMode: false,
        notificationChannelId: channelId,
        foregroundServiceNotificationId: notificationId,
        initialNotificationTitle: 'CellScan',
        initialNotificationContent: '',
      ),
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
    );
  }

  Future<void> start() async {
    await _service.startService();
  }

  Future<void> stop() async {
    if (!await _service.isRunning()) {
      return;
    }
    _service.invoke('stop');
  }

}
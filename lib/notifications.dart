import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan.dart';
import 'package:cellscan/settings.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Notifications {

  static const channelId = 'cellscan';
  static const channelName = 'Status';
  static const notificationId = 0;

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _notificationDetails = const NotificationDetails(android: AndroidNotificationDetails(
    channelId, channelName, ongoing: true,
  ));

  Future<void> init() async {
    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'))
    );
  }

  Notifications._privateConstructor() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    PrerequisiteManager().addListener(() async => await updateNotification());
    Settings().addListener(() async => await updateNotification());
    Scanner().addListener(() async => await updateNotification());
  }

  Future<void> updateNotification() async {
    final dt = dateToString(DateTime.now()) + ' ';
    if (!await PrerequisiteManager().allPrerequisitesSatisfied()) {
      await show(dt + translate('notifications.grant'));
    } else if (Scanner().scanOn) {
      final nextMeasurement = Scanner().nextScan == null ? '' : '${translate('nextMeasurement')}: ${dateToString(Scanner().nextScan!)}\n';
      final uploadCount = '${translate('uploadedMeasurements')}: ${Settings().getUploadCount()}';
      await show(
        dt + translate('notifications.scanningOn') + (Scanner().noGPS ? ' - ${translate('notifications.noGPS')}' : ''),
        body: nextMeasurement + uploadCount
      );
    } else {
      await show(dt + translate('notifications.scanningOff'), body: '${translate('uploadedMeasurements')}: ${Settings().getUploadCount()}');
    }
  }

  static final Notifications _instance = Notifications._privateConstructor();
  factory Notifications() => _instance;

  Future<void> show(String title, {String? body}) async =>
    await _flutterLocalNotificationsPlugin.show(notificationId, title, body, _notificationDetails);

}
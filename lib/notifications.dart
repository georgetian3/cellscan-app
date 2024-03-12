import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_translate/flutter_translate.dart';


class Notifications {

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _notificationDetails = const NotificationDetails(android: AndroidNotificationDetails(
    'cellscan', 'Status', ongoing: true,
  ));

  Future<void> init() async {
    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'))
    );
  }

  Notifications._privateConstructor() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    PrerequisiteManager().addListener(() async => await updateNotification());
    Scanner().addListener(() async => await updateNotification());
  }

  Future<void> updateNotification() async {
    if (!await PrerequisiteManager().allPrerequisitesSatisfied()) {
      await show(translate('notifications.grant'));
    } else if (Scanner().scanOn) {
      await show(translate('notifications.scanningOn') + (Scanner().noGPS ? ' - ${translate('notifications.noGPS')}' : ''));
    } else {
      await show(translate('notifications.scanningOff'));
    }
  }

  static final Notifications _instance = Notifications._privateConstructor();
  factory Notifications() => _instance;

  Future<void> show(String title) async => await _flutterLocalNotificationsPlugin.show(0, title, null, _notificationDetails);

}
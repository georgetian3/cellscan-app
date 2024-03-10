import 'package:cellscan/scan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_translate/flutter_translate.dart';


class Notifications {

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _notificationDetails = const NotificationDetails(android: AndroidNotificationDetails(
    'cellscan', 'Status',
    ongoing: true,
    importance: Importance.low,
    priority: Priority.low,
  ));


  Future<void> init() async {
    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'))
    );
  }

  Notifications._privateConstructor() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    Scanner().addListener(() async => await show(Scanner().scanOn ? translate('scanningOn') : translate('scanningOff')));
  }
  static final Notifications _instance = Notifications._privateConstructor();
  factory Notifications() => _instance;

  Future<void> show(String title) async => await _flutterLocalNotificationsPlugin.show(0, title, null, _notificationDetails);

}
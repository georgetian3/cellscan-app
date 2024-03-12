import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart';
import 'package:version/version.dart';
import 'package:ota_update/ota_update.dart';

class Updater extends ChangeNotifier {

  Updater._privateConstructor();
  static final Updater _instance = Updater._privateConstructor();
  factory Updater() => _instance;

  Future<bool> hasUpdate() async {
    return true;
    try {
      final response = await head(Uri.parse('https://cellscan.georgetian.com/api/v1/apk/latest'));
      if (response.statusCode >= 300) {
        return false;
      }
      final filename = response.headers['content-disposition'] as String;
      final latestVersion = Version.parse(RegExp(r'\d+\.\d+\.\d+').firstMatch(filename)![0]!);
      final currentVersion = Version.parse((await PackageInfo.fromPlatform()).version);
      return latestVersion.compareTo(currentVersion) > 0;
    } on Exception catch (e) {
      // print(e.toString());
      return false;
    }
  }

  OtaEvent? _otaEvent;
  OtaEvent? get otaEvent => _otaEvent;

  // returns whether the update process has been initiated
  Future<bool> update() async {
    if (!await hasUpdate()) {
      return false;
    }
    try {
      OtaUpdate()
        .execute('https://cellscan.georgetian.com/api/v1/apk/latest')
        .listen((OtaEvent event) {
          _otaEvent = event;
          notifyListeners();
        },
      );
    } catch (e) {
      print('Failed to perform OTA update. Details: $e');
    }
    return true;
  }

}
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart';
import 'package:version/version.dart';

Future<bool> hasUpdate() async {
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
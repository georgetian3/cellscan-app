import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart';
import 'package:version/version.dart';

Future<bool> hasUpdate() async {
  try {
    final response = await get(Uri.parse('https://api.github.com/repos/georgetian3/cellscan-app/releases/latest'));
    if (response.statusCode >= 300) {
      return false;
    }
    final latestVersion = Version.parse((jsonDecode(response.body)['tag_name'] as String).replaceAll('v', ''));
    final currentVersion = Version.parse((await PackageInfo.fromPlatform()).version);
    return latestVersion.compareTo(currentVersion) > 0;
  } on Exception catch (e) {
    print(e.toString());
    return false;
  }
}
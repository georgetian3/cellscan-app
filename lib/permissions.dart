import 'dart:io';

import 'package:cellscan/scan.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const permissions = <String, List<Permission>>{
  'all': [
    // Permission.location,
    // Permission.locationAlways,
  ],
  'android': [
    // Permission.phone,
    // Permission.microphone
  ],
  'ios': [
  ],
};

List<Permission> getRequiredPermissions() {
  if (!permissions.containsKey(Platform.operatingSystem)) {
    print('Operating system not supported');
    return [];
  }
  return permissions['all']! + permissions[Platform.operatingSystem]!;
}

Future<bool> allPermissionsGranted() async {
  for (final permission in getRequiredPermissions()) {
    if (!await permission.isGranted) {
      print('Not granted: ${permission.toString()}');
      return false;
    }
  }
  return true;
}

Future<void> requestPermissions() async {
  await getRequiredPermissions().request();
}



class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});
  @override createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionsPage> {

  Map<Permission, PermissionStatus> permissionStatus = {};

  Future<bool> getPermissionStatus() async {
    final newPermissionStatus = <Permission, PermissionStatus>{};
    for (final permission in getRequiredPermissions()) {
      newPermissionStatus[permission] = await permission.status;
    }
    print('got permission new permission status:' + newPermissionStatus.toString());
    setState(() {permissionStatus = newPermissionStatus;});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CellScan - Permissions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const TextButton(onPressed: requestPermissions, child: Text('Grant permissions')),
            FutureBuilder(
              future: getPermissionStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != true) {
                  return emptyWidget;
                }
                if (permissionStatus.values.toSet() == {PermissionStatus.granted}) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScanPage()));
                }
                final ps = <Widget>[];
                for (final permission in permissionStatus.entries.toList()) {
                  ps.add(Row(
                    children: [
                      Text(permission.key.toString()),
                      Text(permission.value == PermissionStatus.granted ? '1' : '0'),
                    ],
                  ));
                }
                return Column(children: ps);
              },
            ),
          ],
        ),
      ),
    );
  }
}
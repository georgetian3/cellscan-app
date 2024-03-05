import 'package:cellscan/platform.dart';
import 'package:cellscan/scan.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const permissions = [
  Permission.phone,
  Permission.location,
  Permission.locationAlways,
];

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});
  @override createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionsPage> {

  Map<Permission, PermissionStatus> permissionStatus = {};

  Future<void> requestPermissions() async {
    print('requesting permissions');
    // try {
    //   await platform.invokeMethod<String>('permissions');
    // } on Exception {
    //   print('permission exception');
    // }
    for (final permission in permissions) {
      final res = await permission.request();
      print(permission.toString() + ' ' + res.toString());
    }
  }

  Future<bool> getPermissionStatus() async {
    final newPermissionStatus = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      newPermissionStatus[permission] = await permission.status;
    }
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
            TextButton(onPressed: requestPermissions, child: const Text('Grant permissions')),
            FutureBuilder(
              future: getPermissionStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != true) {
                  return emptyWidget;
                }
                if (permissionStatus.values.every((status) => status == PermissionStatus.granted)) {
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
            TextButton(onPressed: scan, child: Text('Scan')),
            Text('Previous scan: '),
            Text('Next scan: '),
            Text('Previous upload: '),
            Text('Next upload: '),
            Text('Total measurements: '),
            Text('Unuploaded measurements: '),
          ],
        ),
      ),
    );
  }
}
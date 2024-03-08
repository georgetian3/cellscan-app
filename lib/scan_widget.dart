import 'dart:async';

import 'package:cellscan/database.dart';
import 'package:cellscan/measurement.dart';
import 'package:cellscan/scan.dart';
import 'package:cellscan/settings.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:flutter_translate/flutter_translate.dart';

const jsonViewTheme = JsonViewTheme(
  keyStyle: TextStyle(color: Color.fromARGB(255, 156, 220, 254)),
  doubleStyle: TextStyle(color: Color.fromARGB(255, 181, 206, 168)),
  intStyle: TextStyle(color: Color.fromARGB(255, 181, 206, 168)),
  stringStyle: TextStyle(color: Color.fromARGB(255, 206, 145, 120)),
  boolStyle: TextStyle(color: Color.fromARGB(255, 86, 156, 214)),
  openIcon: Icon(Icons.add, color: Colors.grey),
  closeIcon: Icon(Icons.remove, color: Colors.grey),
  separator: Text(': ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
  backgroundColor: Colors.black
);

class ScanWidget extends StatefulWidget {
  const ScanWidget({super.key});
  @override createState() => _ScanWidgetState();
}

class _ScanWidgetState extends State<ScanWidget> {

  Measurement latestMeasurement = Measurement();
  Timer? scanTimer;

  @override
  void initState() {
    super.initState();
    scanTimer = Timer.periodic(const Duration(seconds: 60), (Timer t) async => await _scan());
    updateScanning();
    updateUploaded();
    Settings().addListener(updateScanning);
    CellScanDatabase().addListener(updateUploaded);
  }

  Future<void> _scan() async {
    if (!Settings().getScanning()) {
      return;
    }
    Measurement measurement = await scan();
    setState(() => latestMeasurement = measurement);
  }

  late bool _scanning;
  void updateScanning() => setState(() => _scanning = Settings().getScanning());

  late int _uploaded;
  late int _unuploaded;

  void updateUploaded() => setState(() async {
    _unuploaded = await CellScanDatabase().count();
    // _uploaded = Settings().
  });
  

  @override Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(translate('scan')),
          leading: Icon(
            Icons.cell_tower,
            color: _scanning ? Theme.of(context).primaryColor : null,
          ),
          trailing: Switch(
            onChanged: (scanning) async => await Settings().setScanning(scanning),
            value: _scanning,
          )
        ),
        const Divider(),
        ListTile(
          title: Text('Next scan'),
          trailing: Text(dateToString(DateTime.now()))
        ),
        ListTile(
          title: Text('Uploaded measurements'),
          trailing: Text(_uploaded.toString()),
        ),
        ListTile(
          title: Text('Unuploaded measurements'),
          trailing: Text(_unuploaded.toString()),
        ),
      ],
    );
  }


}
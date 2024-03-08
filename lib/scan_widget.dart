import 'package:cellscan/database.dart';
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


  @override
  void initState() {
    super.initState();
    updateNextScan();
    updateScanOn();
    updateUploaded();
    Scanner().addListener(updateNextScan);
    Scanner().addListener(updateScanOn);
    Scanner().addListener(updateUploaded);
  }

  DateTime? _nextScan;
  void updateNextScan() => setState(() => _nextScan = Scanner().nextScan);

  late bool _scanOn;
  void updateScanOn() => setState(() => _scanOn = Scanner().scanOn);

  int _uploaded = 0;
  int _unuploaded = 0;

  void updateUploaded() => CellScanDatabase().count().then((count) =>
    setState(() {
      _uploaded = Settings().getUploadCount();
      _unuploaded = count;
    })
  );

  @override Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(translate('scan')),
          leading: const Icon(Icons.cell_tower),
          trailing: Switch(
            onChanged: (scanning) => scanning ? Scanner().start() : Scanner().stop(),
            value: _scanOn,
          )
        ),
        const Divider(),
        ListTile(
          title: Text('Next scan'),
          trailing: Text(_nextScan == null ? '-' : dateToString(_nextScan!))
        ),
        ListTile(
          title: Text('Uploaded measurements'),
          trailing: Text(_uploaded.toString()),
        ),
        ListTile(
          title: Text('Unuploaded measurements'),
          subtitle: Text('Connect to the internet to automatically upload'),
          trailing: Text(_unuploaded.toString()),
        ),
      ],
    );
  }


}
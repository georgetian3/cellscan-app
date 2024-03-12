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
    Scanner().addListener(() => setState(() {}));
    CellScanDatabase().addListener(() => setState(() {}));
    Settings().addListener(() => setState(() {}));
  }

  @override Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(translate('scan')),
          leading: const Icon(Icons.cell_tower),
          trailing: Switch(
            onChanged: (scanning) => scanning ? Scanner().start() : Scanner().stop(),
            value: Scanner().scanOn,
          )
        ),
        const Divider(),
        ListTile(
          title: Text(translate('gpsSignal')),
          subtitle: Text(translate('signalHint')),
          trailing: Icon(Scanner().noGPS ? Icons.close : Icons.done)
        ),
        ListTile(
          title: Text(translate('nextMeasurement')),
          subtitle: Text('${translate('interval')}: ${Scanner().scanInterval.inSeconds}s'),
          trailing: Text(Scanner().nextScan == null ? '-' : dateToString(Scanner().nextScan!))
        ),
        ListTile(
          title: Text(translate('uploadedMeasurements')),
          trailing: Text(Settings().getUploadCount().toString()),
        ),
        ListTile(
          title: Text(translate('unuploadedMeasurements')),
          subtitle: Text(translate('connect')),
          trailing: Text(CellScanDatabase().count.toString()),
        ),
      ],
    );
  }


}
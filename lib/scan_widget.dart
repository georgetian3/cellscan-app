import 'package:cellscan/database.dart';
import 'package:cellscan/scan.dart';
import 'package:cellscan/settings.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';


class ScanWidget extends StatefulWidget {
  const ScanWidget({super.key});
  @override createState() => _ScanWidgetState();
}

class _ScanWidgetState extends State<ScanWidget> {


  @override
  void initState() {
    super.initState();
    Scanner().addListener(() => setState(() {}));
    // CellScanDatabase().addListener(() => setState(() {}));
    // Settings().addListener(() => setState(() {}));
  }

  @override Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(translate('progress'), style: Theme.of(context).textTheme.bodyLarge)
        ),
        // ListTile(
        //   title: Text(translate('gpsSignal')),
        //   subtitle: Text(translate('gpsHint')),
        //   trailing: Icon(Scanner().noGPS ? Icons.close : Icons.done)
        // ),
        // Expanded(
        //   child: ListView(
        //     children: [
        //       // ListTile(
        //       //   title: Text(translate('scan')),
        //       //   leading: const Icon(Icons.cell_tower),
        //       //   trailing: Switch(
        //       //     onChanged: (scanning) => scanning ? Scanner().start() : Scanner().stop(),
        //       //     value: Scanner().isRunning,
        //       //   )
        //       // ),
        //       // const Divider(),
              
        //       // ListTile(
        //       //   title: Text(translate('nextMeasurement')),
        //       //   subtitle: Text('${translate('interval')}: ${Scanner.measurementInterval}s'),
        //       //   trailing: Text(Scanner().nextMeasurement == null ? '-' : dateToString(Scanner().nextMeasurement!))
        //       // ),
        //       // ListTile(
        //       //   title: Text(translate('uploadedMeasurements')),
        //       //   trailing: Text(Settings().getUploadCount().toString()),
        //       // ),
        //       // ListTile(
        //       //   title: Text(translate('unuploadedMeasurements')),
        //       //   subtitle: Text(translate('connect')),
        //       //   trailing: Text(CellScanDatabase().count.toString()),
        //       // ),
        //     ],
        //   ),
        // )
      ]
    );
  }


}
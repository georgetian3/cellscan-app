import 'package:cellscan/measurement.dart';
import 'package:cellscan/platform.dart';
import 'package:cellscan/upload.dart';
import 'package:flutter/material.dart';
import 'dart:async';


Future<void> scan() async {

  Measurement measurement = Measurement();
  measurement.timeMeasured = DateTime.now();

  try {
    // first get location, as this usually takes longer
    measurement.location = await platform.invokeMethod<String>('location') ?? '';
    measurement.cells = await platform.invokeMethod<String>('cells') ?? '';
  } on Exception {
    measurement.location = '';
    measurement.cells = '';
  }

  // if (measurement.location == '') { // failed location measurement
  //   return;
  // }

  // if (measurement.cells == '') { // failed cells measurement
    
  //   return;
  // }

  uploadMeasurements([measurement.toMap()]);

}



class ScanPage extends StatelessWidget {

  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CellScan - Scan'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
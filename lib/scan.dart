import 'dart:convert';

import 'package:cellscan/measurement.dart';
import 'package:cellscan/platform.dart';
import 'package:cellscan/upload.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_json_view/flutter_json_view.dart';


Future<Measurement> scan() async {

  Measurement measurement = Measurement();
  measurement.timeMeasured = DateTime.now();

  try {
    // first get location, as this usually takes longer
    print('getting location');
    measurement.location = await platform.invokeMethod<String>('location').timeout(const Duration(seconds: 5), onTimeout: () => '{}') ?? '{}';
    print('getting cells');
    measurement.cells = await platform.invokeMethod<String>('cells') ?? '[]';
  } on Exception catch (e) {
    print('Scan exception:' + e.toString());
    measurement.location = '{}';
    measurement.cells = '[]';
  }

  // if (measurement.location == '') { // failed location measurement
  //   return;
  // }

  // if (measurement.cells == '') { // failed cells measurement
    
  //   return;
  // }


  uploadMeasurements([measurement.toMap()]);

  return measurement;

}

const jsonViewTheme = JsonViewTheme(
  keyStyle: TextStyle(color: Color.fromARGB(255, 156, 220, 254)),
  doubleStyle: TextStyle(color: Color.fromARGB(255, 181, 206, 168)),
  intStyle: TextStyle(color: Color.fromARGB(255, 181, 206, 168)),
  stringStyle: TextStyle(color: Color.fromARGB(255, 206, 145, 120)),
  boolStyle: TextStyle(color: Color.fromARGB(255, 86, 156, 214)),
  openIcon: Icon(Icons.add, color: Colors.grey),
  closeIcon: Icon(Icons.remove, color: Colors.grey),
  separator: Text(': ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
  backgroundColor: Colors.white
);

Map<String, dynamic> measurementToJson(Measurement measurement) {
  if (measurement.location == '') {
    measurement.location = '{}';
  }
  if (measurement.cells == '') {
    measurement.cells = '[]';
  }
  final map = measurement.toMap();
  map['location'] = jsonDecode(measurement.location);
  map['cells'] = jsonDecode(measurement.cells);
  return map;
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {

  Measurement latestMeasurement = Measurement();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CellScan'),
        actions: [
          IconButton(onPressed: () => print('settings pressed'), icon: const Icon(Icons.settings)),
        ]
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => setState(() => 
                scan().then((measurement) => setState(() => latestMeasurement = measurement))
              ), child: Text('Scan')),
              Text('Scan results: '),
              JsonView.map(measurementToJson(latestMeasurement), theme: jsonViewTheme)
            ],
          ),
        ),
      ),
    );
  }

}


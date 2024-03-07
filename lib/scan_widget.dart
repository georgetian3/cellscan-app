import 'dart:async';

import 'package:cellscan/measurement.dart';
import 'package:cellscan/scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';


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
  }

  Future<void> _scan() async {
    Measurement measurement = await scan();
    setState(() => latestMeasurement = measurement);
  }
  

  @override Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TextButton(onPressed: _scan, child: Text('Scan')),
          JsonView.map(measurementToJson(latestMeasurement), theme: jsonViewTheme)
        ],
      ),
    );
  }


}
import 'dart:async';
import 'dart:convert';

import 'package:cellscan/measurement.dart';
import 'package:cellscan/platform.dart';
import 'package:cellscan/upload.dart';


Future<Measurement> scan() async {


  Measurement measurement = Measurement();
  measurement.timeMeasured = DateTime.now();
  print('Scanning ' + measurement.timeMeasured.toString());


  try {
    // first get location, as this usually takes longer
    measurement.location = await platform.invokeMethod<String>('location').timeout(const Duration(seconds: 5), onTimeout: () => '{}') ?? '{}';
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
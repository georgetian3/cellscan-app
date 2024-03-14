import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:cellscan/background_service.dart';
import 'package:cellscan/database.dart';
import 'package:cellscan/measurement.dart';
import 'package:cellscan/prerequisites.dart';
// import 'package:cellscan/settings.dart';
import 'package:cellscan/upload.dart';
import 'package:flutter/material.dart';
import 'package:cellscan_native/cellscan_native.dart';

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

class Scanner extends ChangeNotifier {

  Scanner._privateConstructor() {
    // start();
  }

  static final Scanner _instance = Scanner._privateConstructor();
  factory Scanner() => _instance;

  Measurement? latestMeasurement;
  bool get noGPS => latestMeasurement != null && !latestMeasurement!.hasLocation();

  DateTime? _nextMeasurement;
  DateTime? get nextMeasurement => _nextMeasurement;

  bool _isScanning = false;

  static const Duration measurementInterval = Duration(seconds: 30); //Duration(seconds: Settings().getMeasurementInterval());

  // Timer? _timer;

  // Future<void> setScanInterval(Duration interval) async {
  //   final wasScanning = isRunning;
  //   if (wasScanning) {
  //     stop();
  //   }
  //   _measurementInterval = interval;
  //   Settings().setInterval(interval.inSeconds);
  //   notifyListeners();
  //   if (wasScanning) {
  //     start();
  //   }
  // }

  // bool _isRunning = false;
  // bool get isRunning => _isRunning;
  // Future<void> start() async {
  //   await BackgroundService().start();
  //   _isRunning = true;
  //   _nextMeasurement = DateTime.now().add(measurementInterval);
  //   _timer = Timer.periodic(measurementInterval, (timer) {
  //     _nextMeasurement = DateTime.now().add(measurementInterval);
  //     notifyListeners();
  //   });
  //   notifyListeners();
  // }

  // Future<void> stop() async {
  //   await BackgroundService().stop();
  //   _nextMeasurement = null;
  //   _timer?.cancel();
  //   _isRunning = false;
  //   notifyListeners();
  // }

  Future<void> scan() async {
    if (_isScanning || !await PrerequisiteManager().allPrerequisitesSatisfied()) {
      return;
    }

    _isScanning = true;
    notifyListeners();

    Measurement measurement = Measurement();
    measurement.timeMeasured = DateTime.now().toUtc();
    print('Scanning ' + measurement.timeMeasured.toString());

    try {
      // first get location, as this usually takes longer
      measurement.location = await CellscanNative().getLocation().timeout(const Duration(seconds: 5), onTimeout: () => '{}') ?? '{}';
      measurement.cells = await CellscanNative().getCells() ?? '[]';
    } on Exception catch (e) {
      print('Scan exception: ' + e.toString());
      measurement.location = '{}';
      measurement.cells = '[]';
    }

    print('cells ${measurement.cells.substring(0, min(20, measurement.cells.length))} location ${measurement.location.substring(0, min(20, measurement.location.length))}');

    // if (measurement.location.length + measurement.cells.length < 10) { // failed location measurement
    //   return Measurement();
    // }

    await CellScanDatabase().insertMeasurement(measurement);
    await uploadAndDeleteMeasurements();
    latestMeasurement = measurement;

    _isScanning = false;
    notifyListeners();

  }

}
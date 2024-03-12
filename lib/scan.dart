import 'dart:async';
import 'dart:convert';

import 'package:cellscan/database.dart';
import 'package:cellscan/measurement.dart';
import 'package:cellscan/platform.dart';
import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/update.dart';
import 'package:cellscan/upload.dart';
import 'package:flutter/material.dart';

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
    start();
  }

  static final Scanner _instance = Scanner._privateConstructor();
  factory Scanner() => _instance;

  Measurement? latestMeasurement;
  Timer? _timer;

  bool get noGPS => latestMeasurement != null && !latestMeasurement!.hasLocation();

  bool get scanOn => _timer?.isActive ?? false;

  DateTime? _nextScan;
  DateTime? get nextScan => _nextScan;

  bool _isScanning = false;

  final Duration _scanInterval = const Duration(seconds: 10);
  Duration get scanInterval => _scanInterval;

  Future<void> start() async {
    if (scanOn) {
      return;
    }
    scan();
    _timer = Timer.periodic(_scanInterval, (timer) async => await scan());
    notifyListeners();
  }

  void stop() {
    if (!scanOn) {
      return;
    }
    _timer?.cancel();
    _nextScan = null;
    notifyListeners();
  }

  Future<void> scan() async {

    await hasUpdate();

    _nextScan = DateTime.now().add(_scanInterval);
    notifyListeners();

    if (!await PrerequisiteManager().allPrerequisitesSatisfied()) {
      return;
    }

    _isScanning = true;
    notifyListeners();

    Measurement measurement = Measurement();
    measurement.timeMeasured = DateTime.now();
    print('Scanning ' + measurement.timeMeasured.toString());

    try {
      // first get location, as this usually takes longer
      measurement.location = await platform.invokeMethod<String>('location').timeout(const Duration(seconds: 5), onTimeout: () => '{}') ?? '{}';
      measurement.cells = await platform.invokeMethod<String>('cells') ?? '[]';
    } on Exception catch (e) {
      print('Scan exception: ' + e.toString());
      measurement.location = '{}';
      measurement.cells = '[]';
    }

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
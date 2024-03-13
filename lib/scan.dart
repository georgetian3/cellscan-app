import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cellscan/database.dart';
import 'package:cellscan/measurement.dart';
import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/settings.dart';
import 'package:cellscan/upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final platform = const MethodChannel('com.georgetian.cellscan/cell_info');


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

  Duration _scanInterval = Duration(seconds: Settings().getInterval());
  Duration get scanInterval => _scanInterval;

  Future<void> setScanInterval(Duration interval) async {
    _scanInterval = interval;
    Settings().setInterval(interval.inSeconds);
    notifyListeners();
    // start();
  }

  void start() {
    if (scanOn) {
      stop();
    }
    scan();
    _timer = Timer.periodic(_scanInterval, (timer) async {
      _nextScan = DateTime.now().add(_scanInterval);
      await scan();
    });
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
      measurement.location = await MethodChannel('com.georgetian.cellscan/cell_info').invokeMethod<String>('location').timeout(const Duration(seconds: 5), onTimeout: () => '{}') ?? '{}';
      measurement.cells = await MethodChannel('com.georgetian.cellscan/cell_info').invokeMethod<String>('cells') ?? '[]';
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
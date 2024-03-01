import 'dart:async';

import 'package:cellscan/measurement.dart';
import 'package:sqflite/sqflite.dart';



class CellScanState {

  Timer? _scanTimer;
  void startScan(Function callback) {
    if (_scanTimer != null && _scanTimer!.isActive) {
      return;
    }
    _scanTimer = Timer.periodic(const Duration(minutes: 1), (timer) => callback());
  }
  void stopScan() {
    if (_scanTimer != null && _scanTimer!.isActive) {
      _scanTimer!.cancel();
    }
  }

  // insert measurements into local database
  Future<void> insertMeasurements(List<Measurement> measurements) async {


  }

 

}

final cellScanState = CellScanState();
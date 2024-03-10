import 'dart:async';

import 'package:cellscan/measurement.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class CellScanDatabase extends ChangeNotifier {

  static const MEASUREMENT_TABLE = 'measurement';

  late Database _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'measurements.db'),
      version: 1,
      onUpgrade: (db, oldVersion, newVersion) => db.execute('''
        CREATE TABLE measurement (
          id            INTEGER PRIMARY KEY AUTOINCREMENT,
          time_measured TEXT,
          location      TEXT,
          cells         TEXT
        );
      ''')
    );
  }

  CellScanDatabase._privateConstructor();
  static final CellScanDatabase _instance = CellScanDatabase._privateConstructor();
  factory CellScanDatabase() => _instance;

  

  Future<List<Map<String, Object?>>> getMeasurements() async {
    return await _database.query(MEASUREMENT_TABLE);
  }

  Future<void> deleteMeasurements(List<Map<String, Object?>> measurements) async {
    final batch = _database.batch();
    for (final measurement in measurements) {
      batch.delete(MEASUREMENT_TABLE, where: 'id = ${measurement['id']}');
    }
    await batch.commit();
  }

  Future<void> insertMeasurement(Measurement measurement) async {
    await _database.insert(MEASUREMENT_TABLE, measurement.toMap());
  }

  Future<int> count() async {
    return Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(id) FROM $MEASUREMENT_TABLE')) ?? 0;
  }

}
import 'dart:async';

import 'package:cellscan/measurement.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class CellScanDatabase {
  static const MEASUREMENT_TABLE = 'measurement';

  late Database _database;

  CellScanDatabase() {
    getDatabasesPath().then((databasesPath) =>
      openDatabase(
        join(databasesPath, 'measurements.db'),
        onCreate: (db, version) => db.execute('''
          CREATE TABLE measurement (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            location    TEXT,
            cells       TEXT,
            uploaded    INTEGER
          );
        ''')
      ).then((value) => _database = value)
    );
  }

  Future<List<Map<String, Object?>>> getNotUploadedMeasurements() async {
    return _database.rawQuery('SELECT * FROM $MEASUREMENT_TABLE WHERE uploaded = 0');
  }

  Future<void> setUploaded(List<Map<String, Object?>> measurements) async {
    final batch = _database.batch();
    for (final measurement in measurements) {
      batch.update(MEASUREMENT_TABLE, {'uploaded': 1}, where: 'id = ${measurement['id']}');
    }
    await batch.commit();
  }

  Future<void> insertMeasurement(Measurement measurement) async {
    await _database.insert(MEASUREMENT_TABLE, measurement.toMap());
  }

}

CellScanDatabase cellScanDatabase = CellScanDatabase();
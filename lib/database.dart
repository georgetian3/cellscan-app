import 'dart:async';

import 'package:cellscan/measurement.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const MEASUREMENT_TABLE = 'measurement';

class CellScanDatabase {
  late Database _database;

  CellScanDatabase() {
    getDatabasesPath().then((databasesPath) =>
      openDatabase(
        join(databasesPath, 'measurements.db'),
        onCreate: (db, version) => db.execute('''
          CREATE TABLE measurement (
            id                      INTEGER PRIMARY KEY AUTOINCREMENT,
            longitude               REAL,
            latitude                REAL,
            altitude                REAL,
            os                      TEXT,
            cell_id                 INTEGER,
            signal_strength         REAL,
            time_measured           TEXT,
            misc                    TEXT,
            uploaded                INTEGER
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

}

CellScanDatabase cellScanDatabase = CellScanDatabase();
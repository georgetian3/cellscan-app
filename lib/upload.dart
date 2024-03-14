import 'dart:convert';
import 'package:cellscan/database.dart';
import 'package:cellscan/settings.dart';
import 'package:http/http.dart';

Future<Response> uploadMeasurements(List<Map<String, Object?>> measurements) async {
  final possiblyNonStringFields = ['location', 'cells'];
  for (final measurement in measurements) {
    for (final field in possiblyNonStringFields) {
      if (measurement[field] is! String) {
        measurement[field] = jsonEncode(measurement[field]);
      }
    }
  }
  return await post(
    Uri.parse('https://cellscan.georgetian.com/api/v1/measurements'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(measurements)
  );
}

Future<void> uploadAndDeleteMeasurements() async {
  final measurements = await CellScanDatabase().getMeasurements();
  try {
    if ((await uploadMeasurements(measurements)).statusCode < 300) {
      // delete local measurement only if upload successful
      await CellScanDatabase().deleteMeasurements(measurements);
      // await Settings().incrementUploadCount(measurements.length);
    }
  } on Exception {
    print('Upload failed');
  }
}
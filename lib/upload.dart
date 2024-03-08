import 'dart:convert';
import 'package:cellscan/database.dart';
import 'package:cellscan/settings.dart';
import 'package:http/http.dart';

Future<Response> uploadMeasurements(List<Map<String, Object?>> measurements) async {
  final response = await post(
    Uri.parse('https://cellscan.georgetian.com/api/v1/measurements'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(measurements)
  );
  if (response.statusCode >= 300) {
    print('${response.statusCode}: ${response.body}');
  }
  return response;
}

Future<void> uploadAndDeleteMeasurements() async {
  final measurements = await CellScanDatabase().getMeasurements();
  try {
    if ((await uploadMeasurements(measurements)).statusCode < 300) {
      print('Upload successful');
      // delete local measurement only if upload successful
      await CellScanDatabase().deleteMeasurements(measurements);
      await Settings().incrementUploadCount(measurements.length);
    }
  } on Exception {
    print('Upload failed');
  }
}
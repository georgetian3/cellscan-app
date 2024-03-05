import 'dart:convert';
import 'package:cellscan/database.dart';
import 'package:http/http.dart';

Future<Response> uploadMeasurements(List<Map<String, Object?>> measurements) async {
  print('Uploading measurements');
  final response = await post(
    Uri.parse('https://cellscan.georgetian.com/measurements'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(measurements)
  );
  if (response.statusCode >= 300) {
    print('${response.statusCode}: ${response.body}');
  }
  return response;
}

Future<void> uploadAndUpdateMeasurements() async {
  final measurements = await cellScanDatabase.getNotUploadedMeasurements();
  if ((await uploadMeasurements(measurements)).statusCode < 300) {
    await cellScanDatabase.setUploaded(measurements);
  }

}
import 'dart:convert';
import 'package:cellscan/database.dart';
import 'package:http/http.dart';

Future<void> uploadMeasurements() async {

  final measurements = await cellScanDatabase.getNotUploadedMeasurements();
  final response = await post(
    Uri.parse('https://cellscan.georgetian.com'),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(measurements)
  );

  if (response.statusCode < 300) {
    await cellScanDatabase.setUploaded(measurements);
  }

}
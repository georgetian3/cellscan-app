class Measurement {
  DateTime? timeMeasured;
  int? id;
  String location = '{}';
  String cells = '[]';

  Map<String, dynamic> toMap() {
    return {
      'time_measured': timeMeasured?.toUtc().toIso8601String(),
      'id': id,
      'location': location,
      'cells': cells
    };
  }

}
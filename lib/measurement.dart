class Measurement {
  DateTime? timeMeasured;
  int? id;
  String location = '{}';
  String cells = '[]';

  bool hasLocation() {
    return location.length > 10;
  }

  bool hasCells() {
    return cells.length > 10;
  }

  bool isValid() {
    return hasLocation() && hasCells();
  }

  Map<String, dynamic> toMap() {
    return {
      'time_measured': timeMeasured?.toUtc().toIso8601String(),
      'location': location,
      'cells': cells
    };
  }

}
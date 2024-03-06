import 'package:permission_handler/permission_handler.dart';

class Prerequisite {
  final String displayName;
  final Future<void> Function() satisfy;
  final Future<bool> Function() checkSatisfied;
  bool isSatisfied = false;

  Prerequisite(
    this.displayName,
    this.satisfy,
    this.checkSatisfied
  );
  
}

class PrerequisiteManager {

  static final _prerequisites = <Prerequisite>[];

  static const _requiredPermissions = [
    Permission.location,
    Permission.locationAlways,
    Permission.phone,
    Permission.ignoreBatteryOptimizations,
  ];

  PrerequisiteManager._privateConstructor() {
    for (final permission in _requiredPermissions) {
      _prerequisites.add(
        Prerequisite(
          permission.toString(),
          () async => await permission.request(),
          () async => await permission.status.isGranted
        )
      );
    }
  }

  static final PrerequisiteManager _instance = PrerequisiteManager._privateConstructor();

  factory PrerequisiteManager() {
    return _instance;
  }

  Future<List<Prerequisite>> getPrerequisites() async {
    await updatePrerequisites();
    for (final x in _prerequisites) {
      print(x.isSatisfied);
    }
    return _prerequisites;
  }

  Future<void> updatePrerequisites() async {
    for (final prerequisite in _prerequisites) {
      prerequisite.isSatisfied = await prerequisite.checkSatisfied();
    }
  }

  Future<void> satisfyAllPrerequisites() async {
    for (final prerequisite in _prerequisites) {
      if (!await prerequisite.checkSatisfied()) {
        await prerequisite.satisfy();
      }
    }
  }

  Future<bool> allPrerequisitesSatisfied() async {
    for (final prerequisite in _prerequisites) {
      if (!await prerequisite.checkSatisfied()) {
        return false;
      }
    }
    return true;
  }


}
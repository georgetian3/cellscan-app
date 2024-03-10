import 'dart:async';

import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
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

class PrerequisiteManager extends ChangeNotifier {

  static final _prerequisites = <Prerequisite>[];

  static const _requiredPermissions = [
    Permission.location,
    Permission.locationAlways,
    Permission.phone,
    Permission.ignoreBatteryOptimizations,
    Permission.notification,
  ];

  late Timer timer;

  PrerequisiteManager._privateConstructor() {

    // check prerequisite status every second
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async => await updatePrerequisites());

    for (final permission in _requiredPermissions) {
      _prerequisites.add(
        Prerequisite(
          permission.toString(),
          () async => await permission.request(),
          () async => await permission.status.isGranted
        )
      );
    }
    _prerequisites.add(
      Prerequisite(
        'Location service',
        () async => await Permission.location.serviceStatus == ServiceStatus.enabled,
        () async => await Permission.location.serviceStatus == ServiceStatus.enabled
      )
    );


  }

  static final PrerequisiteManager _instance = PrerequisiteManager._privateConstructor();

  factory PrerequisiteManager() {
    return _instance;
  }

  Future<List<Prerequisite>> getPrerequisites() async {
    await updatePrerequisites();
    return _prerequisites;
  }

  Future<void> updatePrerequisites() async {
    print('updating prereqs');
    bool changed = false;
    for (final prerequisite in _prerequisites) {
      bool newValue = await prerequisite.checkSatisfied();
      if (prerequisite.isSatisfied != newValue) {
        prerequisite.isSatisfied = newValue;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> satisfyAllPrerequisites() async {
    for (final prerequisite in _prerequisites) {
      if (!await prerequisite.checkSatisfied()) {
        await prerequisite.satisfy();
      }
    }
    updatePrerequisites();
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

class PrerequisitesWidget extends StatelessWidget {

  const PrerequisitesWidget({super.key});
  
  @override Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(onPressed: () async => await PrerequisiteManager().satisfyAllPrerequisites(), child: const Text('Grant permissions')),
        Expanded(
          child: FutureBuilder(
            future: PrerequisiteManager().getPrerequisites(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return emptyWidget;
              }
              final prerequisites = snapshot.data!;
              return ListView(
                children: [
                  for (final prerequisite in prerequisites) 
                    ListTile(
                      title: Text(prerequisite.displayName),
                      trailing: Icon(prerequisite.isSatisfied ? Icons.done : Icons.close),
                    )
                ]
              );
            },
          ),
        )
      ],
    );
  }

}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;


class Prerequisite {
  final String displayNameKey;
  final Future<void> Function() satisfy;
  final Future<bool> Function() checkSatisfied;
  bool isSatisfied = false;

  Prerequisite(
    this.displayNameKey,
    this.satisfy,
    this.checkSatisfied
  );
  
}

String permissionToKey(Permission permission) {
  switch (permission) {
    case Permission.location: return 'prerequisites.location';
    case Permission.locationAlways: return 'prerequisites.locationAlways';
    case Permission.phone: return 'prerequisites.phone';
    case Permission.ignoreBatteryOptimizations: return 'prerequisites.battery';
    case Permission.notification: return 'prerequisites.notifications';
    default: return permission.toString();
  }
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
          permissionToKey(permission),
          () async => await permission.request(),
          () async => await permission.status.isGranted
        )
      );
    }

    _prerequisites.add(
      Prerequisite(
        'prerequisites.locationService',
        () async => await Geolocator.openLocationSettings(),
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

class PrerequisitesWidget extends StatefulWidget {
  const PrerequisitesWidget({super.key});
  @override createState() => _PrerequisitesWidgetState();
}

class _PrerequisitesWidgetState extends State<PrerequisitesWidget> {

  @override initState() {
    super.initState();
    updatePrerequisites();
    PrerequisiteManager().addListener(updatePrerequisites);
  }

  List<Prerequisite> _prerequisites = [];
  Future<void> updatePrerequisites() async {
    final tmp = await PrerequisiteManager().getPrerequisites();
    if (mounted) {
      setState(() => _prerequisites = tmp);
    }
  }
  
  @override Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(translate('prerequisites.introduction'), style: Theme.of(context).textTheme.bodyLarge)
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(translate('prerequisites.data'), style: Theme.of(context).textTheme.bodyLarge)
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(translate('prerequisites.explanation'), style: Theme.of(context).textTheme.bodyLarge)
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: () async => await PrerequisiteManager().satisfyAllPrerequisites(), child: Text(translate('prerequisites.grant'))),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final prerequisite in _prerequisites) 
                ListTile(
                  title: Text(translate(prerequisite.displayNameKey)),
                  trailing: Icon(prerequisite.isSatisfied ? Icons.done : Icons.close),
                )
            ]
          )
        )
      ],
    );
  }

}


import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan_widget.dart';
import 'package:cellscan/settings_page.dart';
import 'package:cellscan/update.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ota_update/ota_update.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override initState() {
    super.initState();
    updatePrerequisites();
    PrerequisiteManager().addListener(updatePrerequisites);
  }

  bool allPrerequisitesSatisfied = false;
  Future<void> updatePrerequisites() async {
    bool x = await PrerequisiteManager().allPrerequisitesSatisfied();
    setState(() => allPrerequisitesSatisfied = x);
  }
  

  bool _updateShown = false;

  Future<void> showUpdatePrompt(BuildContext context) async {
    if (_updateShown || !await Updater().hasUpdate()) {
      return;
    }
    _updateShown = true;
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
        title: Text(translate('updateAvailable')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(translate('cancel'))),
          TextButton(
            child: Text(translate('update')),
            onPressed: () async {
              Navigator.pop(context);
              if (!await Updater().update()) {
                return;
              }
              showUpdateProgress(context);
            }
          )
        ],
      )
    );
  }

  void showUpdateProgress(BuildContext context) => showDialog(
    context: context, barrierDismissible: false, builder: (BuildContext context) => StatefulBuilder(
      builder: (context, setState) {
        Updater().addListener(() => setState(() {}));
        if (Updater().otaEvent != null && Updater().otaEvent!.status != OtaStatus.DOWNLOADING) {
          Navigator.pop(context);
        }

        double value = 0;
        try {
          value = double.parse(Updater().otaEvent?.value ?? '0') / 100;
        } on Exception {
          value = 1;
        }
        return SimpleDialog(
          title: Text(translate('downloading')),
          contentPadding: const EdgeInsets.all(16),
          children: [LinearProgressIndicator(value: value)],
        );
      }
    )
  );


  @override build(BuildContext context) {
    showUpdatePrompt(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CellScan'),
        actions: [
          IconButton(
            onPressed: () => navigate(Navigator.push, context, const SettingsPage()),
            icon: const Icon(Icons.settings)
          ),
        ]
      ),
      body: allPrerequisitesSatisfied ? const ScanWidget() : const PrerequisitesWidget()
    );
  }

}
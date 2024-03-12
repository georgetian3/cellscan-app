

import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan_widget.dart';
import 'package:cellscan/settings_page.dart';
import 'package:cellscan/update.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override void initState() {
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

  Future<void> showUpdate(BuildContext context) async {
    if (_updateShown || !await hasUpdate()) {
      return;
    }
    _updateShown = true;
    showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(translate('updateAvailable')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(translate('cancel'))),
          TextButton(
            onPressed: () async => await launchUrl(Uri.parse('https://github.com/georgetian3/cellscan-app/releases/latest')),
            child: Text(translate('update'))
          )
        ],
      )
    );
  }

  @override build(BuildContext context) {
    showUpdate(context);
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
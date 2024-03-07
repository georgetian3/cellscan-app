

import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan_widget.dart';
import 'package:cellscan/settings_page.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';

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

  @override build(BuildContext context) => Scaffold(
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
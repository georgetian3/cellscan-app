import 'package:cellscan/main_page.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';

void main() async {
  await Settings().init();
  runApp(const CellScan());
}

class CellScan extends StatefulWidget {
  const CellScan({super.key});
  @override createState() => _CellScanState();
}

class _CellScanState extends State<CellScan> {
  @override void initState() {
    super.initState();
    updateTheme();
    Settings().addListener(updateTheme);
  }

  late ThemeMode _theme;
  void updateTheme() => setState(() => _theme = Settings().getTheme());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CellScan',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: _theme,
      home: const MainPage()
    );
  }
}
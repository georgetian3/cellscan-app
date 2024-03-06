import 'package:cellscan/prerequisites_page.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings().init();
  runApp(const CellScan());
}

class CellScan extends StatelessWidget {
  const CellScan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CellScan',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple
        ),
      ),
      themeMode: ThemeMode.dark,
      home:  const PermissionsPage()
    );
  }
}
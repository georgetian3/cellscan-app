import 'package:cellscan/permissions_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CellScan());
}

class CellScan extends StatelessWidget {
  const CellScan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CellScan',
      theme: ThemeData(useMaterial3: true),
      home:  const PermissionsPage()
    );
  }
}
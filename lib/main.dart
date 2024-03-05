import 'package:flutter/material.dart';
import 'permissions.dart';

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
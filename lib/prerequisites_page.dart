import 'package:cellscan/scan.dart';
import 'package:cellscan/utils.dart';
import 'package:flutter/material.dart';
import 'package:cellscan/prerequisites.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});
  @override createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionsPage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CellScan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: () async => await PrerequisiteManager().satisfyAllPrerequisites(), child: const Text('Grant permissions')),
            FutureBuilder(
              future: PrerequisiteManager().getPrerequisites(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return emptyWidget;
                }
                final prerequisites = snapshot.data!;
                if (prerequisites.every((prerequisite) => prerequisite.isSatisfied)) {
                  navigate(Navigator.pushReplacement, context, const ScanPage());
                }
                final ps = <Widget>[];
                for (final prerequisite in prerequisites) {
                  ps.add(Row(children: [
                    Text(prerequisite.displayName),
                    Text(prerequisite.isSatisfied ? '1' : '0')
                  ]));
                }
                return Column(children: ps);
              },
            ),
          ],
        ),
      ),
    );
  }
}
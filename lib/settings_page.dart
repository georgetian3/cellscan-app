import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override

  @override void initState() {
    super.initState();
    updateLanguage();
    Settings().addListener(updateLanguage);
  }

  void listener() {
    print('in listener');
  }

  late int _language;

  void updateLanguage() {
    print('updating language');
    setState(() => _language = Settings().getLanguage().index);
  }



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              title: Text('Language'),
              leading: const Icon(Icons.language),
              subtitle: Text('System'),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: StatefulBuilder(
                    builder: (_, __) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < Language.values.length; i++)
                          RadioListTile(
                            title: Text(Language.values[i].toString()),
                            groupValue: _language,
                            value: i,
                            onChanged: (value) async => await Settings().setLanguage(Language.values[value ?? 0])
                          )
                      ]
                    )
                  )
                )
              )
            ),
            ListTile(
              title: Text('Theme'),
              leading: Icon(Icons.dark_mode),
              subtitle: Text('System'),
            ),
            ListTile(
              title: Text('Information'),
              leading: Icon(Icons.info),
            ),
          ]
        ).toList(),
      ),
    );
  }
}
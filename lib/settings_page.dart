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
    updateTheme();
    Settings().addListener(updateLanguage);
    Settings().addListener(updateTheme);
  }

  late Language _language;
  void updateLanguage() => setState(() => _language = Settings().getLanguage());

  late ThemeMode _theme;
  void updateTheme() => setState(() => _theme = Settings().getTheme());

  @override build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'),),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              title: Text('Language'),
              leading: const Icon(Icons.language),
              subtitle: Text(_language.toString()),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) {
                    int language = Settings().getLanguage().index;
                    return SimpleDialog(
                      title: Text('Select language'),
                      children: [
                        for (var i = 0; i < Language.values.length; i++)
                          RadioListTile<int>(
                            title: Text(Language.values[i].toString()),
                            groupValue: language,
                            value: i,
                            onChanged: (value) async {
                              await Settings().setLanguage(Language.values[value ?? 0]);
                              setState(() => language = Settings().getLanguage().index);
                            }
                          )
                      ]
                    );
                  }
                )
              )
            ),
            ListTile(
              title: Text('Theme'),
              leading: const Icon(Icons.language),
              subtitle: Text(_theme.toString()),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) {
                    int theme = Settings().getTheme().index;
                    return SimpleDialog(
                      title: Text('Select theme'),
                      children: [
                        for (var i = 0; i < ThemeMode.values.length; i++)
                          RadioListTile<int>(
                            title: Text(ThemeMode.values[i].toString()),
                            groupValue: theme,
                            value: i,
                            onChanged: (value) async {
                              await Settings().setTheme(ThemeMode.values[value ?? 0]);
                              setState(() => theme = Settings().getTheme().index);
                            }
                          )
                      ]
                    );
                  }
                )
              )
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
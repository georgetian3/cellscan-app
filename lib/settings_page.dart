import 'package:cellscan/locale.dart';
import 'package:cellscan/scan.dart';
import 'package:cellscan/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override void initState() {
    super.initState();
    Settings().addListener(() => setState(() {}));
    Scanner().addListener(() => setState(() {}));
  }

  @override build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate('settings.settings'))),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              title: Text(translate('interval')),
              leading: const Icon(Icons.timer),
              subtitle: Slider(
                min: 10, max: 60, divisions: 5,
                value: Scanner().scanInterval.inSeconds.toDouble(),
                label: Scanner().scanInterval.inSeconds.toString(),
                onChanged: (double value) async => Scanner().setScanInterval(Duration(seconds: value.toInt())),
              ),
              trailing: Text('${Scanner().scanInterval.inSeconds.toString()}s')
            ),
            ListTile(
              title: Text(translate('settings.language')),
              leading: const Icon(Icons.language),
              subtitle: Text(Settings().getLanguage().toString()),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) {
                    int language = Settings().getLanguage().index;
                    return SimpleDialog(
                      title: Text(translate('settings.language')),
                      children: [
                        for (var i = 0; i < Language.values.length; i++)
                          RadioListTile<int>(
                            title: Text(Language.values[i].toString()),
                            groupValue: language,
                            value: i,
                            onChanged: (value) async {
                              await Settings().setLanguage(Language.values[value ?? 0]);
                              setState(() => language = Settings().getLanguage().index);
                              localizationDelegate.changeLocale(languageToLocale(Settings().getLanguage()));
                            }
                          )
                      ]
                    );
                  }
                )
              )
            ),
            ListTile(
              title: Text(translate('settings.theme')),
              leading: const Icon(Icons.dark_mode),
              subtitle: Text(themeToString(Settings().getTheme())),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) {
                    int theme = Settings().getTheme().index;
                    return SimpleDialog(
                      title: Text(translate('settings.theme')),
                      children: [
                        for (var i = 0; i < ThemeMode.values.length; i++)
                          RadioListTile<int>(
                            title: Text(themeToString(ThemeMode.values[i])),
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
            // ListTile(
            //   title: Text('Update'),
            //   leading: const Icon(Icons.update),
            //   onTap: () async {
            //     if (await showLoading(context, hasUpdate(), text: 'Updating')) {
            //       await launchUrl(Uri.parse('https://github.com/georgetian3/cellscan-app/releases/latest'));
            //     } else {
            //       showDialog(context: context, builder: (context) => SimpleDialog(title: Text('Latest version installed')));
            //     }
            //   }
            // ),
            ListTile(
              title: Text(translate('settings.information')),
              leading: const Icon(Icons.info),
              onTap: () async => await launchUrl(Uri.parse('https://cellscan.georgetian.com')),
            )
          ]
        ).toList(),
      ),
    );
  }
}
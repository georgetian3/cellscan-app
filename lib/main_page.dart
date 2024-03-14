

import 'package:cellscan/localization.dart';
import 'package:cellscan/prerequisites.dart';
import 'package:cellscan/scan_widget.dart';
import 'package:cellscan/settings.dart';
import 'package:cellscan/update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override initState() {
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

  Future<void> showUpdatePrompt(BuildContext context) async {
    if (!await Updater().hasUpdate()) {
      return;
    }
    if (_updateShown) {
      return;
    }
    _updateShown = true;
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
        title: Text(translate('updateAvailable')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(translate('cancel'))),
          TextButton(
            child: Text(translate('update')),
            onPressed: () async {
              Navigator.pop(context);
              if (!await Updater().update()) {
                return;
              }
              showUpdateProgress(context);
            }
          )
        ],
      )
    );
  }

  void showUpdateProgress(BuildContext context) => showDialog(
    context: context, barrierDismissible: false, builder: (BuildContext context) => StatefulBuilder(
      builder: (context, setState) {
        Updater().addListener(() => setState(() {}));
        if (Updater().otaEvent != null && Updater().otaEvent!.status != OtaStatus.DOWNLOADING) {
          Navigator.pop(context);
        }

        double value = 0;
        try {
          value = double.parse(Updater().otaEvent?.value ?? '0') / 100;
        } on Exception {
          value = 1;
        }
        return SimpleDialog(
          title: Text(translate('downloading')),
          contentPadding: const EdgeInsets.all(16),
          children: [LinearProgressIndicator(value: value)],
        );
      }
    )
  );


  @override build(BuildContext context) {
    showUpdatePrompt(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CellScan'),
        actions: [
          IconButton(
            onPressed: () => showDialog(
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
                            CellScanLocale().localizationDelegate.changeLocale(CellScanLocale().languageToLocale(Settings().getLanguage()));
                          }
                        )
                    ]
                  );
                }
              )
            ),
            icon: const Icon(Icons.translate)
          ),
          IconButton(
            onPressed: () => showDialog(
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
            ),
            icon: const Icon(Icons.dark_mode)
          ),
          IconButton(
            onPressed: () async => await launchUrl(Uri.parse('https://cellscan.georgetian.com')),
            icon: const Icon(Icons.info)
          ),
          
        ]
      ),
      body: allPrerequisitesSatisfied ? const ScanWidget() : const PrerequisitesWidget()
    );
  }

}
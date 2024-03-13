

import 'package:cellscan/locale.dart';
import 'package:cellscan/main_page.dart';
import 'package:cellscan/settings.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CellScan extends StatefulWidget {
  const CellScan({super.key});
  @override createState() => _CellScanState();
}

class _CellScanState extends State<CellScan> {
  @override void initState() {
    super.initState();
    Settings().addListener(() => setState(() => {}));
  }

  static const _brandBlue = Color.fromARGB(255, 135, 206, 250);

  @override
  Widget build(BuildContext context) {
    localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          lightColorScheme = lightColorScheme.copyWith(secondary: _brandBlue);
          darkColorScheme = darkDynamic.harmonized();
          darkColorScheme = darkColorScheme.copyWith(secondary: _brandBlue);
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: _brandBlue);
          darkColorScheme = ColorScheme.fromSeed(seedColor: _brandBlue, brightness: Brightness.dark);
        }
      
        return MaterialApp(
          title: 'CellScan',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            localizationDelegate
          ],
          supportedLocales: localizationDelegate.supportedLocales,
          locale: languageToLocale(Settings().getLanguage()),
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          themeMode: Settings().getTheme(),
          home: const MainPage()
        );
      })
    );
  }
}
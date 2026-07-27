import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:m3_dna/theme/app_theme.dart';

import 'l10n/app_localizations.dart';

import 'core/brand.dart';
import 'features/shell/home_shell.dart';

class VehaApp extends StatelessWidget {
  const VehaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(VehaBrand.seed, vibrant: VehaBrand.vibrantByDefault),
      darkTheme: AppTheme.dark(VehaBrand.seed, vibrant: VehaBrand.vibrantByDefault),
      themeMode: ThemeMode.system,
      // Семь языков с первого дня: русский, английский, украинский,
      // румынский, польский, немецкий, испанский. Язык берётся системный.
      supportedLocales: L.supportedLocales,
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

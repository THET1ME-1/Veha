import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3_dna/theme/app_theme.dart';

import 'l10n/app_localizations.dart';

import 'data/providers.dart';
import 'data/settings.dart';
import 'features/shell/home_shell.dart';

class VehaApp extends ConsumerWidget {
  const VehaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = ref.watch(appearanceProvider);

    // Будильники держатся в согласии с базой на всё время работы приложения.
    // Слушаем здесь, а не на экране: экран календаря можно закрыть, а
    // напоминания от этого пропасть не должны.
    ref.listen(reminderPlanProvider, (_, plan) {
      ref.read(reminderServiceProvider).apply(plan);
    });

    return MaterialApp(
      title: 'Veha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(look.seed, vibrant: look.vibrant),
      darkTheme: AppTheme.dark(look.seed, vibrant: look.vibrant),
      themeMode: look.themeMode,
      locale: look.locale,
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

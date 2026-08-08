import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:m3_dna/theme/app_theme.dart';

import 'l10n/app_localizations.dart';

import 'data/providers.dart';
import 'data/settings.dart';
import 'features/shell/fresh_now.dart';
import 'features/shell/home_shell.dart';
import 'features/shell/widget_sync.dart';

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

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // Material You берём только когда система его отдала: на Android 11
        // и ниже схемы нет, и тумблер там ничего не значит.
        final dynamicSeed = look.dynamicColor ? lightDynamic?.primary : null;
        final seed = dynamicSeed ?? look.seed;

        return MaterialApp(
      title: 'Veha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seed, vibrant: look.vibrant),
      darkTheme:
          AppTheme.dark(seed, vibrant: look.vibrant, amoled: look.amoled),
      themeMode: look.themeMode.flutter,
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
      home: const FreshNow(child: WidgetSync(child: HomeShell())),
        );
      },
    );
  }
}

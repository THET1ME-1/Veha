import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/settings/settings_screen.dart';

import 'golden_harness.dart';

/// Настройки применяются сразу: тема, насыщенность схемы и язык меняют вид
/// приложения в тот же момент, а не после «Сохранить».
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Снимок настроек', (tester) async {
    await pumpScreen(tester, const Scaffold(body: SafeArea(child: SettingsScreen())));
    await shoot(tester, 'settings');
  });

  testWidgets('Снимок настроек, тёмная', (tester) async {
    await pumpScreen(tester, const Scaffold(body: SafeArea(child: SettingsScreen())),
        brightness: Brightness.dark);
    await shoot(tester, 'settings_dark');
  });

  testWidgets('Выбор темы открывается листом', (tester) async {
    await pumpScreen(tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    await tester.tap(find.text('Тема'));
    await tester.pumpAndSettle();

    expect(find.text('Как в системе'), findsWidgets);
    expect(find.text('Тёмная'), findsOneWidget);
  });
}

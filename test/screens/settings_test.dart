import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
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

  // Режим темы переехал в карточку: четыре кнопки видны сразу, листа больше
  // нет. Подпись под переключателем говорит, что именно выбрано.
  testWidgets('Режим темы выбирается в карточке', (tester) async {
    await pumpScreen(tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    expect(find.text('Как в системе'), findsWidgets);

    await tester.tap(find.byIcon(VehaIcons.byName('schedule')));
    await tester.pumpAndSettle();

    expect(find.text('По времени суток'), findsOneWidget);
  });

  testWidgets('Стартовый экран выбирается и запоминается', (tester) async {
    await pumpScreen(tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    await tester.scrollUntilVisible(find.text('Стартовый экран'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Стартовый экран'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Список').last);
    await tester.pumpAndSettle();

    expect(find.text('Список'), findsOneWidget, reason: 'Выбор виден в строке');
    // «Вид на старте» имеет смысл только для календаря.
    expect(find.text('Вид на старте'), findsNothing);
  });

  testWidgets('Чёрный фон предлагается только тёмным темам', (tester) async {
    await pumpScreen(tester, const Scaffold(body: SafeArea(child: SettingsScreen())));
    expect(find.text('AMOLED'), findsOneWidget);

    await tester.tap(find.byIcon(VehaIcons.byName('light_mode')));
    await tester.pumpAndSettle();

    expect(find.text('AMOLED'), findsNothing,
        reason: 'В светлой теме чернить нечего');
  });
}

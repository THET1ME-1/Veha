import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/core/veha_theme.dart';
import 'package:veha/data/settings.dart';
import 'package:veha/features/settings/appearance_card.dart';
import 'package:veha/features/settings/settings_screen.dart';

import 'golden_harness.dart';

/// Настройки применяются сразу: тема, подпись событий и скругление меняют вид
/// приложения в тот же момент, а не после «Сохранить».
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Снимок настроек', (tester) async {
    await pumpScreen(
        tester, const Scaffold(body: SafeArea(child: SettingsScreen())));
    await shoot(tester, 'settings');
  });

  testWidgets('Снимок настроек, тёмная', (tester) async {
    await pumpScreen(
        tester, const Scaffold(body: SafeArea(child: SettingsScreen())),
        brightness: Brightness.dark);
    await shoot(tester, 'settings_dark');
  });

  // Режим темы живёт в карточке: три кнопки видны сразу, листа больше нет.
  testWidgets('Режим темы выбирается в карточке', (tester) async {
    await pumpScreen(
        tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    await tester.tap(find.byIcon(VehaIcons.byName('light_mode')));
    await tester.pumpAndSettle();

    final segment = tester.widget<SegmentedButton<VehaThemeMode>>(
      find.byType(SegmentedButton<VehaThemeMode>),
    );
    expect(segment.selected, {VehaThemeMode.light},
        reason: 'Выбранный режим виден в самом переключателе');
  });

  testWidgets('Подпись событий переключается тремя образцами', (tester) async {
    await pumpScreen(
        tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    expect(find.text('Иконки'), findsOneWidget);
    expect(find.text('Текст'), findsOneWidget);
    expect(find.text('Иконки и текст'), findsOneWidget);

    // Образцов ровно три, и каждый рисует блок так, как он будет выглядеть
    // в сетке недели.
    expect(find.byType(EventBlockSample), findsNWidgets(4),
        reason: 'Три образца подписи плюс превью скругления');
  });

  testWidgets('Скругление крутится ползунком и показывается сразу',
      (tester) async {
    await pumpScreen(
        tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    final before = tester.widget<CornerPicker>(find.byType(CornerPicker)).corner;
    expect(before, VehaTheme.defaultCorner);

    // Тянем ползунок вправо: угол обязан вырасти, а превью — перерисоваться.
    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pumpAndSettle();

    final after = tester.widget<CornerPicker>(find.byType(CornerPicker)).corner;
    expect(after, greaterThan(before));
    expect(after, lessThanOrEqualTo(VehaTheme.maxCorner));
  });

  testWidgets('Задачи и календари открываются из настроек', (tester) async {
    await pumpScreen(
        tester, const Scaffold(body: SafeArea(child: SettingsScreen())));

    expect(find.text('Список'), findsOneWidget);
    expect(find.text('Задачи'), findsOneWidget);
  });
}

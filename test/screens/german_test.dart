import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Немецкий проверяем отдельно: слова там самые длинные, и вёрстка ломается
/// именно на нём. Снимок показывает переполнение сразу — жёлто-чёрной лентой.
void main() {
  setUpAll(loadAppFonts);

  const de = Locale('de');

  testWidgets('Календарь по-немецки', (tester) async {
    await pumpScreen(tester, const HomeShell(), locale: de);
    await shoot(tester, 'de_calendar');
  });

  testWidgets('Настройки по-немецки', (tester) async {
    await pumpScreen(tester, const HomeShell(), locale: de);
    await tester.tap(find.text('Einstellungen'));
    await tester.pumpAndSettle();
    await shoot(tester, 'de_settings');
  });

  testWidgets('Форма события по-немецки', (tester) async {
    await pumpScreen(tester, const HomeShell(), locale: de);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Zahnarzttermin');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();

    await shoot(tester, 'de_event_form');
  });

  testWidgets('Календари по-немецки', (tester) async {
    await pumpScreen(tester, const HomeShell(), locale: de);
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    await shoot(tester, 'de_calendars');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/calendar_screen.dart';

import 'golden_harness.dart';

/// Разбор дня: сколько занято, где окна, что наехало друг на друга.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Разбор дня открывается из шапки', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('day-review')));
    await tester.pumpAndSettle();

    expect(find.text('Разбор дня'), findsOneWidget);
    expect(find.text('Занято'), findsOneWidget);
    expect(find.text('Свободно'), findsOneWidget);
    // В демо-дне урок наезжает на планёрку — разбор обязан это назвать.
    expect(find.text('Накладок: 1'), findsOneWidget);

    await shoot(tester, 'day_review');
  });

  testWidgets('Окно из разбора заводит событие', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('day-review')));
    await tester.pumpAndSettle();

    // Тап по окну открывает быстрый лист, уже подставив в него это время.
    await tester.tap(find.byKey(const ValueKey('gap-0')));
    await tester.pumpAndSettle();

    expect(find.text('Разбор дня'), findsNothing);
    expect(find.byType(TextField), findsWidgets);
  });
}

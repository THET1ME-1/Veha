import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/calendar/views/month_view.dart';

import 'golden_harness.dart';

/// День раскрывается листом поверх месяца.
///
/// ТЗ отводит месяцу вопрос «когда», а подробности показывает листом, который
/// тянется по высоте. Раньше тап по числу уводил в другой вид: человек, ткнув
/// в день ради проверки, терял картину месяца целиком и возвращался руками.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openMonth(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );
    await tester.tap(find.text('Месяц'));
    await tester.pumpAndSettle();
  }

  testWidgets('Тап по числу открывает лист, а месяц остаётся на экране',
      (tester) async {
    await openMonth(tester);

    await tester.tap(find.text('28').first);
    await tester.pumpAndSettle();

    expect(find.text('Открыть день'), findsOneWidget,
        reason: 'лист дня не открылся');
    expect(find.byType(MonthView), findsOneWidget,
        reason: 'месяц должен остаться под листом');
  });

  testWidgets('Из листа можно уйти в день целиком', (tester) async {
    await openMonth(tester);

    await tester.tap(find.text('28').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открыть день'));
    await tester.pumpAndSettle();

    expect(find.byType(MonthView), findsNothing);
  });

}

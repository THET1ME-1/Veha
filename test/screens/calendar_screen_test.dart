import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/calendar_screen.dart';

import 'golden_harness.dart';

/// Экран целиком, а не отдельный вид: только здесь видно, что данные доходят
/// из базы до карточек — с развёрнутыми рядами, полосами и занятыми днями
/// в строке недели.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openCalendar(WidgetTester tester,
      {Brightness brightness = Brightness.light}) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
      brightness: brightness,
    );
  }

  testWidgets('Календарь из базы · день', (tester) async {
    await openCalendar(tester);

    expect(find.text('Английский'), findsWidgets,
        reason: 'Повторяющееся занятие развёрнуто на сегодняшний день');
    await shoot(tester, 'calendar_day_db');
  });

  testWidgets('Календарь из базы · месяц', (tester) async {
    await openCalendar(tester);

    await tester.tap(find.text('Месяц'));
    await tester.pumpAndSettle();

    await shoot(tester, 'calendar_month_db');
  });

  testWidgets('Календарь из базы · неделя', (tester) async {
    await openCalendar(tester, brightness: Brightness.dark);

    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();

    await shoot(tester, 'calendar_week_db');
  });

  testWidgets('Календарь из базы · дни лентами', (tester) async {
    await openCalendar(tester);

    await tester.tap(find.text('Дни'));
    await tester.pumpAndSettle();

    await shoot(tester, 'calendar_bands_db');
  });
}

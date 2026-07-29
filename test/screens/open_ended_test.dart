import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/calendar/views/chain_view.dart';
import 'package:veha/features/calendar/views/clock_view.dart';

import 'golden_harness.dart';

/// Событие без времени окончания живёт в сетке полоской: занято начало,
/// а сколько это продлится — неизвестно.
void main() {
  setUpAll(loadAppFonts);

  const inheritance = Inheritance(
    calendars: {
      'home': VCalendar(
        id: 'home',
        name: 'Личное',
        iconName: 'build',
        color: Color(0xFFC2410C),
      ),
    },
    subcategories: {},
  );

  testWidgets('Открытое событие подписано одним временем начала',
      (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: ChainView(
          events: [
            VEvent(
              id: 'shop',
              calendarId: 'home',
              title: 'Мастерская',
              start: DateTime(2026, 7, 27, 14),
              end: DateTime(2026, 7, 27, 14),
            ),
          ],
          inheritance: inheritance,
        ),
      ),
    );

    expect(find.textContaining('с 14:00'), findsWidgets);
    expect(find.textContaining('14:00 –'), findsNothing,
        reason: 'Тире между началом и концом обещало бы длительность');
  });

  testWidgets('Открытое событие не растягивает сетку часов', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [
            VEvent(
              id: 'shop',
              calendarId: 'home',
              title: 'Мастерская',
              start: DateTime(2026, 7, 27, 14),
              end: DateTime(2026, 7, 27, 14),
            ),
            VEvent(
              id: 'call',
              calendarId: 'home',
              title: 'Созвон',
              start: DateTime(2026, 7, 27, 14, 30),
              end: DateTime(2026, 7, 27, 15, 30),
            ),
          ],
          inheritance: inheritance,
        ),
      ),
    );

    // Блок занимает пол шага сетки и не наезжает на следующее событие.
    final open = tester.getRect(find.byKey(const ValueKey('block-shop')));
    final call = tester.getRect(find.byKey(const ValueKey('block-call')));
    expect(open.bottom, lessThanOrEqualTo(call.top));
  });

  testWidgets('Форма заводит событие без окончания', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );

    await openEventEditor(tester, find.text('Обед с Ниной').first);

    await tester.tap(find.text('Без окончания'));
    await tester.pumpAndSettle();

    // Строка времени перестаёт показывать конец: показывать нечего.
    expect(find.textContaining('с 13:00'), findsWidgets);
  });
}

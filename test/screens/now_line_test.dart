import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/tape_view.dart';

import 'golden_harness.dart';

/// Риска «сейчас» в ленте дня.
///
/// Без неё день читается как список без точки отсчёта: непонятно, идёт пара
/// сейчас или уже кончилась. В сетке часов риска была всегда, лента её
/// потеряла при смене облика.
void main() {
  setUpAll(loadAppFonts);

  VEvent event(DateTime start, DateTime end, {String title = 'Пара'}) => VEvent(
        id: '$title-${start.hour}',
        calendarId: 'c1',
        title: title,
        start: start,
        end: end,
        timezone: 'Europe/Chisinau',
      );

  Widget tape({DateTime? now}) => TapeView(
        day: DateTime(2026, 8, 10),
        events: [
          event(DateTime(2026, 8, 10, 9), DateTime(2026, 8, 10, 10, 30)),
          event(DateTime(2026, 8, 10, 13), DateTime(2026, 8, 10, 14, 30),
              title: 'Лаба'),
        ],
        inheritance: const Inheritance(calendars: {}, subcategories: {}),
        now: now,
      );

  testWidgets('Сегодняшний день показывает риску', (tester) async {
    await pumpScreen(tester, tape(now: DateTime(2026, 8, 10, 9, 45)));

    expect(find.byKey(const Key('now-line')), findsOneWidget);
  });

  testWidgets('Риска стоит и между делами', (tester) async {
    await pumpScreen(tester, tape(now: DateTime(2026, 8, 10, 11, 30)));

    expect(find.byKey(const Key('now-line')), findsOneWidget);
  });

  testWidgets('В чужом дне риски нет', (tester) async {
    await pumpScreen(tester, tape());

    expect(find.byKey(const Key('now-line')), findsNothing);
  });
}

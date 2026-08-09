import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/week_view.dart';

import 'golden_harness.dart';

/// В неделе перенос идёт наискосок: другой час и другой день одним движением.
void main() {
  setUpAll(loadAppFonts);

  const inheritance = Inheritance(
    calendars: {
      'work': VCalendar(
        id: 'work',
        name: 'Работа',
        iconName: 'groups',
        color: Color(0xFF0369A1),
      ),
    },
    subcategories: {},
  );

  testWidgets('Пилюля переносится на соседний день', (tester) async {
    Duration? shift;

    final meeting = VEvent(
      id: 'meeting',
      calendarId: 'work',
      title: 'Планёрка',
      start: DateTime(2026, 7, 27, 10),
      end: DateTime(2026, 7, 27, 11),
    );
    final week = [
      for (var i = 0; i < 7; i++) DateTime(2026, 7, 27 + i),
    ];

    await pumpScreen(
      tester,
      Scaffold(
        body: WeekView(
          anchor: week.first,
          columns: week.length,
          eventsOf: (day) => day.day == 27 ? [meeting] : const [],
          spans: const [],
          inheritance: inheritance,
          today: DateTime(2026, 7, 27),
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    // Блок недели подписан названием: с новой темой в него влезает и знак,
    // и слово, поэтому тянем за само название.
    final pill = tester.getCenter(find.text('Планёрка'));

    final gesture = await tester.startGesture(pill);
    await tester.pump(const Duration(milliseconds: 700));
    // Вправо на ширину колонки и вниз на час: колонка в неделе узкая,
    // поэтому шаг считается по ней, а не по фиксированному числу.
    await gesture.moveBy(const Offset(48, 34));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(shift, isNotNull);
    expect(shift!.inDays, 1, reason: 'Уехало на соседний день');
    expect(shift!.inMinutes % 60, 0, reason: 'Время примагнитилось к сетке');
  });

  testWidgets('Пилюля соседнего дня подсвечивается, пока в неё метят',
      (tester) async {
    // Наискосок событие уезжает сразу на другой день — и накладка там своя.
    // Видно её должно быть до того, как палец отпустили.
    final meeting = VEvent(
      id: 'meeting',
      calendarId: 'work',
      title: 'Планёрка',
      start: DateTime(2026, 7, 27, 10),
      end: DateTime(2026, 7, 27, 11),
    );
    final standup = VEvent(
      id: 'standup',
      calendarId: 'work',
      title: 'Летучка',
      start: DateTime(2026, 7, 28, 10),
      end: DateTime(2026, 7, 28, 11),
    );
    final week = [
      for (var i = 0; i < 7; i++) DateTime(2026, 7, 27 + i),
    ];

    await pumpScreen(
      tester,
      Scaffold(
        body: WeekView(
          anchor: week.first,
          columns: week.length,
          eventsOf: (day) => switch (day.day) {
            27 => [meeting],
            28 => [standup],
            _ => const [],
          },
          spans: const [],
          inheritance: inheritance,
          today: DateTime(2026, 7, 27),
          onEventMoved: (_, __) {},
        ),
      ),
    );

    final scheme = Theme.of(tester.element(find.byType(WeekView))).colorScheme;

    Color? tintOf(String id) {
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(ValueKey('pill-$id')),
              matching: find.byType(Container),
            )
            .first,
      );
      return (container.decoration as ShapeDecoration?)?.color;
    }

    expect(tintOf('standup'), isNot(scheme.errorContainer));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('pill-meeting'))),
    );
    await tester.pump(const Duration(milliseconds: 700));
    // Ровно на колонку вправо: планёрка встаёт на летучку.
    await gesture.moveBy(const Offset(48, 0));
    await tester.pump(const Duration(milliseconds: 40));

    expect(tintOf('standup'), scheme.errorContainer);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}

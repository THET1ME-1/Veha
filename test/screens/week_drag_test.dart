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
          week: week,
          eventsOf: (day) => day.day == 27 ? [meeting] : const [],
          spans: const [],
          inheritance: inheritance,
          today: DateTime(2026, 7, 27),
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    // Пилюля недели — это иконка календаря в капсуле, названия там нет.
    final pill = tester.getCenter(
      find.byIcon(VehaIcons.byName('groups')).first,
    );

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
}

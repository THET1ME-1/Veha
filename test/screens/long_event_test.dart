import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/clock_view.dart';

import 'golden_harness.dart';

/// Блок события в сетке часов обязан занимать всю длительность: занятие с
/// 12:00 до 16:30 — четыре с половиной часа высоты, а не один.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Длинное событие занимает всю свою высоту', (tester) async {
    final long = VEvent(
      id: 'long',
      calendarId: 'c-study',
      title: 'Съёмка',
      start: DateTime(2026, 7, 27, 12),
      end: DateTime(2026, 7, 27, 16, 30),
    );
    final short = VEvent(
      id: 'short',
      calendarId: 'c-home',
      title: 'Звонок',
      start: DateTime(2026, 7, 27, 18),
      end: DateTime(2026, 7, 27, 19),
    );

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [long, short],
          inheritance: const Inheritance(
            calendars: {
              'c-study': VCalendar(
                id: 'c-study',
                name: 'Учёба',
                iconName: 'school',
                color: Color(0xFF7C3AED),
              ),
              'c-home': VCalendar(
                id: 'c-home',
                name: 'Личное',
                iconName: 'restaurant',
                color: Color(0xFFC2410C),
              ),
            },
            subcategories: {},
          ),
        ),
      ),
    );

    final longBox = tester.getSize(find.ancestor(
      of: find.text('Съёмка'),
      matching: find.byType(Container),
    ).first);
    final shortBox = tester.getSize(find.ancestor(
      of: find.text('Звонок'),
      matching: find.byType(Container),
    ).first);

    expect(
      longBox.height / shortBox.height,
      closeTo(4.5, 0.15),
      reason: 'Четыре с половиной часа против одного',
    );

    await shoot(tester, 'long_event');
  });
}

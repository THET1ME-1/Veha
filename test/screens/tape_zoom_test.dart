import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/tape_view.dart';

import 'golden_harness.dart';

/// Щипок в занятом дне.
///
/// В сетке часов он был всегда, а лента жила своим шагом «минута в точку с
/// небольшим»: у кого день расписан по четвертям, тому нужен крупный шаг, а
/// кому важна вся картина дня — мелкий. Один и тот же жест обязан работать в
/// обоих прочтениях дня.
void main() {
  setUpAll(loadAppFonts);

  Widget tape() => TapeView(
        day: DateTime(2026, 8, 10),
        events: [
          VEvent(
            id: 'lecture',
            calendarId: 'c1',
            title: 'Лекция',
            start: DateTime(2026, 8, 10, 9),
            end: DateTime(2026, 8, 10, 10, 30),
            timezone: 'Europe/Chisinau',
          ),
        ],
        inheritance: const Inheritance(calendars: {}, subcategories: {}),
      );

  double slabHeight(WidgetTester tester) =>
      tester.getSize(find.byKey(const ValueKey('tape-slab-lecture'))).height;

  testWidgets('Щипок растягивает блоки занятого дня', (tester) async {
    await pumpScreen(tester, tape());
    final before = slabHeight(tester);

    // Два пальца разъезжаются по вертикали: тот же жест, что и в сетке часов.
    final top = await tester.startGesture(const Offset(200, 300));
    final bottom = await tester.startGesture(const Offset(200, 420));
    await tester.pump();
    await top.moveBy(const Offset(0, -90));
    await bottom.moveBy(const Offset(0, 90));
    await tester.pump();
    await top.up();
    await bottom.up();
    await tester.pumpAndSettle();

    expect(slabHeight(tester), greaterThan(before));
  });
}

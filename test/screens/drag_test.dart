import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/clock_view.dart';

import 'golden_harness.dart';

/// Жесты в сетке часов: долгое нажатие отрывает блок, движение переносит его
/// шагом в пятнадцать минут, нижний край тянет длительность. Короткий тап при
/// этом обязан остаться тапом — иначе прокрутка дня превратится в переносы.
void main() {
  setUpAll(loadAppFonts);

  const inheritance = Inheritance(
    calendars: {
      'home': VCalendar(
        id: 'home',
        name: 'Личное',
        iconName: 'restaurant',
        color: Color(0xFFC2410C),
      ),
    },
    subcategories: {},
  );

  VEvent lunch() => VEvent(
        id: 'lunch',
        calendarId: 'home',
        title: 'Обед с Ниной',
        start: DateTime(2026, 7, 27, 13),
        end: DateTime(2026, 7, 27, 14),
      );

  testWidgets('Протяжка переносит событие шагом в четверть часа',
      (tester) async {
    Duration? shift;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    // Долгое нажатие: без него жест уходит в прокрутку.
    await tester.pump(const Duration(milliseconds: 700));
    // Высота часа — 60 логических пикселей.
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(shift, const Duration(hours: 1));
  });

  testWidgets('Мелкое движение примагничивается к четверти часа',
      (tester) async {
    Duration? shift;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    await tester.pump(const Duration(milliseconds: 700));
    // Восемнадцать пикселей — это восемнадцать минут; сетка округляет до
    // пятнадцати.
    await gesture.moveBy(const Offset(0, 18));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(shift, const Duration(minutes: 15));
  });

  testWidgets('Короткий тап остаётся тапом', (tester) async {
    var moved = false;
    VEvent? tapped;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          onEventTap: (e) => tapped = e,
          onEventMoved: (_, __) => moved = true,
        ),
      ),
    );

    await tester.tap(find.text('Обед с Ниной'));
    await tester.pumpAndSettle();

    expect(tapped?.id, 'lunch');
    expect(moved, isFalse);
  });
}

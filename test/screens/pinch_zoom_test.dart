import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/settings.dart';
import 'package:veha/features/calendar/views/clock_view.dart';

import 'golden_harness.dart';

/// Щипок двумя пальцами растягивает час по вертикали.
///
/// Жест слушается напрямую, а не заводится распознавателем: тот забирает и
/// одиночное движение, и сетка перестаёт прокручиваться, а блок — таскаться.
/// Поэтому здесь проверяется и то, что масштаб меняется, и то, что одиночный
/// палец его не трогает.
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

  /// Высота блока часа на экране — по ней и видно масштаб.
  double blockHeight(WidgetTester tester) =>
      tester.getSize(find.text('Обед с Ниной')).height > 0
          ? tester
              .getSize(find.ancestor(
                of: find.text('Обед с Ниной'),
                matching: find.byType(Container),
              ).first)
              .height
          : 0;

  testWidgets('Разведение пальцев растягивает сетку', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(events: [lunch()], inheritance: inheritance),
      ),
    );

    final before = blockHeight(tester);
    final center = tester.getCenter(find.byType(ClockView));

    // Два пальца расходятся по вертикали вдвое.
    final one = await tester.startGesture(center - const Offset(0, 40));
    final two = await tester.startGesture(center + const Offset(0, 40));
    await tester.pump();
    await one.moveBy(const Offset(0, -40));
    await two.moveBy(const Offset(0, 40));
    await tester.pump();
    await one.up();
    await two.up();
    await tester.pumpAndSettle();

    expect(blockHeight(tester), greaterThan(before),
        reason: 'щипок не растянул сетку');
  });

  testWidgets('Одним пальцем масштаб не меняется', (tester) async {
    late double zoom;

    await pumpScreen(
      tester,
      Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            zoom = ref.watch(gridZoomProvider);
            return ClockView(events: [lunch()], inheritance: inheritance);
          },
        ),
      ),
    );

    final center = tester.getCenter(find.byType(ClockView));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(zoom, 1.0, reason: 'прокрутка одним пальцем изменила масштаб');
  });
}

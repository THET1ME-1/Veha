import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/calendar/views/week_view.dart';

import 'golden_harness.dart';

/// Лента недели встаёт на день и отзывается на каждый пройденный.
///
/// Свободная прокрутка оставляла половину колонки за краем экрана: день
/// читался обрезанным, и понять, где он начинается, было нельзя.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openWeek(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();
  }

  double columnOf(WidgetTester tester) {
    final view = tester.widget<WeekView>(find.byType(WeekView));
    return (tester.getSize(find.byType(WeekView)).width - 28 - 34) /
        view.columns;
  }

  testWidgets('Остановиться посреди дня нельзя', (tester) async {
    await openWeek(tester);
    final step = columnOf(tester);
    final box = tester.getRect(find.byType(WeekView));

    // Тянем на полтора дня и отпускаем без броска.
    await tester.dragFrom(
      Offset(box.center.dx, box.top + 120),
      Offset(-step * 1.5 - 18, 0),
    );
    await tester.pumpAndSettle();

    // Колонка стоит ровно на границе: левый край первого дня совпадает с
    // началом сетки.
    final anchor = tester.widget<WeekView>(find.byType(WeekView)).anchor;
    final first = find.text(
        '${['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'][anchor.weekday - 1]} ${anchor.day}');
    expect(first, findsOneWidget);

    final left = tester.getRect(first).left;
    final grid = box.left + 14 + 34;
    // Подпись центрируется в своей колонке, поэтому сравниваем с допуском
    // в половину ширины колонки.
    expect((left - grid).abs(), lessThan(step),
        reason: 'лента застряла между днями');
  });

  testWidgets('Каждый пройденный день отзывается щелчком', (tester) async {
    var clicks = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') clicks++;
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await openWeek(tester);
    final step = columnOf(tester);
    final box = tester.getRect(find.byType(WeekView));

    // Палец идёт плавно, а не прыжком: щелчок должен приходить на каждом
    // пройденном дне, а не один раз за жест.
    final gesture =
        await tester.startGesture(Offset(box.center.dx, box.top + 120));
    await gesture.moveBy(const Offset(-18, 0));
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 4; j++) {
        await gesture.moveBy(Offset(-step / 4, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(clicks, greaterThanOrEqualTo(2),
        reason: 'палец не чувствует смену дня');
  });
}

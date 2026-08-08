import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/calendar/views/week_view.dart';

import 'golden_harness.dart';

/// Листание по дням, а не прыжками через период.
///
/// Неделя двигалась только целиком: увидеть конец прошлой недели рядом с
/// началом этой было нельзя — либо одна, либо другая. Теперь колонки живут в
/// бесконечной ленте, и прокрутка на две колонки сдвигает календарь ровно на
/// два дня.
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

  /// Первый видимый день ленты.
  DateTime anchorOf(WidgetTester tester) =>
      tester.widget<WeekView>(find.byType(WeekView)).anchor;

  /// Ширина колонки: лента прокручивается ими. Из ширины вида вычитаются
  /// боковые отступы сетки и колонка часов — остальное делится на колонки.
  double columnOf(WidgetTester tester) {
    final view = tester.widget<WeekView>(find.byType(WeekView));
    final width = tester.getSize(find.byType(WeekView)).width;
    return (width - 28 - 34) / view.columns;
  }

  /// Тянем саму ленту: жест должен начинаться на колонках, а не на часах
  /// слева — там своя область.
  Future<void> dragColumns(WidgetTester tester, double columns) async {
    final box = tester.getRect(find.byType(WeekView));
    // Первые полтора десятка пикселей жеста уходят на порог распознавания —
    // без запаса на него лента едет на колонку меньше.
    const slop = 18.0;
    final delta = columnOf(tester) * columns;
    await tester.dragFrom(
      Offset(box.center.dx, box.top + 120),
      Offset(delta + (delta.isNegative ? -slop : slop), 0),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Прокрутка на две колонки сдвигает неделю на два дня',
      (tester) async {
    await openWeek(tester);
    // Демонстрация собрана на понедельник 27 июля: с него неделя и начинается.
    expect(anchorOf(tester).day, 27);

    await dragColumns(tester, -2);
    await tester.pumpAndSettle();

    // Сдвинулись ровно на два дня, а не на неделю.
    expect(anchorOf(tester).day, 29);
  });

  testWidgets('Одна колонка — один день', (tester) async {
    await openWeek(tester);

    await dragColumns(tester, -1);
    await tester.pumpAndSettle();

    expect(anchorOf(tester).day, 28);
  });

  testWidgets('Лента листается и назад, через границу недели', (tester) async {
    await openWeek(tester);

    await dragColumns(tester, 3);
    await tester.pumpAndSettle();

    // 24 июля — пятница прошлой недели: раньше такого положения не
    // существовало вовсе.
    expect(anchorOf(tester).day, 24);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/calendar_screen.dart';

import 'golden_harness.dart';

/// Перетаскивание блока против листания календаря.
///
/// Оба жеста горизонтальные, и живут они на одном экране: в неделе блок
/// таскают вбок, чтобы перенести занятие на другой день, а тем же движением
/// календарь листается. Разводит их удержание — но проверить это надо на
/// живом экране, а не на отдельной сетке: пейджер стоит выше по дереву и
/// может забрать палец себе.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openView(WidgetTester tester, String name) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  /// В прочтении «цепочка» тащить нечего: это список, а не шкала времени.
  /// Перетаскивание живёт в часах, поэтому переключаемся на них.
  Future<void> openClock(WidgetTester tester) async {
    await openView(tester, 'День');
    await tester.tap(find.byKey(const ValueKey('reading-clock')));
    await tester.pumpAndSettle();
  }

  testWidgets('Неделя: удержание тащит блок, а не листает календарь',
      (tester) async {
    await openView(tester, 'Неделя');
    expect(find.text('пн 27'), findsOneWidget);

    // Берём любой блок недели: подписей у пилюль нет, поэтому ищем по ключу.
    final block = find
        .byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('pill-'))
        .first;
    final gesture = await tester.startGesture(tester.getCenter(block));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveBy(const Offset(50, 0));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    // Календарь остался на месте: жест ушёл блоку, а не листанию.
    expect(find.text('пн 27'), findsOneWidget,
        reason: 'листание перехватило перетаскивание блока');
  });

  testWidgets('День: удержание тащит блок по времени', (tester) async {
    await openClock(tester);

    final block = find.text('Обед с Ниной');
    final gesture = await tester.startGesture(tester.getCenter(block));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    // Полоска о переносе появляется только после состоявшегося переноса.
    expect(find.textContaining('Событие в'), findsOneWidget,
        reason: 'перенос не состоялся');
  });
}

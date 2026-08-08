import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/widgets/week_strip.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Календарь открывался на одном дне и застревал в нём: соседняя неделя была
/// недостижима. Сторож проверяет, что период листается — жестом и кнопкой.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Свайп по календарю листает день', (tester) async {
    await pumpScreen(tester, const HomeShell());

    // Демонстрация собрана на понедельник 27 июля 2026.
    expect(find.text('27'), findsWidgets);

    await tester.fling(
      find.text('Обед с Ниной').first,
      const Offset(-260, 0),
      900,
    );
    await tester.pumpAndSettle();

    // 28-е стало выбранным: в полоске дней оно теперь на месте текущего.
    expect(find.text('28'), findsWidgets);
  });

  testWidgets('Полоса дней листается пальцем в обе стороны', (tester) async {
    await pumpScreen(tester, const HomeShell());

    // Стрелок в полосе больше нет: она листается как мини-календарь.
    final strip = find.byType(WeekStrip);
    expect(strip, findsOneWidget);

    final box = tester.getRect(strip);
    await tester.dragFrom(box.center, Offset(box.width / 7 * 2 + 18, 0));
    await tester.pumpAndSettle();

    // Ушли на два дня назад: суббота и воскресенье прошлой недели.
    expect(find.text('25'), findsWidgets);
  });
}

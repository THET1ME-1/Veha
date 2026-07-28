import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('Кнопка в полоске дней уводит на неделю назад', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byIcon(const IconData(0xe5cb, fontFamily: 'VehaSymbols')));
    await tester.pumpAndSettle();

    // Шаг вида «День» — сутки: 27 июля становится 26-м.
    expect(find.text('26'), findsWidgets);
  });
}

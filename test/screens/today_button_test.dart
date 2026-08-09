import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Возврат на сегодня.
///
/// Календарь листается свайпом, и уехать на полгода вперёд — дело трёх
/// движений пальцем. Обратно тем же способом это полгода движений: нужна
/// кнопка. Пока стоишь на сегодняшнем дне, её нет — она бы ничего не делала.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('На сегодняшнем дне кнопки нет', (tester) async {
    await pumpScreen(tester, const HomeShell());

    expect(find.byKey(const ValueKey('go-today')), findsNothing);
  });

  testWidgets('Уехали с сегодня — кнопка появилась и вернула', (tester) async {
    await pumpScreen(tester, const HomeShell());

    // Листаем вперёд стрелкой: свайп в тесте требует настоящей физики, а
    // ответ на вопрос тот же.
    await tester.tap(find.byKey(const ValueKey('next-period')));
    await tester.pumpAndSettle();

    final today = find.byKey(const ValueKey('go-today'));
    expect(today, findsOneWidget);

    await tester.tap(today);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('go-today')), findsNothing);
  });
}

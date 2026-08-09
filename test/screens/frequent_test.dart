import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Быстрый лист подсказывает то, что человек уже заводил: в демонстрации это
/// планёрки, зарядки и уроки, повторяющиеся неделями.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Подсказка подставляет название и календарь', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byKey(const ValueKey('add-event')));
    await tester.pumpAndSettle();

    // Пока название пустое, лист предлагает частое.
    final hint = find.text('Планёрка');
    expect(hint, findsWidgets);

    await tester.tap(hint.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    // Событие завелось: в дне их стало на одно больше.
    expect(find.text('Планёрка'), findsWidgets);
  });
}

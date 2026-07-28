import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// «Поставь, где влезет»: лист сам находит ближайшее свободное окно нужной
/// длины и переносит туда событие.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Кнопка ставит событие в свободное окно', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Стрижка');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ближайшее окно'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Свободно:'), findsOneWidget,
        reason: 'Календарь ответил, когда именно свободно');
  });
}

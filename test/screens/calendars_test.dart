import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Календари живут в базе: заведение, правка и скрытие идут туда же, откуда
/// виды берут события.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openList(WidgetTester tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
  }

  testWidgets('Снимок списка календарей', (tester) async {
    await openList(tester);
    await shoot(tester, 'calendars');
  });

  testWidgets('Новый календарь появляется в списке', (tester) async {
    await openList(tester);

    await tester.tap(find.text('Новый'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Дача');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    // Новый календарь встаёт последним, а список строит только видимое:
    // без прокрутки его нет в дереве, и проверка врёт про пропажу.
    await tester.scrollUntilVisible(find.text('Дача'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Дача'), findsOneWidget);
  });

  testWidgets('Скрытый календарь уносит события из дня', (tester) async {
    await pumpScreen(tester, const HomeShell());
    expect(find.text('Английский'), findsWidgets);

    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();

    // Тумблер напротив «Учёбы» — второй в списке после «Личного».
    final study = find.ancestor(
      of: find.text('Учёба'),
      matching: find.byType(Row),
    );
    await tester.tap(find.descendant(of: study.first, matching: find.byType(GestureDetector)).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Календарь'));
    await tester.pumpAndSettle();

    expect(find.text('Английский'), findsNothing);
  });
}

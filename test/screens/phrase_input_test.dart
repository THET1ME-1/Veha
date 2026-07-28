import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Быстрый лист понимает строку целиком: день, время и длительность уезжают
/// в чипы, названием остаётся то, что не разобралось.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Фраза раскладывается по чипам', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Созвон завтра в 15:00 на час',
    );
    await tester.pumpAndSettle();

    // Время из строки встало в чипы, а название очистилось от служебных слов.
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('16:00'), findsOneWidget);
    expect(find.textContaining('Понял из строки'), findsOneWidget);

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('Созвон'), findsNothing,
        reason: 'Событие уехало на завтра, сегодня его нет');
  });
}

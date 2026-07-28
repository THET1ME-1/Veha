import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/repeat/repeat_screen.dart';

import 'golden_harness.dart';

/// Правило собирается на экране, а проверяется предпросмотром: ошибку видно
/// сразу, а не через месяц, когда занятие не пришло.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Повторение', (tester) async {
    await pumpScreen(tester, RepeatScreen(from: DateTime(2026, 7, 27)));
    await tester.tap(find.text('По будням'));
    await tester.pumpAndSettle();

    await shoot(tester, 'repeat');
  });

  testWidgets('Пресет «Не повторять» прячет настройки правила', (tester) async {
    await pumpScreen(tester, RepeatScreen(from: DateTime(2026, 7, 27)));

    await tester.tap(find.text('Не повторять'));
    await tester.pumpAndSettle();

    expect(find.text('КОГДА ЗАКАНЧИВАЕТСЯ'), findsNothing);
  });

  testWidgets('Сохранённое правило открывается на своих значениях',
      (tester) async {
    await pumpScreen(
      tester,
      RepeatScreen(
        from: DateTime(2026, 7, 27),
        initial: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH',
      ),
    );

    expect(find.text('2 недели'), findsOneWidget);
    expect(find.text('КОГДА ЗАКАНЧИВАЕТСЯ'), findsOneWidget);
  });
}

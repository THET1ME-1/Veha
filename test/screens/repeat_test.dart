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

    expect(find.text('Каждые 2 недели'), findsOneWidget);
    expect(find.text('КОГДА ЗАКАНЧИВАЕТСЯ'), findsOneWidget);
  });

  testWidgets('Месяц спрашивает, чем меряется: числом, позицией или буднями',
      (tester) async {
    // 27 июля 2026 — понедельник, и до конца месяца понедельников больше нет:
    // позиция считается с конца, потому что пятый понедельник есть не всегда.
    await pumpScreen(tester, RepeatScreen(from: DateTime(2026, 7, 27)));

    // Настройки правила появляются, когда повтор включён.
    await tester.tap(find.text('Каждый день'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Месяц'));
    await tester.pumpAndSettle();

    expect(find.text('27-го числа'), findsOneWidget);
    expect(find.text('Последний понедельник'), findsOneWidget);
    expect(find.text('Последний рабочий день'), findsOneWidget);
  });

  testWidgets('Выбранное правило месяца доживает до ближайших дат',
      (tester) async {
    await pumpScreen(tester, RepeatScreen(from: DateTime(2026, 7, 31)));

    await tester.tap(find.text('Каждый день'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Месяц'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Последний рабочий день'));
    await tester.pumpAndSettle();

    // 31 августа 2026 — понедельник, последний рабочий день месяца.
    expect(find.text('пн 31 авг.'), findsOneWidget);
  });
}

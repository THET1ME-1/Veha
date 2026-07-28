import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Путь события целиком: кнопка → лист → база → карточка в дне.
///
/// Проверять по частям бессмысленно: ломается обычно связка, а не отдельный
/// виджет.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Событие из быстрого листа появляется в дне', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Название'), findsOneWidget,
        reason: 'Лист открылся с пустым названием');

    await tester.enterText(find.byType(TextField), 'Стрижка');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('Стрижка'), findsWidgets,
        reason: 'Событие сохранено и видно в дне');
  });

  testWidgets('Быстрый лист отдаёт черновик полной форме', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Экзамен');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Подробнее'));
    await tester.pumpAndSettle();

    expect(find.text('Экзамен'), findsWidgets,
        reason: 'Набранное название доехало до полной формы');
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('Снимок быстрого листа', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Английский');
    await tester.pumpAndSettle();

    await shoot(tester, 'quick_add');
  });

  testWidgets('Снимок полной формы', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Английский');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подробнее'));
    await tester.pumpAndSettle();

    await shoot(tester, 'event_form');
  });
}

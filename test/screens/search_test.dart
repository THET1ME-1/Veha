import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Поиск целиком: кнопка в шапке → запрос → карточка события.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openSearch(WidgetTester tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.byIcon(VehaIcons.byName('search')).first);
    await tester.pumpAndSettle();
  }

  testWidgets('Кнопка в шапке открывает поиск', (tester) async {
    await openSearch(tester);
    expect(find.text('Найти событие'), findsOneWidget);
  });

  testWidgets('Находит по названию', (tester) async {
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'англ');
    await tester.pumpAndSettle();

    expect(find.text('Английский'), findsWidgets);
  });

  testWidgets('Находит по номеру кабинета', (tester) async {
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), '204-б');
    await tester.pumpAndSettle();

    expect(find.text('Экзамен по грамматике'), findsOneWidget,
        reason: 'Кабинет — своё поле, в названии его нет');
  });

  testWidgets('Пилюля календаря сужает выдачу', (tester) async {
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'а');
    await tester.pumpAndSettle();
    expect(find.text('Планёрка'), findsWidgets);

    // «Учёба» — первая пилюля: оставляем только её.
    await tester.tap(find.text('Учёба'));
    await tester.pumpAndSettle();

    expect(find.text('Планёрка'), findsNothing);
    expect(find.text('Английский'), findsWidgets);
  });

  testWidgets('Снимок поиска', (tester) async {
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'бассейн');
    await tester.pumpAndSettle();

    await shoot(tester, 'search');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Широкий экран — не увеличенный телефон.
///
/// В браузере и на планшете четыре вкладки внизу читаются как ошибка вёрстки:
/// палец до них не идёт, а мышь — тем более. Навигация переезжает в рельсу,
/// содержимое перестаёт растягиваться на всю ширину монитора.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('На телефоне навигация остаётся внизу', (tester) async {
    await pumpScreen(tester, const HomeShell());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('На широком экране навигация уходит в рельсу', (tester) async {
    await pumpScreen(tester, const HomeShell(), size: const Size(1280, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Содержимое не растягивается во всю ширину монитора',
      (tester) async {
    await pumpScreen(tester, const HomeShell(), size: const Size(1600, 900));

    final content = tester.getRect(find.byKey(const ValueKey('shell-content')));
    expect(content.width, lessThanOrEqualTo(1100));
  });

  testWidgets('Раздел переключается и в рельсе', (tester) async {
    await pumpScreen(tester, const HomeShell(), size: const Size(1280, 900));

    await tester.tap(find.text('Настройки').first);
    await tester.pumpAndSettle();

    expect(find.text('ОФОРМЛЕНИЕ'), findsOneWidget);
  });

  testWidgets('Снимок широкого экрана', (tester) async {
    await pumpScreen(tester, const HomeShell(), size: const Size(1280, 900));
    await shoot(tester, 'wide_calendar');
  });
}

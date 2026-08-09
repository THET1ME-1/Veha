import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/widgets/view_switcher.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Широкий экран — не увеличенный телефон.
///
/// Разделов внизу больше нет: там переключатель видов, и он одинаков на
/// телефоне и на мониторе. Меняется одно — содержимое перестаёт растягиваться
/// на всю ширину, иначе строка календаря становится нечитаемой.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Переключатель видов стоит внизу на любом экране', (tester) async {
    await pumpScreen(tester, const HomeShell());
    expect(find.byType(ViewDock), findsOneWidget);

    await pumpScreen(tester, const HomeShell(), size: const Size(1280, 900));
    expect(find.byType(ViewDock), findsOneWidget);
  });

  testWidgets('Содержимое не растягивается во всю ширину монитора',
      (tester) async {
    await pumpScreen(tester, const HomeShell(), size: const Size(1600, 900));

    // Док живёт внутри ограниченной колонки и повторяет её ширину.
    expect(
      tester.getSize(find.byType(ViewDock)).width,
      lessThanOrEqualTo(HomeShell.contentMax),
    );
  });
}

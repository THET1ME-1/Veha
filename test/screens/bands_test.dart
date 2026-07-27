import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Дни лентами, светлая', (tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.text('Дни'));
    await tester.pumpAndSettle();
    await shoot(tester, 'bands_light');
  });

  testWidgets('Дни лентами, тёмная', (tester) async {
    await pumpScreen(tester, const HomeShell(), brightness: Brightness.dark);
    await tester.tap(find.text('Дни'));
    await tester.pumpAndSettle();
    await shoot(tester, 'bands_dark');
  });
}

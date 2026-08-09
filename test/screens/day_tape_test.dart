import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// День лентой: высота блока равна длительности, окна между делами подписаны.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('День · лента, светлая', (tester) async {
    await pumpScreen(tester, const HomeShell());
    await shoot(tester, 'day_tape_light');
  });

  testWidgets('День · лента, тёмная', (tester) async {
    await pumpScreen(tester, const HomeShell(), brightness: Brightness.dark);
    await shoot(tester, 'day_tape_dark');
  });
}

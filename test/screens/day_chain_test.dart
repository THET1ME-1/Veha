import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('День · цепочка, светлая', (tester) async {
    await pumpScreen(tester, const HomeShell());
    await shoot(tester, 'day_chain_light');
  });

  testWidgets('День · цепочка, тёмная', (tester) async {
    await pumpScreen(tester, const HomeShell(), brightness: Brightness.dark);
    await shoot(tester, 'day_chain_dark');
  });
}

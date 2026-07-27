import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Неделя, тёмная', (tester) async {
    await pumpScreen(tester, const HomeShell(), brightness: Brightness.dark);
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();
    await shoot(tester, 'week_dark');
  });
}

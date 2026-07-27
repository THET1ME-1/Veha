import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/repeat/repeat_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Повторение', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(body: SafeArea(child: RepeatScreen(from: DateTime(2026, 7, 27)))),
    );
    await shoot(tester, 'repeat');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/views/month_view.dart';
import 'package:veha/data/seed.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, name) in const [
    (MonthMode.chips, 'chips'),
    (MonthMode.icons, 'icons'),
    (MonthMode.tint, 'tint'),
  ]) {
    testWidgets('Месяц · $name', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: SafeArea(
            child: MonthView(
              month: Seed.today,
              eventsOf: Seed.eventsOn,
              spans: Seed.spans,
              inheritance: Seed.inheritance,
              today: Seed.today,
              mode: mode,
            ),
          ),
        ),
      );
      await shoot(tester, 'month_$name');
    });
  }
}

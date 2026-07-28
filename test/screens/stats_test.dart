import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/stats/stats_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Итоги за неделю', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: StatsScreen())),
      seed: (repo) async {
        await repo.upsertTask(VTask(
          id: 't1',
          calendarId: 'c-home',
          title: 'Записаться к врачу',
          completedAt: testNow.subtract(const Duration(hours: 5)),
        ));
      },
    );
    await shoot(tester, 'stats');
  });
}

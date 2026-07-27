import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/event/event_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Событие целиком', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: EventScreen(
            event: Seed.dayEvents.firstWhere((e) => e.id == 'e-eng'),
            inheritance: Seed.inheritance,
          ),
        ),
      ),
    );
    await shoot(tester, 'event_full');
  });

  testWidgets('Событие с заметками', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: EventScreen(
            event: Seed.exam,
            inheritance: Seed.inheritance,
            notes: Seed.examNotes,
          ),
        ),
      ),
    );
    await shoot(tester, 'event_notes');
  });

  testWidgets('Абонемент на 30 дней', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: EventScreen(
            event: Seed.spans.first,
            inheritance: Seed.inheritance,
            today: Seed.today,
          ),
        ),
      ),
    );
    await shoot(tester, 'event_pass');
  });
}

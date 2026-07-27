import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/fields/fields_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Поля по группам', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(child: FieldGroupsScreen(inheritance: Seed.inheritance)),
      ),
    );
    await shoot(tester, 'fields_groups');
  });

  testWidgets('Поля группы «Учёба»', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: FieldsOfGroupScreen(
            calendar: Seed.calendars.firstWhere((c) => c.id == 'c-study'),
          ),
        ),
      ),
    );
    await shoot(tester, 'fields_study');
  });
}

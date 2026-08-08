import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/draft.dart';
import 'package:veha/features/event/quick_add_sheet.dart';

import 'golden_harness.dart';

/// Правило, названное словами в быстром листе, доходит до события.
///
/// Разбор строки жил отдельно от формы: «английский каждый вторник»
/// раскладывался в правило, а на сохранение уходило разовое занятие.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('«Каждый вторник» из строки становится правилом события',
      (tester) async {
    EventDraft? saved;

    await pumpScreen(
      tester,
      Scaffold(
        body: QuickAddSheet(
          draft: EventDraft.at(
            DateTime(2026, 7, 27, 10),
            calendarId: 'default',
          ),
          inheritance: const Inheritance(calendars: {}, subcategories: {}),
          onSave: (draft) => saved = draft,
          onDetails: (_) {},
        ),
      ),
    );

    await tester.enterText(
        find.byType(TextField).first, 'английский каждый вторник в 16:00');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.title, 'английский');
    expect(saved!.rrule, contains('BYDAY=TU'));
    expect(saved!.start.day, 28, reason: 'ближайший вторник, а не понедельник');
    expect(saved!.start.hour, 16);
  });
}

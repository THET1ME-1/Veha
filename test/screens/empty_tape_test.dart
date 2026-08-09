import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/features/calendar/views/clock_view.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Свободный день в ленте.
///
/// Раньше он говорил «День свободен» и на этом заканчивался: текст посреди
/// экрана не отвечает на вопрос «куда ткнуть, чтобы завести дело в три часа»,
/// а вместе с текстом уходил и щипок, растягивающий час. Теперь свободный день
/// показывает те же часовые блоки, что и сетка: пустые, но нажимаемые.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openEmptyTape(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const HomeShell(),
      seed: (repo) async {
        await repo.db.update(repo.db.events).write(
              EventsCompanion(deletedAt: Value(testNow.millisecondsSinceEpoch)),
            );
      },
    );
    await tester.tap(find.byKey(const ValueKey('reading-tape')));
    await tester.pumpAndSettle();
  }

  testWidgets('Свободный день показывает часы, а не надпись', (tester) async {
    await openEmptyTape(tester);

    expect(find.text('День свободен'), findsNothing);
    expect(find.byType(ClockView), findsOneWidget);
    // Часовые засечки: сетка рисует окно, даже когда дел нет.
    expect(find.text('09:00'), findsWidgets);
  });
}

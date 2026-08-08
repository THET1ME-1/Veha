import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/features/calendar/views/week_view.dart';
import 'package:veha/features/calendar/widgets/week_strip.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Тап по свободному месту колонки уводит в день.
///
/// Неделя отвечает на вопрос «когда», подробности живут в дне — и дорога
/// туда должна быть под пальцем, а не через переключатель видов.
void main() {
  setUpAll(loadAppFonts);

  /// Неделя без единого события: свободное место есть в любой колонке.
  Future<void> openEmptyWeek(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const HomeShell(),
      seed: (repo) async {
        await repo.db.update(repo.db.events).write(
              EventsCompanion(deletedAt: Value(testNow.millisecondsSinceEpoch)),
            );
      },
    );
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();
  }

  /// Середина колонки нужного дня. Колонки лежат лентой, первая — понедельник.
  Offset columnCenter(WidgetTester tester, int index) {
    final view = tester.getRect(find.byType(WeekView));
    const gutter = 34.0;
    final width = (view.width - 28 - gutter) / 7;
    return Offset(
      view.left + 14 + gutter + width * (index + 0.5),
      view.top + 220,
    );
  }

  testWidgets('Тап по свободному месту колонки открывает её день',
      (tester) async {
    await openEmptyWeek(tester);

    // Третья колонка ленты — среда 29 июля.
    await tester.tapAt(columnCenter(tester, 2));
    await tester.pumpAndSettle();

    expect(find.byType(WeekView), findsNothing, reason: 'Ушли из недели');
    expect(tester.widget<WeekStrip>(find.byType(WeekStrip)).selected.day, 29,
        reason: 'И встали ровно на тот день, по которому тапнули');
  });

  testWidgets('Тап по событию открывает событие, а не день', (tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();

    // Пилюли недели подписаны одной иконкой: ищем их по ключу.
    final pill = find.byWidgetPredicate((w) {
      final key = w.key;
      return key is ValueKey<String> && key.value.startsWith('pill-');
    });
    await tester.tap(pill.first);
    await tester.pumpAndSettle();

    expect(find.byType(WeekView), findsOneWidget,
        reason: 'Неделя на месте: тап по занятию открывает карточку');
  });
}

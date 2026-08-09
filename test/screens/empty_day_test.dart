import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/tape_view.dart';
import 'package:veha/features/calendar/widgets/week_strip.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// День без единого занятия.
///
/// Часы рисовались от первого события до последнего, а на пустом дне не
/// рисовались вовсе: вместо шкалы оставалась пустота нулевой высоты. Вместе с
/// сеткой пропадал и свайп — уйдя в свободный день, вернуться было нельзя.
void main() {
  setUpAll(loadAppFonts);

  DateTime selectedOf(WidgetTester tester) =>
      tester.widget<WeekStrip>(find.byType(WeekStrip)).selected;

  /// Календарь без единого события: демонстрацию стираем целиком.
  Future<void> openEmptyClock(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const HomeShell(),
      seed: (repo) async {
        await repo.db.update(repo.db.events).write(
              EventsCompanion(deletedAt: Value(testNow.millisecondsSinceEpoch)),
            );
      },
    );
    await tester.tap(find.byKey(const ValueKey('reading-clock')));
    await tester.pumpAndSettle();
  }

  /// Свайп по сетке дня — там, где на занятом дне стоят блоки.
  Future<void> swipeGrid(WidgetTester tester, double dx) async {
    final box = tester.getRect(find.byType(WeekStrip));
    await tester.flingFrom(
      Offset(box.center.dx, box.bottom + 260),
      Offset(dx, 0),
      900,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Свободный день листается пальцем в обе стороны',
      (tester) async {
    await openEmptyClock(tester);
    expect(selectedOf(tester).day, 27);

    await swipeGrid(tester, -260);
    expect(selectedOf(tester).day, 28,
        reason: 'Из свободного дня есть дорога вперёд');

    await swipeGrid(tester, 260);
    expect(selectedOf(tester).day, 27,
        reason: 'И обратно: свободный день не запирает календарь');
  });

  testWidgets('Часы свободного дня показывают шкалу, а не пустоту',
      (tester) async {
    await openEmptyClock(tester);

    expect(find.text('09:00'), findsOneWidget,
        reason: 'Шкала стоит на месте: по ней и заводят первое занятие');
    await shoot(tester, 'day_clock_empty');
  });

  testWidgets('Лента свободного дня говорит, что он свободен',
      (tester) async {
    await pumpScreen(
      tester,
      const HomeShell(),
      seed: (repo) async {
        await repo.db.update(repo.db.events).write(
              EventsCompanion(deletedAt: Value(testNow.millisecondsSinceEpoch)),
            );
      },
    );

    expect(find.text('День свободен'), findsOneWidget);

    await swipeGrid(tester, -260);
    expect(selectedOf(tester).day, 28,
        reason: 'И листается так же, как занятый');
  });

  testWidgets('Занятие, пережившее свой ряд, удаляется из карточки',
      (tester) async {
    await pumpScreen(
      tester,
      const HomeShell(),
      seed: (repo) async {
        await repo.db.update(repo.db.events).write(
              EventsCompanion(deletedAt: Value(testNow.millisecondsSinceEpoch)),
            );
        // Так они и остались у людей: ряд удалили, а выломанное из него
        // занятие уцелело и ссылается на запись, которой больше нет.
        await repo.upsertEvent(VEvent(
          id: 'orphan',
          calendarId: 'c-study',
          title: 'English',
          start: DateTime(2026, 7, 27, 15),
          end: DateTime(2026, 7, 27, 16),
          recurrenceId: 'умерший-ряд',
          originalStart: DateTime(2026, 7, 27, 15),
        ));
      },
    );

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Что удалить'), findsNothing,
        reason: 'Спрашивать не о чем: ряда, к которому относился вопрос, нет');
    expect(find.text('English'), findsNothing,
        reason: 'Занятие ушло, а не осталось неудаляемым');
  });

  testWidgets('Иконка занятия стоит слева от названия', (tester) async {
    await pumpScreen(tester, const HomeShell());

    final icon = find.descendant(
      of: find.byType(TapeView),
      matching: find.byIcon(VehaIcons.byName('school')),
    );
    expect(icon, findsWidgets);

    // Лента подписывает блок строкой: знак, имя, время. Знак обязан стоять
    // левее имени, иначе строка читается задом наперёд.
    final title = find.descendant(
      of: find.byType(TapeView),
      matching: find.text('Урок'),
    );
    expect(title, findsWidgets);
    expect(
      tester.getCenter(icon.first).dx,
      lessThan(tester.getCenter(title.first).dx),
      reason: 'Знак занятия стоит перед названием',
    );
  });
}

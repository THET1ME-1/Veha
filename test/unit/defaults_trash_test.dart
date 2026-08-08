import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/draft.dart';

import 'sqlite_for_tests.dart';

/// Значения по умолчанию у календаря и корзина: удалённое должно возвращаться,
/// а «Учёба» — предупреждать за день, не спрашивая об этом каждый раз.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
  });

  tearDown(() => db.close());

  test('Календарь помнит напоминания и длительность', () async {
    await repo.upsertCalendar(const VCalendar(
      id: 'study',
      name: 'Учёба',
      iconName: 'school',
      color: Color(0xFF7C3AED),
      defaultReminders: [1440, 30],
      defaultDuration: Duration(minutes: 90),
    ));

    final inheritance = await repo.loadInheritance();
    final study = inheritance.calendars['study']!;

    expect(study.defaultReminders, [1440, 30]);
    expect(study.defaultDuration, const Duration(minutes: 90));
  });

  test('Новое событие наследует значения календаря', () async {
    const study = VCalendar(
      id: 'study',
      name: 'Учёба',
      iconName: 'school',
      color: Color(0xFF7C3AED),
      defaultReminders: [1440],
      defaultDuration: Duration(minutes: 90),
    );

    final draft = EventDraft.at(
      DateTime(2026, 7, 27, 16),
      calendarId: 'study',
      defaults: study,
    );

    expect(draft.reminders, [1440]);
    expect(draft.end, DateTime(2026, 7, 27, 17, 30));
  });

  test('Календарь без своих значений даёт час и напоминание за полчаса', () {
    final draft = EventDraft.at(DateTime(2026, 7, 27, 16), calendarId: 'x');
    expect(draft.reminders, [30]);
    expect(draft.end, DateTime(2026, 7, 27, 17));
  });

  test('Удалённое попадает в корзину и возвращается', () async {
    await repo.upsertEvent(VEvent(
      id: 'e1',
      calendarId: 'default',
      title: 'Ошибочно удалённое',
      start: DateTime(2026, 7, 27, 10),
      end: DateTime(2026, 7, 27, 11),
    ));
    await repo.deleteEvent('e1');

    final trash = await repo.deletedEvents();
    expect(trash.single.title, 'Ошибочно удалённое');

    await repo.restoreEvent('e1');
    expect(await repo.deletedEvents(), isEmpty);

    final day = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    expect(day.map((e) => e.id), contains('e1'));
  });

  test('Задачи в корзине тоже лежат и возвращаются', () async {
    await repo.upsertTask(const VTask(
      id: 't1',
      calendarId: 'default',
      title: 'Убрать лишнее',
    ));
    await repo.deleteTask('t1');

    expect((await repo.deletedTasks()).single.title, 'Убрать лишнее');

    await repo.restoreTask('t1');
    expect(await repo.deletedTasks(), isEmpty);
  });

  test('Очистка корзины убирает записи насовсем', () async {
    await repo.upsertEvent(VEvent(
      id: 'e2',
      calendarId: 'default',
      title: 'Совсем ненужное',
      start: DateTime(2026, 7, 27, 10),
      end: DateTime(2026, 7, 27, 11),
    ));
    await repo.deleteEvent('e2');

    final removed = await repo.emptyTrash();
    expect(removed, 1);
    expect(await repo.deletedEvents(), isEmpty);
  });
}

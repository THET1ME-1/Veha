import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';

import 'sqlite_for_tests.dart';

void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
  });

  tearDown(() => db.close());

  test('Первый запуск наполняет базу и повторный не дублирует', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final first = await db.select(db.events).get();
    expect(first, isNotEmpty);

    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final second = await db.select(db.events).get();
    expect(second.length, first.length);
  });

  test('Демо-данные ложатся на день первого запуска', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 9, 15));

    final events = await repo
        .watchRange(DateTime(2026, 9, 15), DateTime(2026, 9, 16))
        .first;

    expect(events.map((e) => e.title), contains('Планёрка'));
    expect(events.firstWhere((e) => e.title == 'Планёрка').start,
        DateTime(2026, 9, 15, 10));
  });

  test('Цепочка наследования собирается из базы', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final inheritance = await repo.loadInheritance();

    final exam = inheritance.subcategories['s-exam']!;
    final english = inheritance.subcategories['s-eng']!;

    // У «Экзаменов» свой цвет, у «Английского» — унаследованный от «Учёбы».
    expect(inheritance.subcategoryHasOwnColor(exam), isTrue);
    expect(inheritance.subcategoryHasOwnColor(english), isFalse);
    expect(
      inheritance.colorOfSubcategory(english),
      inheritance.calendars['c-study']!.color,
    );
  });

  test('События за период приходят со своими полями', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;

    // «Английский» повторяется, поэтому из базы приходит экземпляром: свой
    // ключ, ссылка на ряд в `recurrenceId`.
    final english = events.firstWhere((e) => e.recurrenceId == 'e-eng');
    expect(english.fields.map((f) => f.fieldId), containsAll(['f-room', 'f-teacher']));
  });

  test('Ежедневный ряд виден в дни, где своей строки в базе нет', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final events = await repo
        .watchRange(DateTime(2026, 7, 30), DateTime(2026, 7, 31))
        .first;

    final wake = events.firstWhere((e) => e.title == 'Подъём');
    expect(wake.start, DateTime(2026, 7, 30, 7, 30));
    expect(wake.recurrenceId, 'e-wake', reason: 'Экземпляр помнит свой ряд');
  });

  test('Отменённое занятие исчезает, а ряд идёт дальше', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.skipOccurrence('e-wake', DateTime(2026, 7, 30, 7, 30));

    final skipped = await repo
        .watchRange(DateTime(2026, 7, 30), DateTime(2026, 7, 31))
        .first;
    expect(skipped.where((e) => e.title == 'Подъём'), isEmpty);

    final nextDay = await repo
        .watchRange(DateTime(2026, 7, 31), DateTime(2026, 8, 1))
        .first;
    expect(nextDay.where((e) => e.title == 'Подъём'), hasLength(1));
  });

  test('Перенос одного занятия не трогает остальной ряд', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final day = await repo
        .watchRange(DateTime(2026, 7, 30), DateTime(2026, 7, 31))
        .first;
    final wake = day.firstWhere((e) => e.title == 'Подъём');

    await repo.upsertEvent(wake.copyWith(
      start: DateTime(2026, 7, 30, 9),
      end: DateTime(2026, 7, 30, 9, 15),
    ));

    final moved = await repo
        .watchRange(DateTime(2026, 7, 30), DateTime(2026, 7, 31))
        .first;
    final movedWake = moved.singleWhere((e) => e.title == 'Подъём');
    expect(movedWake.start, DateTime(2026, 7, 30, 9),
        reason: 'Перенесённое занятие стоит на новом времени и в одиночестве');

    final nextDay = await repo
        .watchRange(DateTime(2026, 7, 31), DateTime(2026, 8, 1))
        .first;
    expect(nextDay.singleWhere((e) => e.title == 'Подъём').start,
        DateTime(2026, 7, 31, 7, 30),
        reason: 'Соседние дни ряда остались на своём времени');
  });

  test('Удаление мягкое и попадает в очередь синхронизации', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.deleteEvent('e-eng');

    final row = await (db.select(db.events)..where((t) => t.id.equals('e-eng')))
        .getSingle();
    expect(row.deletedAt, isNotNull, reason: 'Строка должна остаться в базе');

    final queue = await db.select(db.syncQueue).get();
    expect(queue.where((q) => q.entityId == 'e-eng' && q.operation == 'delete'),
        hasLength(1));
  });

  test('Повторные правки схлопываются в одну запись очереди', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    // Разовое событие: у экземпляра ряда своя история правок.
    final e = events.firstWhere((x) => x.id == 'e-breakfast');

    await repo.upsertEvent(e);
    await repo.upsertEvent(e);
    await repo.upsertEvent(e);

    final queue = await db.select(db.syncQueue).get();
    expect(queue.where((q) => q.entityId == 'e-breakfast'), hasLength(1));
  });
}

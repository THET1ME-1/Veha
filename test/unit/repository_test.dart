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

  test('первый запуск наполняет базу и повторный не дублирует', () async {
    await repo.seedIfEmpty();
    final first = await db.select(db.events).get();
    expect(first, isNotEmpty);

    await repo.seedIfEmpty();
    final second = await db.select(db.events).get();
    expect(second.length, first.length);
  });

  test('цепочка наследования собирается из базы', () async {
    await repo.seedIfEmpty();
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

  test('события за период приходят со своими полями', () async {
    await repo.seedIfEmpty();
    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;

    final english = events.firstWhere((e) => e.id == 'e-eng');
    expect(english.fields.map((f) => f.fieldId), containsAll(['f-room', 'f-teacher']));
  });

  test('удаление мягкое и попадает в очередь синхронизации', () async {
    await repo.seedIfEmpty();
    await repo.deleteEvent('e-eng');

    final row = await (db.select(db.events)..where((t) => t.id.equals('e-eng')))
        .getSingle();
    expect(row.deletedAt, isNotNull, reason: 'строка должна остаться в базе');

    final queue = await db.select(db.syncQueue).get();
    expect(queue.where((q) => q.entityId == 'e-eng' && q.operation == 'delete'),
        hasLength(1));
  });

  test('повторные правки схлопываются в одну запись очереди', () async {
    await repo.seedIfEmpty();
    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    final e = events.firstWhere((x) => x.id == 'e-eng');

    await repo.upsertEvent(e);
    await repo.upsertEvent(e);
    await repo.upsertEvent(e);

    final queue = await db.select(db.syncQueue).get();
    expect(queue.where((q) => q.entityId == 'e-eng'), hasLength(1));
  });
}

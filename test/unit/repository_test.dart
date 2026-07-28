import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
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

  // Порядок задан руками в демо-данных. Без него SQLite возвращает ветки как
  // ляжет, и список тасуется сам по себе от правки к правке.
  test('Ветки идут в заданном порядке', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    List<String> namesOf(Inheritance inh, String calendarId) => inh
        .subcategories.values
        .where((s) => s.calendarId == calendarId)
        .map((s) => s.name)
        .toList();

    final loaded = await repo.loadInheritance();
    final watched = await repo.watchInheritance().first;

    expect(namesOf(loaded, 'c-study'), ['Английский', 'Экзамены', 'Курсы']);
    expect(namesOf(watched, 'c-study'), ['Английский', 'Экзамены', 'Курсы']);
    expect(namesOf(watched, 'c-sport'), ['Бассейн', 'Зал']);
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

  test('Возврат отменённого занятия ставит его на место', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.skipOccurrence('e-wake', DateTime(2026, 7, 30, 7, 30));
    await repo.unskipOccurrence('e-wake', DateTime(2026, 7, 30, 7, 30));

    final events = await repo
        .watchRange(DateTime(2026, 7, 30), DateTime(2026, 7, 31))
        .first;
    expect(events.where((e) => e.title == 'Подъём'), hasLength(1));
  });

  test('Правка «это и следующие» разрезает ряд по дате', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final day = await repo
        .watchRange(DateTime(2026, 8, 3), DateTime(2026, 8, 4))
        .first;
    final wake = day.firstWhere((e) => e.title == 'Подъём');

    await repo.updateFromOccurrence(
      wake.copyWith(
        start: DateTime(2026, 8, 3, 9),
        end: DateTime(2026, 8, 3, 9, 15),
      ),
    );

    final before = await repo
        .watchRange(DateTime(2026, 8, 1), DateTime(2026, 8, 2))
        .first;
    expect(before.singleWhere((e) => e.title == 'Подъём').start,
        DateTime(2026, 8, 1, 7, 30),
        reason: 'Прошедшие занятия ряд не двигает');

    final after = await repo
        .watchRange(DateTime(2026, 8, 5), DateTime(2026, 8, 6))
        .first;
    expect(after.singleWhere((e) => e.title == 'Подъём').start,
        DateTime(2026, 8, 5, 9),
        reason: 'Начиная с разреза занятия идут по новому времени');
  });

  test('Правка «весь ряд» переносит и прошедшие занятия', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    final day = await repo
        .watchRange(DateTime(2026, 7, 30), DateTime(2026, 7, 31))
        .first;
    final wake = day.firstWhere((e) => e.title == 'Подъём');

    await repo.updateWholeSeries(wake.copyWith(
      title: 'Подъём пораньше',
      start: DateTime(2026, 7, 30, 6, 45),
      end: DateTime(2026, 7, 30, 7),
    ));

    final first = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    final moved = first.singleWhere((e) => e.title == 'Подъём пораньше');
    expect(moved.start, DateTime(2026, 7, 27, 6, 45));
    expect(moved.end, DateTime(2026, 7, 27, 7));

    final later = await repo
        .watchRange(DateTime(2026, 8, 5), DateTime(2026, 8, 6))
        .first;
    expect(later.singleWhere((e) => e.title == 'Подъём пораньше').start,
        DateTime(2026, 8, 5, 6, 45));
  });

  test('Новый календарь появляется в цепочке наследования', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    await repo.upsertCalendar(VCalendar(
      id: id,
      name: 'Дача',
      iconName: 'pets',
      color: const Color(0xFF7C5800),
    ));

    final inheritance = await repo.loadInheritance();
    expect(inheritance.calendars[id]?.name, 'Дача');
  });

  test('Скрытый календарь пропадает из видов, но остаётся в списке', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.setCalendarVisible('c-study', false);

    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    expect(events.where((e) => e.calendarId == 'c-study'), isEmpty);

    final inheritance = await repo.loadInheritance();
    expect(inheritance.calendars['c-study']?.isVisible, isFalse);
  });

  test('Удалённый календарь уносит свои события', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.deleteCalendar('c-study');

    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    expect(events.where((e) => e.calendarId == 'c-study'), isEmpty);

    final inheritance = await repo.loadInheritance();
    expect(inheritance.calendars.containsKey('c-study'), isFalse);
    expect(inheritance.subcategories.values.where((s) => s.calendarId == 'c-study'),
        isEmpty);
  });

  test('Ветка заводится внутри календаря', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    await repo.upsertSubcategory(VSubcategory(
      id: id,
      calendarId: 'c-study',
      name: 'Курсы',
    ));

    final inheritance = await repo.loadInheritance();
    expect(inheritance.subcategories[id]?.name, 'Курсы');
    // Своего цвета нет — берётся от календаря.
    expect(inheritance.colorOfSubcategory(inheritance.subcategories[id]!),
        inheritance.calendars['c-study']!.color);
  });

  // Мягкое удаление копится вечно: без чистки база растёт на каждой правке,
  // а сервер по возвращении привезёт удалённое обратно.
  test('Чистка убирает давно удалённое и не трогает свежее', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.deleteEvent('e-eng');

    final long = DateTime.now()
        .subtract(const Duration(days: 100))
        .millisecondsSinceEpoch;
    await (db.update(db.events)..where((t) => t.id.equals('e-pool')))
        .write(EventsCompanion(deletedAt: Value(long)));

    final removed = await repo.purgeDeleted();

    final left = (await db.select(db.events).get()).map((e) => e.id);
    expect(removed, 1);
    expect(left, contains('e-eng'), reason: 'Удалили только что — рано');
    expect(left, isNot(contains('e-pool')), reason: 'Лежит сто дней');
  });

  test('Значения своих полей сохраняются вместе с событием', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    await repo.upsertEvent(VEvent(
      id: id,
      calendarId: 'c-study',
      title: 'Зачёт',
      start: DateTime(2026, 7, 28, 10),
      end: DateTime(2026, 7, 28, 11),
      fields: const [
        VFieldValue(fieldId: 'f-room', value: '311'),
        VFieldValue(fieldId: 'f-teacher', value: 'Мария Л.'),
      ],
    ));

    final saved = await _eventById(repo, id, DateTime(2026, 7, 28));
    expect(
      {for (final f in saved.fields) f.fieldId: f.value},
      {'f-room': '311', 'f-teacher': 'Мария Л.'},
    );
  });

  test('Стёртое значение поля уходит из события', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    final base = VEvent(
      id: id,
      calendarId: 'c-study',
      title: 'Зачёт',
      start: DateTime(2026, 7, 28, 10),
      end: DateTime(2026, 7, 28, 11),
      fields: const [VFieldValue(fieldId: 'f-room', value: '311')],
    );
    await repo.upsertEvent(base);
    await repo.upsertEvent(base.copyWith(fields: const []));

    final saved = await _eventById(repo, id, DateTime(2026, 7, 28));
    expect(saved.fields, isEmpty);
  });

  test('Напоминания сохраняются вместе с событием', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    await repo.upsertEvent(VEvent(
      id: id,
      calendarId: 'c-study',
      title: 'Зачёт',
      start: DateTime(2026, 7, 28, 10),
      end: DateTime(2026, 7, 28, 11),
      reminders: const [60, 10],
    ));

    final saved = await _eventById(repo, id, DateTime(2026, 7, 28));
    expect(saved.reminders, [60, 10]);
  });

  test('Правка переписывает набор напоминаний, а не добавляет второй', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    final base = VEvent(
      id: id,
      calendarId: 'c-study',
      title: 'Зачёт',
      start: DateTime(2026, 7, 28, 10),
      end: DateTime(2026, 7, 28, 11),
      reminders: const [60, 10],
    );
    await repo.upsertEvent(base);
    await repo.upsertEvent(base.copyWith(reminders: const [5]));

    final saved = await _eventById(repo, id, DateTime(2026, 7, 28));
    expect(saved.reminders, [5]);
  });

  test('Занятия ряда наследуют напоминания ряда', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    await repo.upsertEvent(VEvent(
      id: id,
      calendarId: 'c-study',
      title: 'Английский',
      start: DateTime(2026, 7, 27, 16),
      end: DateTime(2026, 7, 27, 17),
      rrule: 'FREQ=DAILY',
      reminders: const [30],
    ));

    final week = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 8, 3))
        .first;
    // Именно по ряду, а не по названию: «Английский» есть и в демо-данных.
    final instances = week.where((e) => e.recurrenceId == id).toList();

    expect(instances.length, greaterThan(3));
    expect(instances.every((e) => e.reminders.contains(30)), isTrue);
  });

  test('Своё поле заводится в группе календаря', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final id = repo.newId();
    await repo.upsertFieldDef(VFieldDef(
      id: id,
      name: 'Кабинет',
      type: VFieldType.text,
      iconName: 'door',
      calendarId: 'c-sport',
    ));

    final sport = await repo.fieldsFor('c-sport');
    expect(sport.where((f) => f.id == id).single.name, 'Кабинет');

    // Поле принадлежит группе: в соседнем календаре его быть не должно.
    final study = await repo.fieldsFor('c-study');
    expect(study.where((f) => f.id == id), isEmpty);
  });

  test('Видимость поля в карточке переключается', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    Future<bool> shownOf(String id) async =>
        (await repo.fieldsFor('c-study')).firstWhere((f) => f.id == id).showInCard;

    expect(await shownOf('f-pass'), isFalse);
    await repo.setFieldShownInCard('f-pass', true);
    expect(await shownOf('f-pass'), isTrue);
  });

  test('Удалённое поле уходит из группы, а правка ложится в очередь', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.deleteFieldDef('f-room');

    final study = await repo.fieldsFor('c-study');
    expect(study.where((f) => f.id == 'f-room'), isEmpty);

    final queue = await db.select(db.syncQueue).get();
    expect(
      queue.where((q) => q.entityType == 'field' && q.entityId == 'f-room').single.operation,
      'delete',
    );
  });

  test('Поток полей просыпается на правку', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    final seen = <int>[];
    final sub = repo.watchFieldDefs().listen((f) => seen.add(f.length));
    await pumpEventQueue();

    await repo.deleteFieldDef('f-room');
    await pumpEventQueue();
    await sub.cancel();

    expect(seen.length, greaterThanOrEqualTo(2));
    expect(seen.last, seen.first - 1);
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

  test('Удалённое событие возвращается полоской «Вернуть»', () async {
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
    await repo.deleteEvent('e-breakfast');
    await repo.restoreEvent('e-breakfast');

    final events = await repo
        .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
        .first;
    expect(events.where((e) => e.id == 'e-breakfast'), hasLength(1));
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

/// Событие из базы по ключу: репозиторий отдаёт их диапазоном, отдельного
/// чтения по одному нет — виды всегда просят период.
Future<VEvent> _eventById(
  VehaRepository repo,
  String id,
  DateTime day,
) async {
  final events = await repo
      .watchRange(day, day.add(const Duration(days: 1)))
      .first;
  return events.firstWhere((e) => e.id == id);
}

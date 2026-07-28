import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Color;
import 'package:uuid/uuid.dart';

import '../domain/occurrences.dart';
import '../domain/recurrence.dart';
import 'db/database.dart';
import 'models.dart';
import 'seed.dart';

/// Единственная дверь между экранами и базой.
///
/// Экраны работают с доменными моделями и ничего не знают про drift: когда
/// появится сервер, синхронизация встанет за этот же слой.
class VehaRepository {
  VehaRepository(this.db);

  final VehaDatabase db;
  static const _uuid = Uuid();

  // ---------- чтение ----------

  /// Календари и ветки потоком: список обновляется сам, когда календарь
  /// завели, переименовали или скрыли. Ручное обновление экранов после каждой
  /// правки — источник рассинхрона.
  Stream<Inheritance> watchInheritance() {
    // Один запрос вместо двух стримов: два независимых потока пришлось бы
    // сшивать вручную, и на каждой правке экран моргал бы промежуточным
    // состоянием.
    final query = db.select(db.calendars).join([
      leftOuterJoin(db.subcategories,
          db.subcategories.calendarId.equalsExp(db.calendars.id) &
              db.subcategories.deletedAt.isNull()),
    ])
      ..where(db.calendars.deletedAt.isNull())
      // Ничью разрешаем временем заведения, а его — идентификатором. Без этого
      // две ветки с одинаковым порядком меняются местами от чтения к чтению:
      // SQLite ничего не обещает про строки, равные по ORDER BY.
      ..orderBy([
        OrderingTerm(expression: db.calendars.sortOrder),
        OrderingTerm(expression: db.calendars.createdAt),
        OrderingTerm(expression: db.calendars.id),
        OrderingTerm(expression: db.subcategories.sortOrder),
        OrderingTerm(expression: db.subcategories.createdAt),
        OrderingTerm(expression: db.subcategories.id),
      ]);

    return query.watch().map((rows) {
      final calendars = <String, VCalendar>{};
      final subcategories = <String, VSubcategory>{};

      for (final row in rows) {
        final c = row.readTable(db.calendars);
        calendars.putIfAbsent(c.id, () => _toCalendar(c));

        final s = row.readTableOrNull(db.subcategories);
        if (s != null) subcategories.putIfAbsent(s.id, () => _toSubcategory(s));
      }

      return Inheritance(calendars: calendars, subcategories: subcategories);
    });
  }

  /// Календари и ветки одним куском: они нужны вместе на каждом экране,
  /// а запросов два.
  Future<Inheritance> loadInheritance() async {
    final cals = await (db.select(db.calendars)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.createdAt),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .get();
    final subs = await (db.select(db.subcategories)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.createdAt),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .get();

    return Inheritance(
      calendars: {for (final c in cals) c.id: _toCalendar(c)},
      subcategories: {for (final s in subs) s.id: _toSubcategory(s)},
    );
  }

  /// События за период, уже развёрнутые в экземпляры. Многодневные попадают
  /// сюда же: их отфильтровывает экран, потому что рисует их отдельной полосой.
  ///
  /// Три ветки отбора вместо одной: обычное событие берётся по пересечению с
  /// окном, ряд — по одной только дате начала (он мог начаться в мае и идти до
  /// сих пор), а выломанный экземпляр — по своему прежнему месту в ряду, иначе
  /// перенесённое на неделю вперёд занятие оставит после себя призрак на
  /// старом времени.
  Stream<List<VEvent>> watchRange(DateTime from, DateTime to) {
    final fromMs = from.millisecondsSinceEpoch;
    final toMs = to.millisecondsSinceEpoch;

    final crossesWindow = db.events.start.isSmallerOrEqualValue(toMs) &
        db.events.end.isBiggerOrEqualValue(fromMs);
    final startedSeries = db.events.rrule.isNotNull() &
        db.events.start.isSmallerOrEqualValue(toMs);
    final movedFromWindow = db.events.originalStart.isBiggerOrEqualValue(fromMs) &
        db.events.originalStart.isSmallerOrEqualValue(toMs);

    // Оба присоединения дают декартово произведение полей на исключения, но
    // и того и другого у события единицы, а взамен стрим сам просыпается на
    // правку любой из трёх таблиц. Календарь присоединён внутренним: скрытый
    // и удалённый календарь уносят свои события из всех видов сразу.
    final query = db.select(db.events).join([
      innerJoin(db.calendars, db.calendars.id.equalsExp(db.events.calendarId)),
      leftOuterJoin(db.fieldValues, db.fieldValues.eventId.equalsExp(db.events.id)),
      leftOuterJoin(db.recurrenceExceptions,
          db.recurrenceExceptions.eventId.equalsExp(db.events.id)),
    ])
      ..where(db.events.deletedAt.isNull() &
          db.calendars.deletedAt.isNull() &
          db.calendars.isVisible.equals(true) &
          (crossesWindow | startedSeries | movedFromWindow))
      ..orderBy([OrderingTerm(expression: db.events.start)]);

    return query.watch().map((rows) {
      final byId = <String, VEvent>{};
      final fields = <String, Set<VFieldValue>>{};
      final excluded = <String, Set<DateTime>>{};

      for (final row in rows) {
        final e = row.readTable(db.events);
        byId.putIfAbsent(e.id, () => _toEvent(e));

        final fv = row.readTableOrNull(db.fieldValues);
        if (fv != null) {
          fields.putIfAbsent(e.id, () => <VFieldValue>{}).add(
              VFieldValue(fieldId: fv.fieldId, value: fv.value));
        }

        final ex = row.readTableOrNull(db.recurrenceExceptions);
        if (ex != null) {
          excluded.putIfAbsent(e.id, () => <DateTime>{}).add(
              DateTime.fromMillisecondsSinceEpoch(ex.excludedDate));
        }
      }

      final stored = [
        for (final e in byId.values)
          fields[e.id] == null ? e : _withFields(e, fields[e.id]!.toList()),
      ];

      return expandOccurrences(stored, from: from, to: to, excluded: excluded);
    });
  }

  Future<List<VNote>> notesOf(String eventId) async {
    final rows = await (db.select(db.eventNotes)
          ..where((t) => t.eventId.equals(eventId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    return [
      for (final n in rows)
        VNote(
          id: n.id,
          eventId: n.eventId,
          text: n.body,
          color: n.color == null ? null : Color(n.color!),
          sortOrder: n.sortOrder,
        ),
    ];
  }

  Future<List<VFieldDef>> fieldsFor(String? calendarId) async {
    final rows = await _fieldDefsQuery().get();
    return [
      for (final f in rows)
        if (f.scopeId == null || f.scopeId == calendarId) _toFieldDef(f),
    ];
  }

  /// Все определения полей потоком: экран полей и карточки событий должны
  /// узнавать о заведённом поле сами, без обхода через перезапуск.
  Stream<List<VFieldDef>> watchFieldDefs() =>
      _fieldDefsQuery().watch().map((rows) => rows.map(_toFieldDef).toList());

  SimpleSelectStatement<FieldDefs, FieldDef> _fieldDefsQuery() =>
      db.select(db.fieldDefs)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder),
          (t) => OrderingTerm(expression: t.createdAt),
          (t) => OrderingTerm(expression: t.id),
        ]);

  // ---------- запись ----------

  /// Каждая правка ложится и в таблицу, и в очередь синхронизации.
  /// Очередь наполняется с первого дня, даже пока сервера нет: иначе при его
  /// появлении накопленные изменения потеряются.
  ///
  /// Экземпляр, пришедший из развёртки, своей строки в базе не имеет. Правка
  /// такого экземпляра выламывает его из ряда отдельной записью: перенос
  /// одного занятия не должен сдвигать остальные.
  Future<void> upsertEvent(VEvent e) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = e.isVirtual ? newId() : e.id;

    await db.transaction(() async {
      await db.into(db.events).insertOnConflictUpdate(EventsCompanion.insert(
            id: id,
            calendarId: e.calendarId,
            subcategoryId: Value(e.subcategoryId),
            title: e.title,
            location: Value(e.location),
            start: e.start.millisecondsSinceEpoch,
            end: e.end.millisecondsSinceEpoch,
            timezone: e.timezone,
            isAllDay: Value(e.isAllDay),
            color: Value(e.color?.toARGB32()),
            icon: Value(e.iconName),
            // Правило остаётся у ряда: выломанный экземпляр повторяется через
            // него, своего повтора у него нет.
            rrule: Value(e.isVirtual ? null : e.rrule),
            recurrenceId: Value(e.recurrenceId),
            originalStart:
                Value(e.originalStart?.millisecondsSinceEpoch),
            createdAt: now,
            updatedAt: now,
          ));
      await _enqueue('event', id, 'upsert');
    });
  }

  // ---------- календари и ветки ----------

  Future<void> upsertCalendar(VCalendar c) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.calendars).insertOnConflictUpdate(
            CalendarsCompanion.insert(
              id: c.id,
              name: c.name,
              color: c.color.toARGB32(),
              icon: c.iconName,
              isVisible: Value(c.isVisible),
              sortOrder: Value(c.sortOrder),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue('calendar', c.id, 'upsert');
    });
  }

  /// Скрытый календарь остаётся в списке, но его события уходят из видов:
  /// это «не показывай сейчас», а не «удали».
  Future<void> setCalendarVisible(String id, bool visible) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.calendars)..where((t) => t.id.equals(id))).write(
        CalendarsCompanion(
          isVisible: Value(visible),
          updatedAt: Value(now),
        ),
      );
      await _enqueue('calendar', id, 'upsert');
    });
  }

  /// Удаление календаря уносит его ветки и события — все мягко.
  Future<void> deleteCalendar(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.calendars)..where((t) => t.id.equals(id)))
          .write(CalendarsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await (db.update(db.subcategories)..where((t) => t.calendarId.equals(id)))
          .write(SubcategoriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await (db.update(db.events)..where((t) => t.calendarId.equals(id)))
          .write(EventsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue('calendar', id, 'delete');
    });
  }

  Future<void> upsertSubcategory(VSubcategory s) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.subcategories).insertOnConflictUpdate(
            SubcategoriesCompanion.insert(
              id: s.id,
              calendarId: s.calendarId,
              name: s.name,
              icon: Value(s.iconName),
              color: Value(s.color?.toARGB32()),
              sortOrder: Value(s.sortOrder),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue('subcategory', s.id, 'upsert');
    });
  }

  /// Удаление ветки события не трогает: они возвращаются на уровень календаря
  /// и там же берут цвет.
  Future<void> deleteSubcategory(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.subcategories)..where((t) => t.id.equals(id)))
          .write(SubcategoriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await (db.update(db.events)..where((t) => t.subcategoryId.equals(id)))
          .write(const EventsCompanion(subcategoryId: Value(null)));
      await _enqueue('subcategory', id, 'delete');
    });
  }

  // ---------- свои поля ----------

  /// Заведение и правка своего поля. `calendarId == null` — поле общее и
  /// достаётся каждому событию; иначе оно принадлежит группе календаря.
  Future<void> upsertFieldDef(VFieldDef f) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.fieldDefs).insertOnConflictUpdate(
            FieldDefsCompanion.insert(
              id: f.id,
              name: f.name,
              type: f.type.name,
              icon: Value(f.iconName),
              scopeType: Value(f.calendarId == null ? 'global' : 'calendar'),
              scopeId: Value(f.calendarId),
              showInCard: Value(f.showInCard),
              sortOrder: Value(f.sortOrder),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue('field', f.id, 'upsert');
    });
  }

  /// Показывать ли поле в свёрнутой карточке события. Отдельным методом, а не
  /// правкой целиком: экран знает про тумблер, а не про остальные поля записи.
  Future<void> setFieldShownInCard(String id, bool shown) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.fieldDefs)..where((t) => t.id.equals(id))).write(
        FieldDefsCompanion(
          showInCard: Value(shown),
          updatedAt: Value(now),
        ),
      );
      await _enqueue('field', id, 'upsert');
    });
  }

  /// Заполненные значения остаются в базе: определение может вернуться по
  /// синхронизации с другого устройства, и тогда написанное найдётся на месте.
  Future<void> deleteFieldDef(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.fieldDefs)..where((t) => t.id.equals(id)))
          .write(FieldDefsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue('field', id, 'delete');
    });
  }

  /// Отменяет одно занятие ряда: «на этой неделе английского не будет».
  ///
  /// Ряд остаётся жить, в базе появляется пропуск. Хранится именно исходное
  /// время экземпляра — то, на котором развёртка его и порождает.
  Future<void> skipOccurrence(String seriesId, DateTime originalStart) async {
    await db.transaction(() async {
      await db.into(db.recurrenceExceptions).insertOnConflictUpdate(
            RecurrenceExceptionsCompanion.insert(
              eventId: seriesId,
              excludedDate: originalStart.millisecondsSinceEpoch,
            ),
          );
      await _enqueue('event', seriesId, 'upsert');
    });
  }

  /// Удаление всегда мягкое.
  Future<void> deleteEvent(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.events)..where((t) => t.id.equals(id)))
          .write(EventsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await _enqueue('event', id, 'delete');
    });
  }

  /// Возвращает удалённое событие: полоска «Вернуть» живёт несколько секунд,
  /// и всё это время строка лежит в базе с пометкой об удалении.
  Future<void> restoreEvent(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.events)..where((t) => t.id.equals(id))).write(
          const EventsCompanion(deletedAt: Value(null))
              .copyWith(updatedAt: Value(now)));
      await _enqueue('event', id, 'upsert');
    });
  }

  /// Возвращает отменённое занятие в ряд.
  Future<void> unskipOccurrence(String seriesId, DateTime originalStart) async {
    await db.transaction(() async {
      await (db.delete(db.recurrenceExceptions)
            ..where((t) =>
                t.eventId.equals(seriesId) &
                t.excludedDate
                    .equals(originalStart.millisecondsSinceEpoch)))
          .go();
      await _enqueue('event', seriesId, 'upsert');
    });
  }

  /// Правка «весь ряд»: экземпляр отдаёт ряду своё время суток и остальные
  /// поля, дата начала ряда остаётся прежней.
  ///
  /// Двигаем именно время суток, а не всю запись: ряд, начатый в мае, не
  /// должен перепрыгнуть в август от того, что человек правил августовское
  /// занятие.
  Future<void> updateWholeSeries(VEvent instance) async {
    final seriesId = instance.recurrenceId;
    if (seriesId == null) {
      await upsertEvent(instance);
      return;
    }

    final series = await (db.select(db.events)
          ..where((t) => t.id.equals(seriesId)))
        .getSingleOrNull();
    if (series == null) {
      await upsertEvent(instance);
      return;
    }

    final seriesStart = DateTime.fromMillisecondsSinceEpoch(series.start);
    final start = DateTime(
      seriesStart.year,
      seriesStart.month,
      seriesStart.day,
      instance.start.hour,
      instance.start.minute,
    );
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      await (db.update(db.events)..where((t) => t.id.equals(seriesId)))
          .write(EventsCompanion(
        title: Value(instance.title),
        location: Value(instance.location),
        start: Value(start.millisecondsSinceEpoch),
        end: Value(start.add(instance.duration).millisecondsSinceEpoch),
        isAllDay: Value(instance.isAllDay),
        color: Value(instance.color?.toARGB32()),
        icon: Value(instance.iconName),
        rrule: Value(instance.rrule ?? series.rrule),
        updatedAt: Value(now),
      ));
      await _enqueue('event', seriesId, 'upsert');
    });
  }

  /// Правка «это занятие и следующие»: ряд разрезается по дате экземпляра.
  ///
  /// Прошедшие занятия остаются на своих местах — их человек уже прожил, и
  /// задним числом сдвигать их нельзя. Старый ряд получает `UNTIL` на канун
  /// разреза, новый начинается с правки и наследует остаток правила.
  Future<void> updateFromOccurrence(VEvent instance) async {
    final seriesId = instance.recurrenceId;
    final cut = instance.originalStart;
    if (seriesId == null || cut == null) {
      await upsertEvent(instance);
      return;
    }

    final series = await (db.select(db.events)
          ..where((t) => t.id.equals(seriesId)))
        .getSingleOrNull();
    if (series?.rrule == null) {
      await upsertEvent(instance);
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final seriesStart = DateTime.fromMillisecondsSinceEpoch(series!.start);
    final tail = Recurrence.cutBefore(series.rrule!, cut, start: seriesStart);
    final head = Recurrence.endBefore(series.rrule!, cut, start: seriesStart);
    final newId = this.newId();

    await db.transaction(() async {
      await (db.update(db.events)..where((t) => t.id.equals(seriesId)))
          .write(EventsCompanion(rrule: Value(head), updatedAt: Value(now)));

      await db.into(db.events).insert(EventsCompanion.insert(
            id: newId,
            calendarId: instance.calendarId,
            subcategoryId: Value(instance.subcategoryId),
            title: instance.title,
            location: Value(instance.location),
            start: instance.start.millisecondsSinceEpoch,
            end: instance.end.millisecondsSinceEpoch,
            timezone: instance.timezone,
            isAllDay: Value(instance.isAllDay),
            color: Value(instance.color?.toARGB32()),
            icon: Value(instance.iconName),
            rrule: Value(tail),
            createdAt: now,
            updatedAt: now,
          ));

      await _enqueue('event', seriesId, 'upsert');
      await _enqueue('event', newId, 'upsert');
    });
  }

  Future<void> _enqueue(String type, String id, String op) async {
    // Схлопывание очереди: незачем хранить пять правок одного события.
    await (db.delete(db.syncQueue)
          ..where((t) => t.entityType.equals(type) & t.entityId.equals(id)))
        .go();
    await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          entityType: type,
          entityId: id,
          operation: op,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  // ---------- первый запуск ----------

  /// Наполняет пустую базу демонстрационными данными.
  ///
  /// Пустой календарь при первом запуске выглядит сломанным: человек не
  /// понимает, что приложение вообще умеет. Данные помечены обычными
  /// записями и удаляются как любые другие.
  /// Данные собраны на 27 июля 2026 и сдвигаются к дню первого запуска целыми
  /// сутками: иначе человек, поставивший приложение в сентябре, открывает его
  /// на пустом дне, а демонстрация лежит в прошлом.
  Future<void> seedIfEmpty({DateTime? today}) async {
    final count = await db.select(db.calendars).get();
    if (count.isNotEmpty) return;

    final start = today ?? DateTime.now();
    final shift = DateTime(start.year, start.month, start.day)
        .difference(Seed.today);
    DateTime moved(DateTime d) => d.add(shift);

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      for (final c in Seed.calendars) {
        await db.into(db.calendars).insert(CalendarsCompanion.insert(
              id: c.id,
              name: c.name,
              color: c.color.toARGB32(),
              icon: c.iconName,
              sortOrder: Value(c.sortOrder),
              createdAt: now,
              updatedAt: now,
            ));
      }
      for (final s in Seed.subcategories) {
        await db.into(db.subcategories).insert(SubcategoriesCompanion.insert(
              id: s.id,
              calendarId: s.calendarId,
              name: s.name,
              icon: Value(s.iconName),
              color: Value(s.color?.toARGB32()),
              sortOrder: Value(s.sortOrder),
              createdAt: now,
              updatedAt: now,
            ));
      }
      for (final f in Seed.fields) {
        await db.into(db.fieldDefs).insert(FieldDefsCompanion.insert(
              id: f.id,
              name: f.name,
              type: f.type.name,
              icon: Value(f.iconName),
              scopeType: Value(f.calendarId == null ? 'global' : 'calendar'),
              scopeId: Value(f.calendarId),
              showInCard: Value(f.showInCard),
              sortOrder: Value(f.sortOrder),
              createdAt: now,
              updatedAt: now,
            ));
      }
      for (final e in [...Seed.dayEvents, ...Seed.spans, Seed.exam]) {
        await db.into(db.events).insert(EventsCompanion.insert(
              id: e.id,
              calendarId: e.calendarId,
              subcategoryId: Value(e.subcategoryId),
              title: e.title,
              location: Value(e.location),
              start: moved(e.start).millisecondsSinceEpoch,
              end: moved(e.end).millisecondsSinceEpoch,
              timezone: e.timezone,
              isAllDay: Value(e.isAllDay),
              color: Value(e.color?.toARGB32()),
              icon: Value(e.iconName),
              rrule: Value(e.rrule),
              createdAt: now,
              updatedAt: now,
            ));
        for (final v in e.fields) {
          await db.into(db.fieldValues).insert(FieldValuesCompanion.insert(
                eventId: e.id,
                fieldId: v.fieldId,
                value: v.value,
              ));
        }
      }
      for (final n in Seed.examNotes) {
        await db.into(db.eventNotes).insert(EventNotesCompanion.insert(
              id: n.id,
              eventId: n.eventId,
              body: n.text,
              color: Value(n.color?.toARGB32()),
              sortOrder: Value(n.sortOrder),
              createdAt: now,
              updatedAt: now,
            ));
      }
    });
  }

  String newId() => _uuid.v4();

  // ---------- преобразования ----------

  static VCalendar _toCalendar(Calendar c) => VCalendar(
        id: c.id,
        name: c.name,
        iconName: c.icon,
        color: Color(c.color),
        isVisible: c.isVisible,
        sortOrder: c.sortOrder,
      );

  static VSubcategory _toSubcategory(Subcategory s) => VSubcategory(
        id: s.id,
        calendarId: s.calendarId,
        name: s.name,
        iconName: s.icon,
        color: s.color == null ? null : Color(s.color!),
        sortOrder: s.sortOrder,
      );

  static VEvent _toEvent(Event e) => VEvent(
        id: e.id,
        calendarId: e.calendarId,
        subcategoryId: e.subcategoryId,
        title: e.title,
        start: DateTime.fromMillisecondsSinceEpoch(e.start),
        end: DateTime.fromMillisecondsSinceEpoch(e.end),
        color: e.color == null ? null : Color(e.color!),
        iconName: e.icon,
        isAllDay: e.isAllDay,
        rrule: e.rrule,
        recurrenceId: e.recurrenceId,
        originalStart: e.originalStart == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(e.originalStart!),
        timezone: e.timezone,
        location: e.location,
      );

  static VEvent _withFields(VEvent e, List<VFieldValue> fields) => VEvent(
        id: e.id,
        calendarId: e.calendarId,
        subcategoryId: e.subcategoryId,
        title: e.title,
        start: e.start,
        end: e.end,
        color: e.color,
        iconName: e.iconName,
        isAllDay: e.isAllDay,
        rrule: e.rrule,
        recurrenceId: e.recurrenceId,
        originalStart: e.originalStart,
        timezone: e.timezone,
        location: e.location,
        fields: fields,
      );

  static VFieldDef _toFieldDef(FieldDef f) => VFieldDef(
        id: f.id,
        name: f.name,
        type: VFieldType.values.firstWhere(
          (t) => t.name == f.type,
          orElse: () => VFieldType.text,
        ),
        iconName: f.icon ?? 'text',
        calendarId: f.scopeId,
        showInCard: f.showInCard,
        isBuiltIn: f.scopeId == null,
        sortOrder: f.sortOrder,
      );
}

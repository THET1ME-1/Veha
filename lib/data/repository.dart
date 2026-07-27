import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Color;
import 'package:uuid/uuid.dart';

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

  /// Календари и ветки одним куском: они нужны вместе на каждом экране,
  /// а запросов два.
  Future<Inheritance> loadInheritance() async {
    final cals = await (db.select(db.calendars)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    final subs = await (db.select(db.subcategories)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();

    return Inheritance(
      calendars: {for (final c in cals) c.id: _toCalendar(c)},
      subcategories: {for (final s in subs) s.id: _toSubcategory(s)},
    );
  }

  /// События за период. Многодневные попадают сюда же: их отфильтровывает
  /// экран, потому что рисует их отдельной полосой.
  Stream<List<VEvent>> watchRange(DateTime from, DateTime to) {
    final fromMs = from.millisecondsSinceEpoch;
    final toMs = to.millisecondsSinceEpoch;

    final query = db.select(db.events).join([
      leftOuterJoin(db.fieldValues, db.fieldValues.eventId.equalsExp(db.events.id)),
    ])
      ..where(db.events.deletedAt.isNull() &
          db.events.start.isSmallerOrEqualValue(toMs) &
          db.events.end.isBiggerOrEqualValue(fromMs))
      ..orderBy([OrderingTerm(expression: db.events.start)]);

    return query.watch().map((rows) {
      final byId = <String, VEvent>{};
      final fields = <String, List<VFieldValue>>{};

      for (final row in rows) {
        final e = row.readTable(db.events);
        byId.putIfAbsent(e.id, () => _toEvent(e));
        final fv = row.readTableOrNull(db.fieldValues);
        if (fv != null) {
          fields.putIfAbsent(e.id, () => []).add(
              VFieldValue(fieldId: fv.fieldId, value: fv.value));
        }
      }

      return [
        for (final e in byId.values)
          fields[e.id] == null ? e : _withFields(e, fields[e.id]!),
      ];
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
    final rows = await (db.select(db.fieldDefs)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    return [
      for (final f in rows)
        if (f.scopeId == null || f.scopeId == calendarId) _toFieldDef(f),
    ];
  }

  // ---------- запись ----------

  /// Каждая правка ложится и в таблицу, и в очередь синхронизации.
  /// Очередь наполняется с первого дня, даже пока сервера нет: иначе при его
  /// появлении накопленные изменения потеряются.
  Future<void> upsertEvent(VEvent e) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.events).insertOnConflictUpdate(EventsCompanion.insert(
            id: e.id,
            calendarId: e.calendarId,
            subcategoryId: Value(e.subcategoryId),
            title: e.title,
            location: Value(e.location),
            start: e.start.millisecondsSinceEpoch,
            end: e.end.millisecondsSinceEpoch,
            timezone: 'Europe/Chisinau',
            isAllDay: Value(e.isAllDay),
            color: Value(e.color?.toARGB32()),
            icon: Value(e.iconName),
            rrule: Value(e.rrule),
            createdAt: now,
            updatedAt: now,
          ));
      await _enqueue('event', e.id, 'upsert');
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
  Future<void> seedIfEmpty() async {
    final count = await db.select(db.calendars).get();
    if (count.isNotEmpty) return;

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
              start: e.start.millisecondsSinceEpoch,
              end: e.end.millisecondsSinceEpoch,
              timezone: 'Europe/Chisinau',
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

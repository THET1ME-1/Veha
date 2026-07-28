import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Color;
import 'package:uuid/uuid.dart';

import '../domain/occurrences.dart';
import '../domain/recurrence.dart';
import 'db/database.dart';
import 'models.dart';
import 'seed.dart';
import 'seed_words.dart';

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
  Stream<List<VEvent>> watchRange(DateTime from, DateTime to) =>
      _rangeQuery(from, to).watch().map((rows) => _expand(rows, from, to));

  /// То же окно разовым запросом. Нужно там, где стрим не к месту: поиск
  /// свободного окна перебирает две недели, и четырнадцать живых подписок
  /// ради одного ответа — цена ни за что.
  Future<List<VEvent>> eventsBetween(DateTime from, DateTime to) async =>
      _expand(await _rangeQuery(from, to).get(), from, to);

  JoinedSelectStatement<HasResultSet, dynamic> _rangeQuery(
    DateTime from,
    DateTime to,
  ) {
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
    return db.select(db.events).join([
      innerJoin(db.calendars, db.calendars.id.equalsExp(db.events.calendarId)),
      leftOuterJoin(db.fieldValues, db.fieldValues.eventId.equalsExp(db.events.id)),
      leftOuterJoin(db.recurrenceExceptions,
          db.recurrenceExceptions.eventId.equalsExp(db.events.id)),
      leftOuterJoin(db.reminders, db.reminders.eventId.equalsExp(db.events.id)),
    ])
      ..where(db.events.deletedAt.isNull() &
          db.calendars.deletedAt.isNull() &
          db.calendars.isVisible.equals(true) &
          (crossesWindow | startedSeries | movedFromWindow))
      ..orderBy([OrderingTerm(expression: db.events.start)]);
  }

  /// Строки запроса — в развёрнутые события окна.
  List<VEvent> _expand(List<TypedResult> rows, DateTime from, DateTime to) {
    final byId = <String, VEvent>{};
    final fields = <String, Set<VFieldValue>>{};
    final excluded = <String, Set<DateTime>>{};
    final alarms = <String, Set<int>>{};

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

      final rem = row.readTableOrNull(db.reminders);
      if (rem != null) {
        alarms.putIfAbsent(e.id, () => <int>{}).add(rem.minutesBefore);
      }
    }

    final stored = [
      for (final e in byId.values)
        _withDetails(
          e,
          fields: fields[e.id]?.toList(),
          reminders: alarms[e.id]?.toList(),
        ),
    ];

    return expandOccurrences(stored, from: from, to: to, excluded: excluded);
  }

  /// Поиск по всему календарю: название, место и значения своих полей.
  ///
  /// Окна у поиска нет. «Когда был экзамен» спрашивают про прошлое так же
  /// часто, как про будущее, а ограничение диапазоном человек воспринимает как
  /// «не нашлось».
  ///
  /// Ряд отдаётся ближайшим занятием: строка ряда стоит на дате первого
  /// занятия, и «Подъём» из мая в ответе на поиск выглядит ошибкой. Занятия
  /// ищутся вперёд на год — дальше уходят разве что годовщины, а разворачивать
  /// бесконечный ряд ради поиска дорого.
  Stream<List<VEvent>> watchSearch(String query, {DateTime? now}) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return Stream.value(const []);

    final moment = now ?? DateTime.now();

    // Отбор идёт в Dart, а не в `WHERE ... LIKE`. `lower()` у SQLite трогает
    // только латиницу: «Английский» так и остаётся с заглавной, и поиск по
    // «англ» не находит ничего. Своя ICU-сборка ради этого не стоит того —
    // событий у человека тысячи, проход по ним занимает миллисекунды.
    // Полнотекстового индекса нет и не будет: он не переживёт шифрование.
    final selfQuery = db.select(db.events).join([
      innerJoin(db.calendars, db.calendars.id.equalsExp(db.events.calendarId)),
      leftOuterJoin(
          db.fieldValues, db.fieldValues.eventId.equalsExp(db.events.id)),
    ])
      ..where(db.events.deletedAt.isNull() &
          db.calendars.deletedAt.isNull() &
          db.calendars.isVisible.equals(true));

    return selfQuery.watch().map((rows) {
      final byId = <String, VEvent>{};
      final matched = <String>{};

      for (final row in rows) {
        final e = row.readTable(db.events);
        byId.putIfAbsent(e.id, () => _toEvent(e));

        final value = row.readTableOrNull(db.fieldValues)?.value;
        if (_has(e.title, needle) ||
            _has(e.location, needle) ||
            _has(e.description, needle) ||
            _has(value, needle)) {
          matched.add(e.id);
        }
      }
      byId.removeWhere((id, _) => !matched.contains(id));

      final out = <VEvent>[];
      for (final e in byId.values) {
        if (e.rrule == null) {
          out.add(e);
          continue;
        }
        final next = expandOccurrences(
          [e],
          from: moment,
          to: moment.add(const Duration(days: 365)),
        );
        // Ряд, у которого впереди ничего нет, показываем последним занятием:
        // закончившийся курс из поиска пропадать не должен.
        out.add(next.isNotEmpty ? next.first : e);
      }

      // Сначала то, что ещё будет, — по возрастанию. Прошедшее следом, от
      // недавнего к давнему: «на той неделе» ищут чаще, чем «в прошлом году».
      final future = out.where((e) => e.start.isAfter(moment)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      final past = out.where((e) => !e.start.isAfter(moment)).toList()
        ..sort((a, b) => b.start.compareTo(a.start));

      return [...future, ...past];
    });
  }

  static bool _has(String? haystack, String needle) =>
      haystack != null && haystack.toLowerCase().contains(needle);

  Future<List<VNote>> notesOf(String eventId) async =>
      (await _notesQuery(eventId).get()).map(_toNote).toList();

  /// Заметки события потоком: их правят на том же экране, где показывают,
  /// и обновляться список должен сам.
  Stream<List<VNote>> watchNotes(String eventId) =>
      _notesQuery(eventId).watch().map((rows) => rows.map(_toNote).toList());

  SimpleSelectStatement<EventNotes, EventNote> _notesQuery(String eventId) =>
      db.select(db.eventNotes)
        ..where((t) => t.eventId.equals(eventId) & t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder),
          (t) => OrderingTerm(expression: t.createdAt),
          (t) => OrderingTerm(expression: t.id),
        ]);

  static VNote _toNote(EventNote n) => VNote(
        id: n.id,
        eventId: n.eventId,
        text: n.body,
        color: n.color == null ? null : Color(n.color!),
        sortOrder: n.sortOrder,
      );

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
      await _writeReminders(id, e.reminders);
      await _writeFieldValues(id, e.fields);
      await _enqueue('event', id, 'upsert');
    });
  }

  /// Значения своих полей переписываются целиком, как и напоминания: стёртое
  /// человеком поле обязано исчезнуть, а не остаться в базе со старым текстом.
  Future<void> _writeFieldValues(String eventId, List<VFieldValue> fields) async {
    await (db.delete(db.fieldValues)..where((t) => t.eventId.equals(eventId)))
        .go();
    for (final f in fields) {
      if (f.value.trim().isEmpty) continue;
      await db.into(db.fieldValues).insert(FieldValuesCompanion.insert(
            eventId: eventId,
            fieldId: f.fieldId,
            value: f.value,
          ));
    }
  }

  /// Набор напоминаний переписывается целиком: правка отвечает на вопрос
  /// «когда предупредить», а не «добавь ещё одно». Дописывание оставляло бы
  /// снятые галочки жить в базе.
  Future<void> _writeReminders(String eventId, List<int> minutes) async {
    await (db.delete(db.reminders)..where((t) => t.eventId.equals(eventId)))
        .go();
    for (final m in minutes.toSet()) {
      await db.into(db.reminders).insert(RemindersCompanion.insert(
            id: newId(),
            eventId: eventId,
            minutesBefore: m,
          ));
    }
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
              defaultReminders: Value(c.defaultReminders?.join(',')),
              defaultDuration: Value(c.defaultDuration?.inMinutes),
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

  /// Выбрасывает то, что удалено давно.
  ///
  /// Удаление мягкое: строка остаётся с отметкой `deleted_at`, иначе сервер
  /// вернёт её обратно при следующей синхронизации. Но копить это вечно
  /// нельзя — база растёт на каждой правке. Девяносто дней с запасом
  /// перекрывают любой разумный перерыв между запусками.
  ///
  /// Возвращает число выброшенных событий: остальное считать незачем, а
  /// показать «почищено» полезно.
  Future<int> purgeDeleted({
    Duration olderThan = const Duration(days: 90),
    DateTime? now,
  }) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(olderThan)
        .millisecondsSinceEpoch;

    return db.transaction(() async {
      final doomed = await (db.select(db.events)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .get();

      for (final e in doomed) {
        // Сначала то, что на событие ссылается: иначе внешние ключи не дадут
        // убрать саму строку.
        await (db.delete(db.fieldValues)..where((t) => t.eventId.equals(e.id)))
            .go();
        await (db.delete(db.reminders)..where((t) => t.eventId.equals(e.id)))
            .go();
        await (db.delete(db.eventNotes)..where((t) => t.eventId.equals(e.id)))
            .go();
        await (db.delete(db.recurrenceExceptions)
              ..where((t) => t.eventId.equals(e.id)))
            .go();
        await (db.delete(db.events)..where((t) => t.id.equals(e.id))).go();
      }

      await (db.delete(db.eventNotes)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .go();
      await (db.delete(db.fieldDefs)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .go();
      await (db.delete(db.subcategories)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .go();
      await (db.delete(db.calendars)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .go();

      return doomed.length;
    });
  }

  // ---------- обмен файлами ----------

  /// Все события для выгрузки: строки как есть, без развёртки рядов.
  ///
  /// В файл уходит правило, а не тысяча его занятий: так меньше файл, а чужой
  /// календарь развернёт ряд сам. Скрытые календари выгружаются наравне с
  /// видимыми — скрытие про показ, а не про содержимое.
  Future<List<VEvent>> allEvents() async {
    final rows = await (db.select(db.events)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.start)]))
        .get();
    final values = await db.select(db.fieldValues).get();

    final byEvent = <String, List<VFieldValue>>{};
    for (final v in values) {
      byEvent
          .putIfAbsent(v.eventId, () => [])
          .add(VFieldValue(fieldId: v.fieldId, value: v.value));
    }

    return [
      for (final e in rows)
        _withDetails(_toEvent(e), fields: byEvent[e.id] ?? const []),
    ];
  }

  /// Загрузка из файла. Все события ложатся в указанный календарь: в чужом
  /// файле календаря нет, а раскладывать наугад хуже, чем сложить в одну
  /// стопку, которую человек разберёт сам.
  ///
  /// [fields] — определения своих полей из того же файла. Недостающие
  /// заводятся в этом же календаре: без определения значение показать негде.
  Future<int> importEvents(
    List<VEvent> events, {
    required String calendarId,
    List<VFieldDef> fields = const [],
  }) async {
    final known = {
      for (final f in await _fieldDefsQuery().get()) f.id,
    };
    for (final f in fields) {
      if (known.contains(f.id)) continue;
      await upsertFieldDef(VFieldDef(
        id: f.id,
        name: f.name,
        type: f.type,
        iconName: f.iconName,
        calendarId: calendarId,
      ));
    }

    var added = 0;
    for (final e in events) {
      await upsertEvent(VEvent(
        id: newId(),
        calendarId: calendarId,
        title: e.title,
        start: e.start,
        end: e.end,
        isAllDay: e.isAllDay,
        rrule: e.rrule,
        timezone: e.timezone,
        location: e.location,
        fields: e.fields,
      ));
      added++;
    }
    return added;
  }

  // ---------- заметки ----------

  /// Заметка внутри события. Свой цвет — четвёртый уровень наследования:
  /// `null` означает «как у события», а не скопированный оттуда цвет.
  Future<void> upsertNote(VNote n) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.eventNotes).insertOnConflictUpdate(
            EventNotesCompanion.insert(
              id: n.id,
              eventId: n.eventId,
              body: n.text,
              color: Value(n.color?.toARGB32()),
              sortOrder: Value(n.sortOrder),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue('note', n.id, 'upsert');
    });
  }

  Future<void> deleteNote(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.eventNotes)..where((t) => t.id.equals(id)))
          .write(EventNotesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue('note', id, 'delete');
    });
  }

  // ---------- сохранённые цвета ----------

  /// «Мои цвета» — общие на всё приложение: подобранный оттенок нужен и
  /// календарю, и заметке, и теме, и повторять подбор в каждом пикере глупо.
  Stream<List<Color>> watchSavedColors() => (db.select(db.savedColors)
        ..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder),
          (t) => OrderingTerm(expression: t.createdAt),
          (t) => OrderingTerm(expression: t.id),
        ]))
      .watch()
      .map((rows) => [for (final r in rows) Color(r.color)]);

  Future<List<Color>> savedColors() async =>
      (await db.select(db.savedColors).get()).map((r) => Color(r.color)).toList();

  /// Возвращает `false`, если такой цвет уже сохранён: два одинаковых кружка
  /// в списке — мусор, а не выбор.
  Future<bool> addSavedColor(Color color) async {
    final value = color.toARGB32();
    final existing = await (db.select(db.savedColors)
          ..where((t) => t.color.equals(value)))
        .getSingleOrNull();
    if (existing != null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.savedColors).insert(SavedColorsCompanion.insert(
          id: newId(),
          color: value,
          sortOrder: Value(now ~/ 1000),
          createdAt: now,
        ));
    return true;
  }

  Future<void> removeSavedColor(Color color) =>
      (db.delete(db.savedColors)..where((t) => t.color.equals(color.toARGB32())))
          .go();

  // ---------- снимки ----------

  /// Снимки события потоком: их добавляют на том же экране, где показывают.
  Stream<List<VPhoto>> watchPhotos(String eventId) =>
      (db.select(db.eventPhotos)
            ..where((t) => t.eventId.equals(eventId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.sortOrder),
              (t) => OrderingTerm(expression: t.createdAt),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .watch()
          .map((rows) => [
                for (final r in rows)
                  VPhoto(
                    id: r.id,
                    eventId: r.eventId,
                    path: r.path,
                    sortOrder: r.sortOrder,
                  ),
              ]);

  /// В очередь синхронизации не идёт: сервер хранит записи, а не файлы.
  Future<void> addPhoto(VPhoto photo) => db
      .into(db.eventPhotos)
      .insertOnConflictUpdate(EventPhotosCompanion.insert(
        id: photo.id,
        eventId: photo.eventId,
        path: photo.path,
        sortOrder: Value(photo.sortOrder),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

  /// Возвращает путь удалённой строки, чтобы вызывающий убрал файл: работа с
  /// диском репозиторию не принадлежит.
  Future<String?> deletePhoto(String id) async {
    final row = await (db.select(db.eventPhotos)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    await (db.delete(db.eventPhotos)..where((t) => t.id.equals(id))).go();
    return row.path;
  }

  // ---------- задачи ----------

  /// Задачи потоком. Невыполненные впереди, дальше по сроку: задача без срока
  /// не всплывает над завтрашней, но и не тонет под сделанными.
  Stream<List<VTask>> watchTasks({bool includeDone = true}) {
    final query = db.select(db.tasks)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt.isNotNull()),
        (t) => OrderingTerm(expression: t.due.isNull()),
        (t) => OrderingTerm(expression: t.due),
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.createdAt),
        (t) => OrderingTerm(expression: t.id),
      ]);
    if (!includeDone) query.where((t) => t.completedAt.isNull());
    return query.watch().map((rows) => rows.map(_toTask).toList());
  }

  /// Задачи со сроком внутри окна — для видов календаря.
  Stream<List<VTask>> watchTasksInRange(DateTime from, DateTime to) =>
      (db.select(db.tasks)
            ..where((t) =>
                t.deletedAt.isNull() &
                t.due.isBiggerOrEqualValue(from.millisecondsSinceEpoch) &
                t.due.isSmallerThanValue(to.millisecondsSinceEpoch))
            ..orderBy([
              (t) => OrderingTerm(expression: t.due),
              (t) => OrderingTerm(expression: t.sortOrder),
              (t) => OrderingTerm(expression: t.createdAt),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .watch()
          .map((rows) => rows.map(_toTask).toList());

  Future<void> upsertTask(VTask t) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.tasks).insertOnConflictUpdate(TasksCompanion.insert(
            id: t.id,
            calendarId: t.calendarId,
            subcategoryId: Value(t.subcategoryId),
            title: t.title,
            notes: Value(t.notes),
            due: Value(t.due?.millisecondsSinceEpoch),
            hasTime: Value(t.hasTime),
            completedAt: Value(t.completedAt?.millisecondsSinceEpoch),
            color: Value(t.color?.toARGB32()),
            icon: Value(t.iconName),
            sortOrder: Value(t.sortOrder),
            createdAt: now,
            updatedAt: now,
          ));
      await _enqueue('task', t.id, 'upsert');
    });
  }

  /// Отметка выполнения. Отдельным методом: чекбокс знает про одну колонку,
  /// а не про всю запись, и правка целиком затёрла бы чужие изменения.
  Future<void> setTaskDone(String id, bool done) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          completedAt: Value(done ? now : null),
          updatedAt: Value(now),
        ),
      );
      await _enqueue('task', id, 'upsert');
    });
  }

  Future<void> deleteTask(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.tasks)..where((t) => t.id.equals(id)))
          .write(TasksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue('task', id, 'delete');
    });
  }

  Future<void> restoreTask(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.tasks)..where((t) => t.id.equals(id)))
          .write(TasksCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ));
      await _enqueue('task', id, 'upsert');
    });
  }

  static VTask _toTask(Task t) => VTask(
        id: t.id,
        calendarId: t.calendarId,
        subcategoryId: t.subcategoryId,
        title: t.title,
        notes: t.notes,
        due: t.due == null ? null : DateTime.fromMillisecondsSinceEpoch(t.due!),
        hasTime: t.hasTime,
        completedAt: t.completedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(t.completedAt!),
        color: t.color == null ? null : Color(t.color!),
        iconName: t.icon,
        sortOrder: t.sortOrder,
      );

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

  /// Удаление всего ряда: и записи, и всех его занятий разом.
  ///
  /// Отдельным методом от [deleteEvent] намеренно: у экземпляра ряда своего
  /// ключа нет, и «удалить» без уточнения означало бы «отменить одно
  /// занятие» — разные намерения, которые легко перепутать.
  Future<void> deleteSeries(String seriesId) => deleteEvent(seriesId);

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

  /// Событие по ключу — как оно лежит в базе. Нужно, чтобы полоска «Вернуть»
  /// могла положить обратно ровно то, что было до правки.
  Future<VEvent?> eventById(String id) async {
    final row = await (db.select(db.events)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;

    final fields = await (db.select(db.fieldValues)
          ..where((t) => t.eventId.equals(id)))
        .get();
    final alarms = await (db.select(db.reminders)
          ..where((t) => t.eventId.equals(id)))
        .get();

    return _withDetails(
      _toEvent(row),
      fields: [
        for (final f in fields)
          VFieldValue(fieldId: f.fieldId, value: f.value),
      ],
      reminders: [for (final r in alarms) r.minutesBefore],
    );
  }

  /// Пауза ряда: занятия в окне пропускаются, ряд живёт дальше.
  ///
  /// Каникулы, отпуск, болезнь — это не «отменить одно» и не «убить весь
  /// ряд», а отрезок без занятий. Пропуски пишутся теми же исключениями,
  /// что и отмена одного занятия, поэтому возвращаются так же.
  ///
  /// Возвращает даты пропущенного — вызывающий отдаёт их полоске «Вернуть».
  Future<List<DateTime>> pauseSeries(
    String seriesId,
    DateTime from,
    DateTime to,
  ) async {
    final row = await (db.select(db.events)..where((t) => t.id.equals(seriesId)))
        .getSingleOrNull();
    if (row?.rrule == null) return const [];

    final series = _toEvent(row!);
    final occurrences =
        expandOccurrences([series], from: from, to: to, excluded: const {});

    final skipped = <DateTime>[];
    await db.transaction(() async {
      for (final o in occurrences) {
        final moment = o.originalStart ?? o.start;
        await db.into(db.recurrenceExceptions).insertOnConflictUpdate(
              RecurrenceExceptionsCompanion.insert(
                eventId: seriesId,
                excludedDate: moment.millisecondsSinceEpoch,
              ),
            );
        skipped.add(moment);
      }
      if (skipped.isNotEmpty) await _enqueue('event', seriesId, 'upsert');
    });
    return skipped;
  }

  /// Возвращает в ряд пачку пропущенных занятий — обратная сторона паузы.
  Future<void> resumeSeries(String seriesId, List<DateTime> moments) async {
    if (moments.isEmpty) return;
    await db.transaction(() async {
      for (final moment in moments) {
        await (db.delete(db.recurrenceExceptions)
              ..where((t) =>
                  t.eventId.equals(seriesId) &
                  t.excludedDate.equals(moment.millisecondsSinceEpoch)))
            .go();
      }
      await _enqueue('event', seriesId, 'upsert');
    });
  }

  /// События одного дня, уже развёрнутые. Нужны действиям, которые работают
  /// с днём целиком: сдвинуть остаток, повторить день.
  Future<List<VEvent>> eventsOfDay(DateTime day) {
    final from = DateTime(day.year, day.month, day.day);
    return eventsBetween(from, from.add(const Duration(days: 1)));
  }

  /// Обрывает ряд на дате занятия: «это и следующие удалить».
  ///
  /// Прошедшие занятия остаются — их человек прожил, и стирать их задним
  /// числом нельзя. Правилу дописывается `UNTIL` на канун разреза.
  Future<void> trimSeriesAt(String seriesId, DateTime cut) async {
    final series = await (db.select(db.events)
          ..where((t) => t.id.equals(seriesId)))
        .getSingleOrNull();
    if (series?.rrule == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final start = DateTime.fromMillisecondsSinceEpoch(series!.start);
    final head = Recurrence.endBefore(series.rrule!, cut, start: start);

    await db.transaction(() async {
      await (db.update(db.events)..where((t) => t.id.equals(seriesId)))
          .write(EventsCompanion(rrule: Value(head), updatedAt: Value(now)));
      await _enqueue('event', seriesId, 'upsert');
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

    // Занятие могли не только переставить по времени, но и перенести на
    // другой день. Сдвиг считаем от исходного места экземпляра в ряду и
    // прикладываем к началу ряда: ряд, начатый в мае, переезжает на столько
    // же суток, а не прыгает в август из-за правки августовского занятия.
    final origin = instance.originalStart ?? instance.start;
    final shift = DateTime(instance.start.year, instance.start.month,
            instance.start.day)
        .difference(DateTime(origin.year, origin.month, origin.day))
        .inDays;

    final moved = seriesStart.add(Duration(days: shift));
    final start = DateTime(
      moved.year,
      moved.month,
      moved.day,
      instance.start.hour,
      instance.start.minute,
    );
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      await (db.update(db.events)..where((t) => t.id.equals(seriesId)))
          .write(EventsCompanion(
        title: Value(instance.title),
        subcategoryId: Value(instance.subcategoryId),
        location: Value(instance.location),
        start: Value(start.millisecondsSinceEpoch),
        end: Value(start.add(instance.duration).millisecondsSinceEpoch),
        isAllDay: Value(instance.isAllDay),
        color: Value(instance.color?.toARGB32()),
        icon: Value(instance.iconName),
        // Ровно то, что выбрал человек. Подстановка старого правила при
        // пустом значении означала, что снять повтор невозможно: экран
        // говорил «Не повторяется», а ряд продолжал идти.
        rrule: Value(instance.rrule),
        updatedAt: Value(now),
      ));
      // Напоминания и значения полей лежат в соседних таблицах: строка
      // события их не несёт, и без этих двух вызовов правка ряда теряла
      // половину — молча.
      await _writeReminders(seriesId, instance.reminders);
      await _writeFieldValues(seriesId, instance.fields);
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
      await _writeReminders(newId, instance.reminders);
      await _writeFieldValues(newId, instance.fields);

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
  /// [words] переводят демонстрацию на язык человека: первый запуск с чужой
  /// кириллицей выглядит поломкой, а не приветствием.
  /// Первый запуск: один пустой календарь и ничего больше.
  ///
  /// Демонстрационные события в приложение не попадают: человек ставит
  /// календарь, чтобы вести свои дела, а не разбирать чужие. Календарь всё же
  /// нужен один — иначе новое событие некуда положить, и кнопка «Записать»
  /// молча не работает.
  Future<void> ensureFirstCalendar({SeedWords? words}) async {
    final existing = await db.select(db.calendars).get();
    if (existing.isNotEmpty) return;

    final w = words ?? SeedWords.of('ru');
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.calendars).insert(CalendarsCompanion.insert(
          id: 'default',
          name: w.t('Личное'),
          color: 0xFF41CCB5,
          icon: 'calendar',
          createdAt: now,
          updatedAt: now,
        ));
  }

  /// Демонстрационные данные. В приложении не вызывается — живут ради
  /// снимков экранов и тестов, где нужен полный календарь.
  Future<void> seedIfEmpty({DateTime? today, SeedWords? words}) async {
    final w = words ?? SeedWords.of('ru');
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
              name: w.t(c.name),
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
              name: w.t(s.name),
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
              name: w.t(f.name),
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
              title: w.t(e.title),
              location: Value(e.location == null ? null : w.t(e.location!)),
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
                value: w.t(v.value),
              ));
        }
      }
      for (final n in Seed.examNotes) {
        await db.into(db.eventNotes).insert(EventNotesCompanion.insert(
              id: n.id,
              eventId: n.eventId,
              body: w.t(n.text),
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

  /// Частые события: что человек заводит снова и снова.
  ///
  /// Отдельной таблицы шаблонов нет намеренно. Шаблон, который надо завести
  /// руками, заводят один раз и забывают; а история уже знает, что «Планёрка»
  /// была двенадцать раз по полтора часа в «Работе». Считаем по ней.
  Future<List<VEvent>> frequentEvents({
    int limit = 6,
    Duration within = const Duration(days: 90),
    DateTime? now,
  }) async {
    final since = (now ?? DateTime.now())
        .subtract(within)
        .millisecondsSinceEpoch;

    final rows = await db
        .customSelect(
          'SELECT title, calendar_id, subcategory_id, color, icon, '
          '       MAX(start) AS last_start, '
          '       (\'end\') AS ignored, '
          '       AVG("end" - start) AS avg_length, '
          '       COUNT(*) AS times '
          'FROM events '
          'WHERE deleted_at IS NULL AND start >= ? '
          'GROUP BY lower(title), calendar_id '
          'ORDER BY times DESC, last_start DESC '
          'LIMIT ?',
          variables: [Variable<int>(since), Variable<int>(limit)],
        )
        .get();

    return [
      for (final row in rows)
        VEvent(
          // Ключ не настоящий: это заготовка, а не запись из базы.
          id: 'frequent',
          calendarId: row.read<String>('calendar_id'),
          subcategoryId: row.read<String?>('subcategory_id'),
          title: row.read<String>('title'),
          start: DateTime.fromMillisecondsSinceEpoch(
              row.read<int>('last_start')),
          end: DateTime.fromMillisecondsSinceEpoch(
                  row.read<int>('last_start'))
              .add(Duration(
                  milliseconds: row.read<double>('avg_length').round())),
          color: row.read<int?>('color') == null
              ? null
              : Color(row.read<int>('color')),
          iconName: row.read<String?>('icon'),
        ),
    ];
  }

  /// Удалённое, что ещё лежит в базе: корзина показывает именно это.
  ///
  /// Хранение мягкое и без того — корзина просто даёт на него посмотреть.
  /// Чистка раз в 90 дней остаётся: она щедрее обещанных тридцати.
  Future<List<VEvent>> deletedEvents() async {
    final rows = await (db.select(db.events)
          ..where((t) => t.deletedAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.deletedAt, mode: OrderingMode.desc),
          ]))
        .get();
    return rows.map(_toEvent).toList();
  }

  Future<List<VTask>> deletedTasks() async {
    final rows = await (db.select(db.tasks)
          ..where((t) => t.deletedAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.deletedAt, mode: OrderingMode.desc),
          ]))
        .get();
    return rows.map(_toTask).toList();
  }

  /// Очистить корзину целиком — сейчас, а не через 90 дней.
  Future<int> emptyTrash() => purgeDeleted(olderThan: Duration.zero);

  static VCalendar _toCalendar(Calendar c) => VCalendar(
        id: c.id,
        name: c.name,
        iconName: c.icon,
        color: Color(c.color),
        isVisible: c.isVisible,
        sortOrder: c.sortOrder,
        defaultReminders: _minutes(c.defaultReminders),
        defaultDuration: c.defaultDuration == null
            ? null
            : Duration(minutes: c.defaultDuration!),
      );

  /// «30,1440» → [30, 1440]. Хранится строкой: список из двух чисел не стоит
  /// отдельной таблицы, а серверу строка едет как есть.
  ///
  /// `null` и пустая строка — разные вещи: первое значит «не настраивали»,
  /// второе — «молчать».
  static List<int>? _minutes(String? packed) {
    if (packed == null) return null;
    if (packed.trim().isEmpty) return const [];
    return [
      for (final part in packed.split(','))
        if (int.tryParse(part.trim()) != null) int.parse(part.trim()),
    ];
  }

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

  /// Поля и напоминания приезжают отдельными строками присоединения, поэтому
  /// садятся на событие уже после сборки.
  ///
  /// Напоминания идут от дальнего к ближнему («за час, за десять минут»):
  /// у равных строк порядка нет, а список читается человеком.
  static VEvent _withDetails(
    VEvent e, {
    List<VFieldValue>? fields,
    List<int>? reminders,
  }) {
    if (fields == null && reminders == null) return e;
    final sorted = reminders == null
        ? e.reminders
        : (reminders.toList()..sort((a, b) => b.compareTo(a)));

    return VEvent(
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
      fields: fields ?? e.fields,
      reminders: sorted,
    );
  }

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

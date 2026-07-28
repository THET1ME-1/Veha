import 'package:drift/drift.dart';

part 'database.g.dart';

/// Календарь — верхний уровень группировки и цвета.
class Calendars extends Table {
  /// UUID генерирует клиент: без этого календарь не создать офлайн.
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  /// Ушёл ли календарь на сервер. Личные не покидают устройство никогда.
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Напоминания по умолчанию: минуты через запятую. Пусто — календарь
  /// молчит. Учёба предупреждает за день, распорядок не предупреждает вовсе,
  /// и повторять этот выбор в каждом событии человек не должен.
  TextColumn get defaultReminders => text().nullable()();

  /// Длительность по умолчанию в минутах. Пусто — час, как раньше.
  IntColumn get defaultDuration => integer().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Удаление всегда мягкое: иначе сервер вернёт удалённое обратно при
  /// следующем синке. Физическая чистка — раз в 90 дней.
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ветка внутри календаря. `color` и `icon` пустые означают «взять у
/// календаря», а не скопированное вниз значение.
class Subcategories extends Table {
  TextColumn get id => text()();
  TextColumn get calendarId => text().references(Calendars, #id)();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()();
  TextColumn get calendarId => text().references(Calendars, #id)();
  TextColumn get subcategoryId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();

  /// UTC epoch ms. Часовой пояс хранится отдельно, чтобы событие не «поехало»
  /// при переезде или переводе часов.
  IntColumn get start => integer()();
  IntColumn get end => integer()();
  TextColumn get timezone => text()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get eventTypeId => text().nullable()();

  /// RFC 5545. Ряд не материализуется в базе: разворачивается только для
  /// видимого диапазона.
  TextColumn get rrule => text().nullable()();
  TextColumn get recurrenceId => text().nullable()();
  IntColumn get originalStart => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('confirmed'))();
  TextColumn get availability => text().withDefault(const Constant('busy'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Пропущенный экземпляр повторяющегося ряда.
class RecurrenceExceptions extends Table {
  TextColumn get eventId => text().references(Events, #id)();
  IntColumn get excludedDate => integer()();

  @override
  Set<Column> get primaryKey => {eventId, excludedDate};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  IntColumn get minutesBefore => integer()();
  TextColumn get method => text().withDefault(const Constant('notification'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Заметка внутри события — четвёртый уровень цвета.
class EventNotes extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();

  /// Не `text`: так называется метод самого Table, и колонка с этим именем
  /// перекрывает его.
  TextColumn get body => text()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Снимок, приложенный к событию.
///
/// Не уезжает на сервер: фотография — файл, а сервер хранит записи и отдаёт
/// дельты, хранилища файлов у него нет. Путь относительный от папки
/// приложения: абсолютный протухает после переустановки.
class EventPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get path => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Задача. Отличается от события отметкой выполнения и тем, что срок
/// необязателен: «когда-нибудь купить лампу» живёт в списке без даты.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get calendarId => text().references(Calendars, #id)();
  TextColumn get subcategoryId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();

  /// Срок. Пустой — задача без даты, она видна только в списке.
  IntColumn get due => integer().nullable()();

  /// У срока есть время, а не только день.
  BoolColumn get hasTime => boolean().withDefault(const Constant(false))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Определение своего поля. Принадлежит группе: `scopeId` пустой — поле общее.
class FieldDefs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get options => text().nullable()();
  TextColumn get icon => text().nullable()();

  /// `event_type`, `calendar` или `global`.
  TextColumn get scopeType => text().withDefault(const Constant('calendar'))();
  TextColumn get scopeId => text().nullable()();
  BoolColumn get showInCard => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FieldValues extends Table {
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get fieldId => text().references(FieldDefs, #id)();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {eventId, fieldId};
}

class EventTypes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get defaultDuration => integer().nullable()();
  TextColumn get defaultReminders => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Сохранённые пользователем цвета: доступны из любого пикера.
class SavedColors extends Table {
  TextColumn get id => text()();
  IntColumn get color => integer()();
  TextColumn get name => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Очередь изменений для синхронизации. Схлопывается: пять правок одного
/// события превращаются в одну запись.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Calendars,
    Subcategories,
    Events,
    RecurrenceExceptions,
    Reminders,
    EventNotes,
    EventPhotos,
    Tasks,
    FieldDefs,
    FieldValues,
    EventTypes,
    SavedColors,
    SyncQueue,
  ],
)
class VehaDatabase extends _$VehaDatabase {
  VehaDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Индексы из спеки: без них скролл месяца упирается в полный скан.
          await customStatement(
              'CREATE INDEX idx_events_calendar_start ON events (calendar_id, start)');
          await customStatement(
              'CREATE INDEX idx_events_range ON events (start, "end")');
          await customStatement(
              'CREATE INDEX idx_events_deleted ON events (deleted_at)');
          await customStatement(
              'CREATE INDEX idx_tasks_due ON tasks (due, completed_at)');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(eventPhotos);
            await m.createTable(tasks);
            await customStatement(
                'CREATE INDEX idx_tasks_due ON tasks (due, completed_at)');
          }
          if (from < 3) {
            await m.addColumn(calendars, calendars.defaultReminders);
            await m.addColumn(calendars, calendars.defaultDuration);
          }
        },
        beforeOpen: (details) async {
          // Внешние ключи в SQLite выключены по умолчанию, и мягкое удаление
          // без них разъедется с ветками.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

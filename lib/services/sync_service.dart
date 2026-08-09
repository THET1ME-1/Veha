import 'package:drift/drift.dart';

import '../data/db/database.dart';
import 'sync_api.dart';

/// Синхронизация: слить накопленное, забрать чужое, применить.
///
/// Работает поверх сырых запросов, а не типизированных таблиц drift. Так
/// решено намеренно: строк девяти таблиц, и писать восемь пар «объект →
/// колонки» значит завести восемь мест, где схема может разойтись с сервером.
/// Имена колонок в обеих базах одинаковые, поэтому строка переносится как есть.
class SyncService {
  SyncService({required this.db, required this.api});

  final VehaDatabase db;
  final SyncApi api;

  /// Таблицы, которые ездят между устройствами, и их имена на сервере.
  static const tables = <String, String>{
    'calendars': 'calendars',
    'subcategories': 'subcategories',
    'events': 'events',
    'reminders': 'reminders',
    'event_notes': 'notes',
    'field_defs': 'field_defs',
    'field_values': 'field_values',
    'recurrence_exceptions': 'recurrence_exceptions',
    'tasks': 'tasks',
  };

  /// Обратное соответствие: с сервера имя приходит его.
  static final _localOf = {
    for (final entry in tables.entries) entry.value: entry.key,
  };

  /// Потолок страниц за один круг. Пятьсот строк на страницу — это полмиллиона
  /// строк за заход: больше человеческого календаря на порядки, а зациклиться
  /// на сломанном сервере круг не должен.
  static const _maxPages = 1000;

  /// Сколько правок ждёт отправки. Этим живёт строка состояния в настройках:
  /// «не синхронизировано, 12 изменений ждут» честнее крутящегося кружка.
  Future<int> pendingCount() async {
    final rows = await db
        .customSelect('SELECT COUNT(*) AS n FROM sync_queue')
        .get();
    return rows.first.read<int>('n');
  }

  /// Полный круг: отправили своё, забрали чужое, применили.
  ///
  /// Порядок именно такой. Заберёшь сначала — свои несохранённые правки
  /// проиграют чужим по времени, хотя человек сделал их последними.
  Future<SyncOutcome> run({
    required String token,
    required int since,
  }) async {
    final queue = await db
        .customSelect('SELECT id, entity_type, entity_id, operation FROM sync_queue'
            ' ORDER BY id')
        .get();

    final changes = <String, List<Map<String, Object?>>>{};
    final sent = <int>[];

    for (final row in queue) {
      final local = _tableOf(row.read<String>('entity_type'));
      if (local == null) continue;

      final id = row.read<String>('entity_id');
      final found = await db
          .customSelect('SELECT * FROM $local WHERE id = ?',
              variables: [Variable<String>(id)])
          .get();
      if (found.isEmpty) {
        // Строка исчезла из базы совсем — чистка старых удалений уже прошла.
        // Отправлять нечего, но и держать запись в очереди незачем.
        sent.add(row.read<int>('id'));
        continue;
      }

      final remote = tables[local]!;
      final data = found.first.data;
      changes.putIfAbsent(remote, () => []).add(_toRemote(data));
      sent.add(row.read<int>('id'));

      // Напоминания, значения полей и пропуски ряда лежат в своих таблицах и
      // в очередь не попадают: они принадлежат событию, а не сами по себе.
      // Поэтому едут вместе с ним — иначе на другом устройстве событие
      // появится голым.
      if (local == 'events') {
        await _collectChildren(id, data['updated_at'] as int?, changes);
      }
    }

    final pushed = changes.isEmpty
        ? const PushResult(cursor: 0, applied: 0, skipped: 0)
        : await api.push(token, changes);

    if (sent.isNotEmpty) {
      await db.customStatement(
        'DELETE FROM sync_queue WHERE id IN (${sent.join(',')})',
      );
    }

    // Дельта приходит страницами: сервер отдаёт не больше пятисот строк на
    // таблицу. Импорт расписания — тысячи занятий, и один заход оставлял
    // хвост за курсором навсегда. Крутим, пока курсор растёт; остановка по
    // нему же страхует от вечного круга, если сервер перестанет двигаться.
    var mark = since;
    var applied = 0;
    for (var page = 0; page < _maxPages; page++) {
      final pulled = await api.pull(token, mark);
      applied += await _apply(pulled.changes);
      if (pulled.cursor <= mark) break;
      mark = pulled.cursor;
    }

    return SyncOutcome(
      cursor: mark,
      sent: changes.values.fold(0, (sum, rows) => sum + rows.length),
      received: applied,
      rejected: pushed.skipped,
    );
  }

  /// Дочерние строки события. У части из них нет ни своего ключа, ни времени
  /// правки: на клиенте они опознаются парой колонок. Ключ и метки собираются
  /// здесь — серверу нужна строка целиком.
  Future<void> _collectChildren(
    String eventId,
    int? updatedAt,
    Map<String, List<Map<String, Object?>>> changes,
  ) async {
    final stamp = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

    Future<void> take(
      String local,
      String remote,
      String Function(Map<String, Object?> row) idOf,
    ) async {
      final rows = await db
          .customSelect('SELECT * FROM $local WHERE event_id = ?',
              variables: [Variable<String>(eventId)])
          .get();
      for (final row in rows) {
        final data = Map<String, Object?>.from(row.data);
        final out = _toRemote(data);
        out['id'] ??= idOf(data);
        out['createdAt'] ??= stamp;
        out['updatedAt'] ??= stamp;
        changes.putIfAbsent(remote, () => []).add(out);
      }
    }

    await take('reminders', 'reminders', (row) => row['id'].toString());
    await take(
      'field_values',
      'field_values',
      (row) => '${row['event_id']}:${row['field_id']}',
    );
    await take(
      'recurrence_exceptions',
      'recurrence_exceptions',
      (row) => '${row['event_id']}:${row['excluded_date']}',
    );
    await take('event_notes', 'notes', (row) => row['id'].toString());
  }

  /// Сущность очереди → таблица. Очередь называет их по-своему («event»,
  /// «calendar»), потому что писалась до сервера.
  String? _tableOf(String entityType) => switch (entityType) {
        'calendar' => 'calendars',
        'subcategory' => 'subcategories',
        'event' => 'events',
        'note' => 'event_notes',
        'field' => 'field_defs',
        'task' => 'tasks',
        _ => null,
      };

  /// Строка в вид сервера: колонки `snake_case` становятся `camelCase`.
  Map<String, Object?> _toRemote(Map<String, Object?> row) => {
        for (final entry in row.entries) _camel(entry.key): entry.value,
      };

  Future<int> _apply(Map<String, List<Map<String, Object?>>> changes) async {
    var count = 0;
    for (final entry in changes.entries) {
      final local = _localOf[entry.key];
      if (local == null) continue;

      final columns = await _columnsOf(local);
      for (final remote in entry.value) {
        final row = <String, Object?>{};
        for (final field in remote.entries) {
          final column = _snake(field.key);
          // Чужих колонок у клиента нет: `user_id` и `version` — дело сервера.
          if (!columns.contains(column)) continue;
          row[column] = _sqlValue(field.value);
        }
        if (row['id'] == null) continue;

        // Конфликт разрешается по времени правки: побеждает более позднее.
        // Без этой проверки версия, сделанная на сервере раньше, затирала
        // свежую местную — человек правил событие без сети, а после синка
        // видел чужой текст и не мог понять, куда делась его правка.
        if (!await _isNewer(local, row)) continue;

        final names = row.keys.join(', ');
        final marks = List.filled(row.length, '?').join(', ');
        await db.customStatement(
          'INSERT OR REPLACE INTO $local ($names) VALUES ($marks)',
          row.values.toList(),
        );
        count++;
      }
    }
    return count;
  }

  /// Свежее ли приехавшее, чем то, что уже лежит в базе.
  ///
  /// Записи без времени правки (пропуски ряда, значения полей) сравнивать не
  /// по чему — их применяем как есть: они принадлежат событию и приезжают
  /// вместе с ним.
  Future<bool> _isNewer(String table, Map<String, Object?> row) async {
    final incoming = row['updated_at'];
    if (incoming is! int) return true;

    final columns = await _columnsOf(table);
    if (!columns.contains('updated_at')) return true;

    final found = await db.customSelect(
      'SELECT updated_at FROM $table WHERE id = ?',
      variables: [Variable<Object>(row['id']!)],
    ).get();
    if (found.isEmpty) return true;

    final mine = found.first.read<int?>('updated_at') ?? 0;
    // Равенство отдаём приезжему: одинаковое время означает одну и ту же
    // правку, вернувшуюся кругом, и разницы нет.
    return incoming >= mine;
  }

  final Map<String, Set<String>> _columnCache = {};

  Future<Set<String>> _columnsOf(String table) async {
    final cached = _columnCache[table];
    if (cached != null) return cached;

    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    final columns = {for (final row in rows) row.read<String>('name')};
    _columnCache[table] = columns;
    return columns;
  }

  /// JSON знает `true`, SQLite — нет.
  Object? _sqlValue(Object? value) => switch (value) {
        bool b => b ? 1 : 0,
        _ => value,
      };

  static String _camel(String value) {
    final parts = value.split('_');
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
  }

  static String _snake(String value) => value
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
}

/// Что случилось за круг. Показывается человеку: «отправлено 3, получено 12».
class SyncOutcome {
  const SyncOutcome({
    required this.cursor,
    required this.sent,
    required this.received,
    required this.rejected,
  });

  final int cursor;
  final int sent;
  final int received;

  /// Сколько правок сервер отклонил как устаревшие.
  final int rejected;
}

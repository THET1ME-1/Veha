import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/services/sync_api.dart';
import 'package:veha/services/sync_service.dart';

import 'sqlite_for_tests.dart';

/// Правки поверх приехавшего с сервера.
///
/// Расписание приезжает синхронизацией, а не заводится руками, и строки
/// ложатся в базу напрямую, минуя репозиторий. Проверяем, что удаление и
/// правка такого события держатся: человек удалил занятие, увидел «Удалено»,
/// а оно вернулось — это выглядит как сломанное приложение.
class _Api implements SyncApi {
  _Api(this.rows);

  final List<Map<String, Object?>> rows;
  int cursor = 100;
  Map<String, List<Map<String, Object?>>> lastPush = {};

  /// Что ещё приезжает вместе с событиями: определения полей и их значения.
  Map<String, List<Map<String, Object?>>> extra = {};

  @override
  Future<PushResult> push(
    String token,
    Map<String, List<Map<String, Object?>>> changes,
  ) async {
    lastPush = changes;
    return const PushResult(cursor: 100, applied: 1, skipped: 0);
  }

  @override
  Future<PullResult> pull(String token, int since) async {
    if (since >= cursor) {
      return PullResult(cursor: cursor, changes: const {});
    }
    return PullResult(
      cursor: cursor,
      changes: {'events': rows, ...extra},
    );
  }

  @override
  Future<DeviceCredentials> register(String deviceName) async =>
      const DeviceCredentials(userId: 'u', token: 'dev_x');

  @override
  Future<DeviceCredentials> claim(String code, String deviceName) async =>
      const DeviceCredentials(userId: 'u', token: 'dev_y');

  @override
  Future<String> pairCode(String token) async => 'ABC123';

  @override
  Future<List<AgentKey>> tokens(String token) async => const [];

  @override
  Future<AgentKeyCreated> createToken(
    String token, {
    required String name,
    required List<KeyScope> scopes,
    int? expiresAt,
  }) async =>
      const AgentKeyCreated(id: 'k', token: 'cal_x');

  @override
  Future<void> revokeToken(String token, String id) async {}

  @override
  Future<List<KeyAction>> tokenLog(String token, String id) async => const [];
}

void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  /// Строка события в том виде, в каком её отдаёт сервер.
  Map<String, Object?> remote({
    required String id,
    String? rrule,
    String title = 'Тренировка в зале',
  }) =>
      {
        'id': id,
        'userId': 'u',
        'version': 7,
        'calendarId': 'default',
        'subcategoryId': null,
        'title': title,
        'description': null,
        'location': 'Зал',
        'start': DateTime(2026, 8, 10, 18).millisecondsSinceEpoch,
        'end': DateTime(2026, 8, 10, 19).millisecondsSinceEpoch,
        'timezone': 'Europe/Chisinau',
        'isAllDay': false,
        'color': null,
        'icon': 'fitness_center',
        'rrule': rrule,
        'recurrenceId': null,
        'originalStart': null,
        'travelMinutes': null,
        'createdAt': 1,
        'updatedAt': 2,
        'deletedAt': null,
      };

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
    await repo.setCalendarShared('default', true);
  });

  tearDown(() => db.close());

  test('Приехавшее событие удаляется насовсем', () async {
    final api = _Api([remote(id: 'from-server')]);
    final sync = SyncService(db: db, api: api);
    await sync.run(token: 'dev_x', since: 0);

    final before = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 11))
        .first;
    expect(before.map((e) => e.id), contains('from-server'));

    await repo.deleteEvent('from-server');

    final after = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 11))
        .first;
    expect(after.map((e) => e.id), isNot(contains('from-server')));

    // Второй круг синхронизации: сервер о правке ещё не знает и отдаёт
    // прежнюю строку. Удалённое обязано остаться удалённым.
    await sync.run(token: 'dev_x', since: 0);

    final again = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 11))
        .first;
    expect(again.map((e) => e.id), isNot(contains('from-server')));
    expect(api.lastPush['events'], isNotNull);
  });

  test('Отменённое занятие ряда не возвращается синхронизацией', () async {
    final api = _Api([
      remote(id: 'series', rrule: 'FREQ=WEEKLY;BYDAY=MO;INTERVAL=1'),
    ]);
    final sync = SyncService(db: db, api: api);
    await sync.run(token: 'dev_x', since: 0);

    final week = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 25))
        .first;
    expect(week.length, greaterThan(1));

    final second = week[1];
    await repo.cancelOccurrence('series', second.originalStart ?? second.start);

    final afterCancel = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 25))
        .first;
    expect(afterCancel.length, week.length - 1);

    await sync.run(token: 'dev_x', since: 0);

    final afterSync = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 25))
        .first;
    expect(afterSync.length, week.length - 1);
  });

  test('Событие со своим полем удаляется и правится', () async {
    // У расписания к каждому занятию приезжает «Кабинет». Значение поля
    // ссылается на событие, и переписывание строки события задевает его.
    final api = _Api([remote(id: 'with-field')]);
    api.extra = {
      'field_defs': [
        {
          'id': 'f-room',
          'userId': 'u',
          'version': 7,
          'name': 'Кабинет',
          'type': 'text',
          'icon': 'meeting_room',
          'scopeId': 'default',
          'showInCard': true,
          'sortOrder': 0,
          'createdAt': 1,
          'updatedAt': 2,
          'deletedAt': null,
        },
      ],
      'field_values': [
        {
          'id': 'v-1',
          'userId': 'u',
          'version': 7,
          'eventId': 'with-field',
          'fieldId': 'f-room',
          'value': '247/4',
          'createdAt': 1,
          'updatedAt': 2,
          'deletedAt': null,
        },
      ],
    };

    final sync = SyncService(db: db, api: api);
    await sync.run(token: 'dev_x', since: 0);

    final loaded = await repo.eventById('with-field');
    expect(loaded, isNotNull);

    await repo.upsertEvent(loaded!.copyWith(title: 'Правка'));
    expect((await repo.eventById('with-field'))?.title, 'Правка');

    await repo.deleteEvent('with-field');
    final after = await repo
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 11))
        .first;
    expect(after.map((e) => e.id), isNot(contains('with-field')));
  });

  test('Правка приехавшего события переживает синхронизацию', () async {
    final api = _Api([remote(id: 'from-server')]);
    final sync = SyncService(db: db, api: api);
    await sync.run(token: 'dev_x', since: 0);

    final loaded = await repo.eventById('from-server');
    await repo.upsertEvent(loaded!.copyWith(title: 'Зал перенесён'));

    await sync.run(token: 'dev_x', since: 0);

    final after = await repo.eventById('from-server');
    expect(after?.title, 'Зал перенесён');
  });
}

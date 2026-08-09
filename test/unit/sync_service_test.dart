import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/services/sync_api.dart';
import 'package:veha/services/sync_service.dart';

import 'sqlite_for_tests.dart';

/// Синхронизация проверяется без сети: сервер подменяется подделкой, а логика
/// «слить очередь → забрать чужое → применить» гоняется целиком.
class _FakeApi implements SyncApi {
  Map<String, List<Map<String, Object?>>> pushed = {};
  Map<String, List<Map<String, Object?>>> incoming = {};
  int cursor = 7;
  int skipped = 0;

  /// Страницы дельты, если сервер отдаёт её не за один заход. Пусто — работает
  /// обычная выдача из [incoming].
  List<PullResult> pages = [];
  final List<int> asked = [];

  @override
  Future<PushResult> push(
    String token,
    Map<String, List<Map<String, Object?>>> changes,
  ) async {
    pushed = changes;
    return PushResult(cursor: cursor, applied: 1, skipped: skipped);
  }

  @override
  Future<PullResult> pull(String token, int since) async {
    asked.add(since);
    if (pages.isNotEmpty) {
      return pages.firstWhere(
        (page) => page.cursor > since,
        orElse: () => PullResult(cursor: since, changes: const {}),
      );
    }
    // Дельта берётся строго после курсора: догнавшее устройство получает
    // пустой ответ, а не те же строки по второму разу.
    if (since >= cursor) return PullResult(cursor: cursor, changes: const {});
    return PullResult(cursor: cursor, changes: incoming);
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
  late _FakeApi api;
  late SyncService sync;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    api = _FakeApi();
    sync = SyncService(db: db, api: api);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
    // Очередь наполняется только для общих календарей.
    await repo.setCalendarShared('default', true);
  });

  tearDown(() => db.close());

  test('Накопленное уходит на сервер и очередь пустеет', () async {
    await repo.upsertEvent(VEvent(
      id: 'e1',
      calendarId: 'default',
      title: 'Планёрка',
      start: DateTime(2026, 8, 3, 10),
      end: DateTime(2026, 8, 3, 11),
    ));
    expect(await sync.pendingCount(), greaterThan(0));

    final outcome = await sync.run(token: 'dev_x', since: 0);

    expect(api.pushed['events'], hasLength(1));
    expect(api.pushed['events']!.first['title'], 'Планёрка');
    // Колонки уезжают в виде сервера: `calendar_id` → `calendarId`.
    expect(api.pushed['events']!.first.containsKey('calendarId'), isTrue);
    expect(outcome.sent, greaterThan(0));
    expect(await sync.pendingCount(), 0);
  });

  test('Чужое событие приезжает и видно в дне', () async {
    api.incoming = {
      'events': [
        {
          'id': 'remote-1',
          'userId': 'u',
          'version': 5,
          'calendarId': 'default',
          'title': 'С другого устройства',
          'start': DateTime(2026, 8, 3, 12).millisecondsSinceEpoch,
          'end': DateTime(2026, 8, 3, 13).millisecondsSinceEpoch,
          'timezone': 'UTC',
          'isAllDay': false,
          'createdAt': 1,
          'updatedAt': 2,
          'deletedAt': null,
        },
      ],
    };

    final outcome = await sync.run(token: 'dev_x', since: 0);
    expect(outcome.received, 1);
    expect(outcome.cursor, 7);

    final day = await repo
        .watchRange(DateTime(2026, 8, 3), DateTime(2026, 8, 4))
        .first;
    expect(day.map((e) => e.title), contains('С другого устройства'));
  });

  test('Дельта в несколько страниц забирается целиком', () async {
    // Сервер режет выдачу по 500 строк. Импорт расписания больше страницы, и
    // один заход оставил бы хвост за курсором: он двигается вперёд, а
    // непрочитанное после него уже не запросят.
    Map<String, Object?> event(int i) => {
          'id': 'remote-$i',
          'userId': 'u',
          'version': i,
          'calendarId': 'default',
          'title': 'Занятие $i',
          'start': DateTime(2026, 8, 3, 9).millisecondsSinceEpoch,
          'end': DateTime(2026, 8, 3, 10).millisecondsSinceEpoch,
          'timezone': 'UTC',
          'isAllDay': false,
          'createdAt': 1,
          'updatedAt': 2,
          'deletedAt': null,
        };

    api.pages = [
      PullResult(cursor: 3, changes: {
        'events': [event(1), event(2), event(3)],
      }),
      PullResult(cursor: 5, changes: {
        'events': [event(4), event(5)],
      }),
    ];

    final outcome = await sync.run(token: 'dev_x', since: 0);

    expect(outcome.received, 5);
    expect(outcome.cursor, 5);
    expect(api.asked, [0, 3, 5]);

    final day = await repo
        .watchRange(DateTime(2026, 8, 3), DateTime(2026, 8, 4))
        .first;
    expect(day, hasLength(5));
  });

  test('Чужие колонки не роняют применение', () async {
    // `userId` и `version` — дело сервера, у клиента таких колонок нет.
    api.incoming = {
      'calendars': [
        {
          'id': 'cal-remote',
          'userId': 'u',
          'version': 9,
          'name': 'Общий',
          'color': 0xff41ccb5,
          'icon': 'calendar',
          'isVisible': true,
          'isShared': true,
          'sortOrder': 3,
          'createdAt': 1,
          'updatedAt': 2,
          'deletedAt': null,
        },
      ],
    };

    await sync.run(token: 'dev_x', since: 0);

    final inheritance = await repo.loadInheritance();
    expect(inheritance.calendars['cal-remote']?.name, 'Общий');
  });

  test('Удаление с сервера убирает событие из видов', () async {
    await repo.upsertEvent(VEvent(
      id: 'e2',
      calendarId: 'default',
      title: 'Уедет',
      start: DateTime(2026, 8, 4, 10),
      end: DateTime(2026, 8, 4, 11),
    ));

    // Удаление на сервере случилось после того, как событие завели здесь:
    // конфликт разрешается по времени правки, и версия из прошлого местную
    // запись не тронет.
    final removedAt = DateTime.now().millisecondsSinceEpoch + 60000;
    api.incoming = {
      'events': [
        {
          'id': 'e2',
          'calendarId': 'default',
          'title': 'Уедет',
          'start': DateTime(2026, 8, 4, 10).millisecondsSinceEpoch,
          'end': DateTime(2026, 8, 4, 11).millisecondsSinceEpoch,
          'timezone': 'UTC',
          'createdAt': 1,
          'updatedAt': removedAt,
          'deletedAt': removedAt,
        },
      ],
    };

    await sync.run(token: 'dev_x', since: 0);

    final day = await repo
        .watchRange(DateTime(2026, 8, 4), DateTime(2026, 8, 5))
        .first;
    expect(day.where((e) => e.id == 'e2'), isEmpty);
  });

  test('Отклонённые сервером правки видно в ответе', () async {
    api.skipped = 2;
    await repo.upsertEvent(VEvent(
      id: 'e3',
      calendarId: 'default',
      title: 'Старьё',
      start: DateTime(2026, 8, 5, 10),
      end: DateTime(2026, 8, 5, 11),
    ));

    final outcome = await sync.run(token: 'dev_x', since: 0);
    expect(outcome.rejected, 2);
  });
}

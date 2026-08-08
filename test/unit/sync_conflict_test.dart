import 'package:drift/drift.dart' show DatabaseConnection, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/services/sync_api.dart';
import 'package:veha/services/sync_service.dart';

import 'sqlite_for_tests.dart';

/// Конфликт правок: побеждает более позднее `updated_at`.
///
/// Правило из ТЗ, и цена ошибки — потерянная правка. Человек поправил событие
/// в метро без сети, а следом приехала версия с сервера, сделанная раньше:
/// без сравнения времени она затирает свежую, и заметить это невозможно —
/// в базе просто оказывается чужой текст.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
  });

  tearDown(() => db.close());

  /// Событие с заданным временем правки — как его отдал бы сервер.
  Map<String, Object?> remoteEvent({
    required String title,
    required int updatedAt,
  }) =>
      {
        'id': 'e1',
        'calendarId': 'default',
        'title': title,
        'start': DateTime(2026, 7, 27, 10).millisecondsSinceEpoch,
        'end': DateTime(2026, 7, 27, 11).millisecondsSinceEpoch,
        'timezone': 'Europe/Chisinau',
        'createdAt': 1,
        'updatedAt': updatedAt,
      };

  Future<String> titleInBase() async {
    final row = await db
        .customSelect('SELECT title FROM events WHERE id = ?',
            variables: [Variable<String>('e1')])
        .getSingle();
    return row.read<String>('title');
  }

  Future<int> updatedInBase() async {
    final row = await db
        .customSelect('SELECT updated_at FROM events WHERE id = ?',
            variables: [Variable<String>('e1')])
        .getSingle();
    return row.read<int>('updated_at');
  }

  test('Свежая местная правка переживает приезд старой версии', () async {
    await repo.upsertEvent(VEvent(
      id: 'e1',
      calendarId: 'default',
      title: 'Мой текст',
      start: DateTime(2026, 7, 27, 10),
      end: DateTime(2026, 7, 27, 11),
    ));
    final mine = await updatedInBase();

    final service = SyncService(db: db, api: _FakeApi([
      remoteEvent(title: 'Старый текст с сервера', updatedAt: mine - 60000),
    ]));
    await service.run(token: 't', since: 0);

    expect(await titleInBase(), 'Мой текст',
        reason: 'старая версия с сервера затёрла свежую местную правку');
  });

  test('Более поздняя версия с сервера применяется', () async {
    await repo.upsertEvent(VEvent(
      id: 'e1',
      calendarId: 'default',
      title: 'Мой текст',
      start: DateTime(2026, 7, 27, 10),
      end: DateTime(2026, 7, 27, 11),
    ));
    final mine = await updatedInBase();

    final service = SyncService(db: db, api: _FakeApi([
      remoteEvent(title: 'Свежее с сервера', updatedAt: mine + 60000),
    ]));
    await service.run(token: 't', since: 0);

    expect(await titleInBase(), 'Свежее с сервера');
  });
}

/// Сервер, который отдаёт заданные записи и молча принимает отправку.
class _FakeApi implements SyncApi {
  _FakeApi(this.events);

  final List<Map<String, Object?>> events;

  @override
  Future<PullResult> pull(String token, int since) async =>
      PullResult(cursor: 1, changes: {'events': events});

  @override
  Future<PushResult> push(
    String token,
    Map<String, List<Map<String, Object?>>> changes,
  ) async =>
      const PushResult(cursor: 1, applied: 0, skipped: 0);

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

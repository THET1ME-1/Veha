@Tags(['live'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/services/sync_api.dart';
import 'package:veha/services/sync_service.dart';

import 'sqlite_for_tests.dart';

/// Проверка на живом сервере: те же строки, что приезжают на телефон.
///
/// Запуск руками, в общий прогон не входит:
///   flutter test test/unit/live_pull_test.dart --tags live
void main() {
  setUpAll(useSystemSqlite);

  test('Удалённое на сервере не показывается в календаре', () async {
    final db = VehaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = VehaRepository(db);

    final api = HttpSyncApi(baseUrl: 'https://veha-server.badzoff.workers.dev');
    final sync = SyncService(db: db, api: api);

    final outcome = await sync.run(
      token: 'dev_gjpvs6pzpibzma2wmakqit33g7n3zv8n',
      since: 0,
    );
    // ignore: avoid_print
    print('получено строк: ${outcome.received}, курсор: ${outcome.cursor}');

    final live = await db
        .customSelect('SELECT COUNT(*) AS n FROM events WHERE deleted_at IS NULL')
        .getSingle();
    final gone = await db
        .customSelect('SELECT COUNT(*) AS n FROM events WHERE deleted_at IS NOT NULL')
        .getSingle();
    // ignore: avoid_print
    print('в базе живых: ${live.read<int>('n')}, удалённых: ${gone.read<int>('n')}');

    final sea = await db
        .customSelect("SELECT id, deleted_at FROM events WHERE title LIKE '%Море%'")
        .get();
    // ignore: avoid_print
    print('строк «Море»: ${sea.length}, '
        'из них удалённых: ${sea.where((r) => r.data['deleted_at'] != null).length}');

    // Календарь за август: «Море» повторялось ежедневно до 28 августа.
    final shown = await repo.eventsBetween(
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 31),
    );
    final seaShown = shown.where((e) => e.title.contains('Море')).toList();
    // ignore: avoid_print
    print('«Море» в календаре: ${seaShown.length}');

    expect(seaShown, isEmpty);
  });
}

@Tags(['live'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/services/sync_api.dart';
import 'package:veha/services/sync_service.dart';

import 'sqlite_for_tests.dart';

/// Проверка на живом сервере: доезжают ли свои поля до устройства.
///
///   flutter test test/unit/live_fields_test.dart --tags live
void main() {
  setUpAll(useSystemSqlite);

  test('Кабинет приезжает с боевого сервера', () async {
    final db = VehaDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final sync = SyncService(
      db: db,
      api: HttpSyncApi(baseUrl: 'https://veha-server.badzoff.workers.dev'),
    );
    final outcome = await sync.run(
      token: 'dev_gjpvs6pzpibzma2wmakqit33g7n3zv8n',
      since: 0,
    );

    final values = await db
        .customSelect('SELECT COUNT(*) AS n FROM field_values')
        .getSingle();
    final exam = await db.customSelect(
      "SELECT fv.value FROM field_values fv"
      " JOIN events e ON e.id = fv.event_id"
      " JOIN field_defs fd ON fd.id = fv.field_id"
      " WHERE e.title LIKE '%Экзамен] Операционные%' AND fd.name = 'Кабинет'",
    ).get();

    // ignore: avoid_print
    print('получено строк: ${outcome.received}, '
        'значений полей в базе: ${values.read<int>('n')}, '
        'кабинет экзамена: ${exam.map((r) => r.data['value']).toList()}');

    expect(values.read<int>('n'), greaterThan(100));
    expect(exam.map((r) => r.data['value']), contains('421b/4'));
  });
}

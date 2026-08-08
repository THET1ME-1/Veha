import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/providers.dart';

import 'sqlite_for_tests.dart';

/// Уборка корзины: раз в сутки, а не на каждом запуске.
///
/// ТЗ обещает холодный старт под 500 мс, а чистка шла до первого кадра и
/// перебирала четыре таблицы построчно. Календарь открывают по десять раз в
/// день — девять из них эта работа была впустую.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = VehaDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      seedLanguageProvider.overrideWithValue('ru'),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('Запуск приложения не ждёт уборку', () async {
    await container.read(bootstrapProvider.future);

    // Календарь есть, экран строить можно — а уборка ещё даже не начиналась.
    final tree = await container.read(inheritanceProvider.future);
    expect(tree.calendars, isNotEmpty);
    expect(container.read(purgeProvider), isA<AsyncLoading<int>>());
  });

  test('Второй запуск за сутки не убирает повторно', () async {
    await container.read(purgeProvider.future);

    // Отметка о вчерашней уборке уже стоит: следующий заход обязан промолчать.
    container.invalidate(purgeProvider);
    expect(await container.read(purgeProvider.future), 0);
  });
}

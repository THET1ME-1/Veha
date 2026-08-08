import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/providers.dart';

import 'sqlite_for_tests.dart';

/// Сторож памяти календаря.
///
/// Окно событий — семейство по паре дат, и каждый свайп заводит в нём новый
/// ключ. Пока ключи не убираются за собой, месяц листания оставляет три
/// десятка живых подписок на базу, и любая правка события будит их все разом:
/// приложение тем медленнее, чем дольше им пользуются.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late ProviderContainer container;

  setUp(() {
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

  /// Сколько окон событий держится в памяти прямо сейчас.
  int aliveRanges() => container
      .getAllProviderElements()
      .where((e) => identical(e.origin.from, rangeProvider))
      .length;

  /// Один свайп: экран подписался на своё окно, показал его и ушёл к соседнему.
  Future<void> swipeTo(DateTime day) async {
    final range = (from: day, to: day.add(const Duration(days: 1)));
    final sub = container.listen(rangeProvider(range), (_, __) {});
    await container.read(rangeProvider(range).future);
    sub.close();
    // Отписка освобождает окно на следующем обороте цикла, не в тот же миг.
    await Future<void>.delayed(Duration.zero);
  }

  test('Месяц листания не оставляет за собой живых окон', () async {
    final start = DateTime(2026, 7, 27);
    for (var i = 0; i < 30; i++) {
      await swipeTo(start.add(Duration(days: i)));
    }

    // Одно окно на экране плюс запас на соседнее — всё, что имеет право
    // пережить листание.
    expect(aliveRanges(), lessThanOrEqualTo(2));
  });

  test('Возврат на прежний день не заводит второе окно', () async {
    final day = DateTime(2026, 7, 27);
    await swipeTo(day);
    await swipeTo(day.add(const Duration(days: 1)));
    await swipeTo(day);

    expect(aliveRanges(), lessThanOrEqualTo(2));
  });
}

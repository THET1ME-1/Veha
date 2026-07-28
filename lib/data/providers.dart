import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/connection.dart';
import 'db/database.dart';
import 'models.dart';
import 'repository.dart';

/// База живёт всё время работы приложения: пересоздавать соединение на каждый
/// экран дороже, чем держать одно.
final databaseProvider = Provider<VehaDatabase>((ref) {
  final db = VehaDatabase(openConnection());
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<VehaRepository>(
  (ref) => VehaRepository(ref.watch(databaseProvider)),
);

/// Сегодняшний день одной точкой на всё приложение: экраны, демо-данные и
/// снимки экранов должны сходиться в одном «сейчас», иначе golden-тесты
/// начинают зависеть от календаря машины.
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

/// Первый запуск: наполняем пустую базу и только потом отдаём экраны.
final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(repositoryProvider).seedIfEmpty(today: ref.watch(nowProvider));
});

/// Календари и ветки. Нужны на каждом экране, поэтому держатся отдельно от
/// потока событий.
final inheritanceProvider = FutureProvider<Inheritance>((ref) async {
  await ref.watch(bootstrapProvider.future);
  return ref.watch(repositoryProvider).loadInheritance();
});

/// События целого диапазона, разложенные по дням: этим живут неделя, месяц и
/// лента дней. Разложить один раз дешевле, чем на каждой ячейке фильтровать
/// общий список заново.
final rangeProvider =
    StreamProvider.family<RangeData, ({DateTime from, DateTime to})>(
  (ref, range) async* {
    await ref.watch(bootstrapProvider.future);

    final repo = ref.watch(repositoryProvider);
    await for (final events in repo.watchRange(range.from, range.to)) {
      final byDay = <DateTime, List<VEvent>>{};
      final spans = <VEvent>[];

      for (final e in events) {
        if (e.isMultiDay) {
          spans.add(e);
          continue;
        }
        final key = DateTime(e.start.year, e.start.month, e.start.day);
        byDay.putIfAbsent(key, () => []).add(e);
      }

      for (final day in byDay.values) {
        day.sort((a, b) => a.start.compareTo(b.start));
      }
      // Недавно начатые полосы выше: абонемент на месяц актуальнее курса,
      // идущего с июня.
      spans.sort((a, b) => b.start.compareTo(a.start));

      yield RangeData(byDay: byDay, spans: spans);
    }
  },
);

class RangeData {
  const RangeData({required this.byDay, required this.spans});

  final Map<DateTime, List<VEvent>> byDay;
  final List<VEvent> spans;

  List<VEvent> eventsOn(DateTime day) =>
      byDay[DateTime(day.year, day.month, day.day)] ?? const [];

  /// Полосы, накрывающие день: абонемент на месяц висит над каждым днём
  /// месяца, а не только над первым.
  List<VEvent> spansOn(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return [
      for (final e in spans)
        if (e.start.isBefore(end) && e.end.isAfter(start)) e,
    ];
  }

  static const empty = RangeData(byDay: {}, spans: []);
}

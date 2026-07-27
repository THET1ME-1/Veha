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

/// Первый запуск: наполняем пустую базу и только потом отдаём экраны.
final bootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(repositoryProvider).seedIfEmpty();
});

/// Календари и ветки. Нужны на каждом экране, поэтому держатся отдельно от
/// потока событий.
final inheritanceProvider = FutureProvider<Inheritance>((ref) async {
  await ref.watch(bootstrapProvider.future);
  return ref.watch(repositoryProvider).loadInheritance();
});

/// События за период. Диапазон — параметр: экраны просят ровно то окно,
/// которое рисуют, плюс запас.
final eventsProvider =
    StreamProvider.family<List<VEvent>, ({DateTime from, DateTime to})>(
  (ref, range) async* {
    await ref.watch(bootstrapProvider.future);
    yield* ref.watch(repositoryProvider).watchRange(range.from, range.to);
  },
);

/// События одного дня и многодневные, которые его захватывают, разделены:
/// многодневным место над таймлайном, а не в сетке часов.
final dayProvider = StreamProvider.family<DayData, DateTime>((ref, day) async* {
  final from = DateTime(day.year, day.month, day.day);
  final to = from.add(const Duration(days: 1));
  await ref.watch(bootstrapProvider.future);

  final repo = ref.watch(repositoryProvider);
  await for (final events in repo.watchRange(from, to)) {
    yield DayData(
      timed: [
        for (final e in events)
          if (!e.isMultiDay) e,
      ]..sort((a, b) => a.start.compareTo(b.start)),
      // Недавно начатые полосы выше: абонемент на месяц актуальнее курса,
      // идущего с июня.
      spans: [
        for (final e in events)
          if (e.isMultiDay) e,
      ]..sort((a, b) => b.start.compareTo(a.start)),
    );
  }
});

class DayData {
  const DayData({required this.timed, required this.spans});

  final List<VEvent> timed;
  final List<VEvent> spans;
}

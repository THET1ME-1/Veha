import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reminder_plan.dart';
import '../services/reminder_service.dart';
import 'db/connection.dart';
import 'db/database.dart';
import 'models.dart';
import 'repository.dart';
import 'seed_words.dart';

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

/// Язык первого календаря. Переопределяется в тестах: снимки экранов
/// сверяются с русским макетом.
final seedLanguageProvider = Provider<String>(
  (ref) => PlatformDispatcher.instance.locale.languageCode,
);

/// Сегодняшний день одной точкой на всё приложение: экраны, демо-данные и
/// снимки экранов должны сходиться в одном «сейчас», иначе golden-тесты
/// начинают зависеть от календаря машины.
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

/// Первый запуск: наполняем пустую базу и только потом отдаём экраны.
final bootstrapProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(repositoryProvider);
  await repo.ensureFirstCalendar(
    words: SeedWords.of(ref.watch(seedLanguageProvider)),
  );
  // Чистка давно удалённого — на запуске: отдельного расписания ради неё
  // заводить не за что, а приложение открывают чаще, чем раз в 90 дней.
  await repo.purgeDeleted();
});

/// Календари и ветки. Нужны на каждом экране, поэтому держатся отдельно от
/// потока событий.
final inheritanceProvider = StreamProvider<Inheritance>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchInheritance();
});

/// Определения своих полей. Живут отдельно от событий: одно определение
/// обслуживает сотни записей, и перечитывать его вместе с каждой — впустую.
final fieldDefsProvider = StreamProvider<List<VFieldDef>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchFieldDefs();
});

/// Те же определения под рукой у карточек события: там поле ищут по
/// идентификатору, а не перебирают список на каждой строке.
final fieldDefsByIdProvider = Provider<Map<String, VFieldDef>>((ref) => {
      for (final f in ref.watch(fieldDefsProvider).valueOrNull ?? const [])
        f.id: f,
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

/// Заметки события. Семейство по ключу события: карточка держит их ровно
/// столько, сколько открыта.
final notesProvider =
    StreamProvider.family<List<VNote>, String>((ref, eventId) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchNotes(eventId);
});

/// Поиск по запросу. Семейство, а не одно состояние: экран поиска живёт
/// столько же, сколько запрос, и держать его в провайдере вручную незачем.
final searchProvider =
    StreamProvider.family<List<VEvent>, String>((ref, query) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchSearch(query);
});

/// Будильники на ближайший месяц.
///
/// Отдельный поток, а не побочное действие сохранения: напоминание должно
/// пересобираться и когда событие приехало по синхронизации, и когда занятие
/// отменили, и когда календарь скрыли. Место, где это видно одинаково, — сама
/// база.
final reminderPlanProvider = Provider<List<PlannedReminder>>((ref) {
  final now = ref.watch(nowProvider);
  final from = DateTime(now.year, now.month, now.day);
  final range = (from: from, to: from.add(const Duration(days: 30)));

  final data = ref.watch(rangeProvider(range)).valueOrNull;
  if (data == null) return const [];

  final events = [
    for (final day in data.byDay.values) ...day,
    ...data.spans,
  ];
  // Считаем от настоящего «сейчас», а не от `nowProvider`: тот заморожен на
  // запуске приложения и в снимках экрана.
  return planReminders(events, now: DateTime.now());
});

final reminderServiceProvider =
    Provider<ReminderService>((ref) => ReminderService());

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

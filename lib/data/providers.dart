import 'dart:ui' show Color, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reminder_plan.dart';
import '../services/photo_service.dart';
import '../services/place_service.dart';
import '../services/sync_api.dart';
import '../services/sync_service.dart';
import '../services/widget_service.dart';
import 'settings.dart';
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
///
/// Здесь ровно то, без чего экран не построить. Всё остальное — после первого
/// кадра: календарь открывают на пять секунд по десять раз в день, и каждая
/// лишняя транзакция до первой отрисовки видна человеку как задержка.
final bootstrapProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(repositoryProvider);
  await repo.ensureFirstCalendar(
    words: SeedWords.of(ref.watch(seedLanguageProvider)),
  );
});

/// Уборка: физическое удаление того, что пролежало в корзине 90 дней.
///
/// Раз в сутки и после первого кадра. Раньше она шла на каждом запуске и до
/// показа экрана: транзакция с построчным обходом четырёх таблиц стояла ровно
/// между запуском и первым кадром, а смысла чаще раза в сутки в ней нет —
/// корзина живёт кварталами.
final purgeProvider = FutureProvider<int>((ref) async {
  final settings = await ref.watch(settingsProvider.future);

  final now = DateTime.now().millisecondsSinceEpoch;
  const day = Duration(days: 1);
  if (now - settings.lastPurge < day.inMilliseconds) return 0;

  await ref.watch(bootstrapProvider.future);
  final removed = await ref.watch(repositoryProvider).purgeDeleted();
  await settings.setLastPurge(now);
  return removed;
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
///
/// `autoDispose` тут не оптимизация, а условие работоспособности. Ключ окна —
/// пара дат, и без уборки каждый свайп оставлял бы за собой живую подписку на
/// базу: после месяца листания правка одного события будила три десятка
/// запросов разом, и приложение тем медленнее, чем дольше им пользуются.
/// Сторож — `test/unit/range_cache_test.dart`.
final rangeProvider =
    StreamProvider.autoDispose.family<RangeData, ({DateTime from, DateTime to})>(
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

/// Снимки события. Семейство по ключу события — как и заметки.
final photosProvider =
    StreamProvider.family<List<VPhoto>, String>((ref, eventId) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchPhotos(eventId);
});

/// Вложения события — как заметки и снимки, семейством по ключу события.
final filesProvider =
    StreamProvider.family<List<VFile>, String>((ref, eventId) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchFiles(eventId);
});

/// История правок события. Не поток: журнал читают, когда открывают, а
/// подписка на него держала бы запрос ради экрана, куда заходят раз в месяц.
final historyProvider =
    FutureProvider.family<List<VRevision>, String>((ref, eventId) async {
  await ref.watch(bootstrapProvider.future);
  return ref.watch(repositoryProvider).historyOf(eventId);
});

/// Частые события: подсказки быстрого листа. Считаются по истории, а не по
/// заготовкам, которые надо заводить руками.
final frequentEventsProvider =
    FutureProvider.autoDispose<List<VEvent>>((ref) async {
  await ref.watch(bootstrapProvider.future);
  return ref.watch(repositoryProvider).frequentEvents();
});

/// «Мои цвета»: подобранные оттенки, общие на всё приложение.
final savedColorsProvider = StreamProvider<List<Color>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchSavedColors();
});

/// Камера и галерея. Подменяется в тестах: плагина выбора файлов в
/// `flutter test` нет.
final photoServiceProvider = Provider<PhotoService>((ref) => PhotoService());

/// Все задачи: список показывает и сделанные, поэтому фильтрует экран, а не
/// запрос — иначе отметка выполнения выкидывала бы строку из-под пальца.
final tasksProvider = StreamProvider<List<VTask>>((ref) async* {
  await ref.watch(bootstrapProvider.future);
  yield* ref.watch(repositoryProvider).watchTasks();
});

/// Задачи со сроком внутри окна — для видов календаря. Убирается за собой по
/// той же причине, что и окно событий.
final tasksInRangeProvider =
    StreamProvider.autoDispose.family<List<VTask>, ({DateTime from, DateTime to})>(
  (ref, range) async* {
    await ref.watch(bootstrapProvider.future);
    yield* ref.watch(repositoryProvider).watchTasksInRange(range.from, range.to);
  },
);

/// Поиск по запросу. Семейство, а не одно состояние: экран поиска живёт
/// столько же, сколько запрос, и держать его в провайдере вручную незачем.
final searchProvider =
    StreamProvider.family<List<VEvent>, String>((ref, query) async* {
  await ref.watch(bootstrapProvider.future);
  // «Сейчас» берётся общее на приложение, а не своё у поиска: иначе выдача
  // считается по часам машины, и снимок экрана расходится с макетом на
  // следующий же день после съёмки.
  yield* ref
      .watch(repositoryProvider)
      .watchSearch(query, now: ref.watch(nowProvider));
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

/// Синхронизация: живёт, только когда сервер подключён.
final syncServiceProvider = Provider<SyncService?>((ref) {
  final settings = ref.watch(syncSettingsProvider);
  if (!settings.connected) return null;
  return SyncService(
    db: ref.watch(databaseProvider),
    api: HttpSyncApi(baseUrl: settings.url),
  );
});

/// Сколько правок ждёт отправки. Пересчитывается по требованию: строка
/// состояния обновляется после синка, а не тикает каждую секунду.
final pendingChangesProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(syncServiceProvider);
  if (service == null) return 0;
  return service.pendingCount();
});

/// Источник места: координаты и названия. Подменяется в тестах — плагинов
/// геолокации в `flutter test` нет.
final placeSourceProvider =
    Provider<PlaceSource>((ref) => const DevicePlaceSource());

final reminderServiceProvider =
    Provider<ReminderService>((ref) => ReminderService());

/// Виджеты рабочего стола. Подменяется в тестах: канала платформы там нет.
final widgetServiceProvider =
    Provider<WidgetService>((ref) => const WidgetService());

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
    return spansBetween(start, start.add(const Duration(days: 1)));
  }

  /// Полосы, попавшие в отрезок `[from, to)`.
  ///
  /// Окно базы шире видимого: события подгружаются на месяц вокруг, чтобы
  /// календарь листался без рывков. Виду нужен только его отрезок — иначе над
  /// неделей повисает всё, что нашлось в окне, включая сентябрьские дни
  /// рождения, а подпись «день N из 2» уходит в минус.
  List<VEvent> spansBetween(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return [
      for (final e in spans)
        if (e.start.isBefore(end) && e.end.isAfter(start)) e,
    ];
  }

  static const empty = RangeData(byDay: {}, spans: []);
}

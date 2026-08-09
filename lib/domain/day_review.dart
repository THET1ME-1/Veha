import '../data/models.dart';
import 'free_time.dart';

/// Разбор дня: сколько занято, где окна и что стоит развести.
///
/// Календарь уже знает всё, чтобы ответить на «влезет ли ещё одно дело», —
/// значит должен отвечать сам, а не заставлять человека складывать часы
/// глазами. Считается без базы и без экрана: чистая функция под тестами.

/// Две встречи, наехавшие друг на друга.
class Clash {
  const Clash(this.first, this.second);

  final VEvent first;
  final VEvent second;
}

class DayReview {
  const DayReview({
    required this.busy,
    required this.free,
    required this.gaps,
    required this.clashes,
    required this.longest,
    required this.hasNoBreaks,
  });

  /// Сколько времени занято внутри границ дня.
  final Duration busy;

  /// Сколько осталось свободным.
  final Duration free;

  /// Окна между занятостями — туда и переносят.
  final List<TimeSlot> gaps;

  /// Наложения: их видно и в сетке, но список отвечает «сколько их всего».
  final List<Clash> clashes;

  /// Самое длинное занятие дня.
  final VEvent? longest;

  /// День забит без единого перерыва. Не ошибка, но сказать об этом стоит:
  /// шесть часов подряд человек ставит не нарочно, а по невнимательности.
  final bool hasNoBreaks;

  /// Доля занятого от границ дня, от нуля до единицы.
  double get load {
    final total = busy + free;
    if (total == Duration.zero) return 0;
    return busy.inMinutes / total.inMinutes;
  }
}

/// Разбор одного дня.
///
/// Многодневные полосы не считаются занятостью: абонемент в бассейн помечает
/// день, а не занимает его. Событие без окончания — тоже: времени за ним не
/// числится.
DayReview reviewDay(
  List<VEvent> events,
  DateTime day, {
  DayBounds bounds = const DayBounds(),
  DateTime? now,
}) {
  final from = DateTime(day.year, day.month, day.day, bounds.from);
  final to = DateTime(day.year, day.month, day.day, bounds.to);

  final timed = [
    for (final e in events)
      if (!e.isSpan && !e.isOpenEnded) e,
  ]..sort((a, b) => a.busyFrom.compareTo(b.busyFrom));

  // Занятое считается объединением отрезков: две наехавшие встречи занимают
  // не два часа, а полтора — иначе загрузка дня переваливает за сотню
  // процентов и перестаёт что-либо значить.
  var busy = Duration.zero;
  DateTime? runStart;
  DateTime? runEnd;
  for (final e in timed) {
    // Дорога — тоже занятое время: полчаса пути нельзя занять ничем другим.
    final start = e.busyFrom.isBefore(from) ? from : e.busyFrom;
    final end = e.end.isAfter(to) ? to : e.end;
    if (!end.isAfter(start)) continue;

    if (runEnd == null || start.isAfter(runEnd)) {
      if (runStart != null) busy += runEnd!.difference(runStart);
      runStart = start;
      runEnd = end;
    } else if (end.isAfter(runEnd)) {
      runEnd = end;
    }
  }
  if (runStart != null && runEnd != null) busy += runEnd.difference(runStart);

  final gaps = freeSlots(
    timed,
    day,
    atLeast: const Duration(minutes: 15),
    bounds: bounds,
    now: now,
  );

  final clashes = <Clash>[];
  for (var i = 0; i < timed.length; i++) {
    for (var j = i + 1; j < timed.length; j++) {
      if (!intervalsOverlap(
          timed[i].start, timed[i].end, timed[j].start, timed[j].end)) {
        // Список отсортирован: дальше начала только позже, пересечений
        // с этим событием больше не будет.
        break;
      }
      clashes.add(Clash(timed[i], timed[j]));
    }
  }

  VEvent? longest;
  for (final e in timed) {
    if (longest == null || e.duration > longest.duration) longest = e;
  }

  final window = to.difference(from);
  return DayReview(
    busy: busy,
    free: window - busy,
    gaps: gaps,
    clashes: clashes,
    longest: longest,
    // Перерыв — окно хотя бы в четверть часа. День без единого такого окна
    // и есть день без передышки; пустой день сюда не попадает.
    hasNoBreaks: timed.isNotEmpty && gaps.isEmpty,
  );
}

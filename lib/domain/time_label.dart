import 'package:flutter/widgets.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';

/// Часы и минуты события. Ведущий ноль обязателен: «9:05» и «09:05» в столбце
/// расходятся по ширине, и время перестаёт читаться колонкой.
String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Подпись времени события одной строкой.
///
/// У события без окончания тире не ставится вовсе: «14:00 – 14:00» обещает
/// длительность, которой нет, а «с 14:00» говорит ровно то, что известно.
String eventTimeLabel(BuildContext context, VEvent event) => event.isOpenEnded
    ? L.of(context).timeFrom(hhmm(event.start))
    : '${hhmm(event.start)} – ${hhmm(event.end)}';

/// Длительность по-человечески: «1 ч 30 мин», «45 мин», «2 ч».
String humanDuration(L l, Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours == 0) return l.durationMinutes(minutes);
  if (minutes == 0) return l.durationHours(hours);
  return l.durationHoursMinutes(hours, minutes);
}

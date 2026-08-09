import '../data/models.dart';

/// Где полоса сейчас: какой день по счёту из скольких.
///
/// Счёт идёт от выбранного дня, а полоса может ещё не начаться или уже
/// кончиться: голая разница дат тогда уходит в минус или за длину события, и
/// над неделей висело «-9-й из 1». Номер держится внутри срока.
class SpanProgress {
  const SpanProgress({required this.passed, required this.total});

  final int passed;
  final int total;

  /// Стоит ли вообще подписывать счётчик. У однодневного праздника «1-й из 1»
  /// не сообщает ничего, а у трёхмесячного абонемента важнее дата окончания.
  bool get counted => total > 1 && total <= 45;

  double get fraction => total <= 0 ? 0 : (passed / total).clamp(0.0, 1.0);
}

SpanProgress spanProgress(VEvent event, DateTime today) {
  final start = DateTime(event.start.year, event.start.month, event.start.day);
  // Обе границы входят в срок: с 16 июля по 14 августа — это 30 дней, а не
  // 29, как выйдет из голой разницы дат.
  final total = event.lastDay.difference(start).inDays + 1;
  final day = DateTime(today.year, today.month, today.day);
  final passed = (day.difference(start).inDays + 1).clamp(1, total < 1 ? 1 : total);
  return SpanProgress(passed: passed, total: total < 1 ? 1 : total);
}

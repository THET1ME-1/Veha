import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/month_header.dart';

/// Неделя колонками пилюль — самый узнаваемый вид.
///
/// Высота пилюли пропорциональна длительности, внутри только иконка по центру.
/// Пересекающиеся события делят ширину колонки: место, которое ломается тише
/// всего, поэтому раскладка вынесена в отдельную функцию с тестом.
class WeekView extends StatelessWidget {
  const WeekView({
    super.key,
    required this.week,
    required this.eventsOf,
    required this.spans,
    required this.inheritance,
    required this.today,
  });

  final List<DateTime> week;
  final List<VEvent> Function(DateTime) eventsOf;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final DateTime today;

  static const double _firstHour = 7;
  // Границы кратны шагу подписей (два часа), иначе последняя подпись вылезает
  // за сетку и колонка часов переполняется.
  static const double _lastHour = 21;
  static const double _hourHeight = 34;
  static const double _gutter = 34;
  static const double _gap = 5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dow = DateFormat.E(locale);
    final gridHeight = (_lastHour - _firstHour) * _hourHeight;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: _gutter),
              for (final d in week) ...[
                const SizedBox(width: _gap),
                Expanded(
                  child: Text(
                    '${dow.format(d).toLowerCase()} ${d.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      fontWeight: _sameDay(d, today) ? FontWeight.w700 : FontWeight.w600,
                      color: _sameDay(d, today)
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          for (final s in spans)
            _SpanStrip(event: s, inheritance: inheritance, today: today),
          const SizedBox(height: 2),
          SizedBox(
            height: gridHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _gutter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var h = _firstHour; h < _lastHour; h += 2)
                        SizedBox(
                          height: _hourHeight * 2,
                          child: Text(
                            h.toInt().toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                for (final d in week) ...[
                  const SizedBox(width: _gap),
                  Expanded(
                    child: _DayColumn(
                      events: eventsOf(d),
                      inheritance: inheritance,
                      isWeekend: d.weekday >= 6,
                      isPast: d.isBefore(DateTime(today.year, today.month, today.day)),
                      firstHour: _firstHour,
                      hourHeight: _hourHeight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Лента многодневного события над сеткой. Тянется через захваченные дни.
class _SpanStrip extends StatelessWidget {
  const _SpanStrip({
    required this.event,
    required this.inheritance,
    required this.today,
  });

  final VEvent event;
  final Inheritance inheritance;
  final DateTime today;

  /// Полоса подписывается вместе со счётчиком: «идёт сейчас» без ответа
  /// «сколько осталось» бесполезно.
  String _label(BuildContext context) {
    final total = event.end.difference(event.start).inDays + 1;
    final passed = today.difference(event.start).inDays + 1;
    if (total > 45) return event.title;
    return '${event.title} · ${L.of(context).spanDayOf(passed, total)}';
  }

  @override
  Widget build(BuildContext context) {
    final ink = EventColors.of(
        inheritance.colorOfEvent(event), Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(left: WeekView._gutter + WeekView._gap, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: ShapeDecoration(color: ink.background, shape: const StadiumBorder()),
        child: Row(
          children: [
            Icon(VehaIcons.byName(event.iconName), size: 13, color: ink.foreground),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _label(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ink.foreground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.events,
    required this.inheritance,
    required this.isWeekend,
    required this.isPast,
    required this.firstHour,
    required this.hourHeight,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final bool isWeekend;
  final bool isPast;
  final double firstHour;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placed = layoutOverlaps(events);

    return Opacity(
      opacity: isPast ? 0.5 : 1,
      child: LayoutBuilder(
        builder: (context, c) => Container(
          decoration: ShapeDecoration(
            // Подложка есть у всех семи колонок, иначе суббота и воскресенье
            // выглядят оборванными. Выходной отличается тональным уровнем,
            // а не отсутствием фона.
            color: isWeekend
                ? scheme.surfaceContainerLowest
                : scheme.surfaceContainerLow,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          child: Stack(
            children: [
              for (final p in placed)
                _Pill(
                  placed: p,
                  width: c.maxWidth,
                  firstHour: firstHour,
                  hourHeight: hourHeight,
                  color: inheritance.colorOfEvent(p.event),
                  icon: inheritance.iconOfEvent(p.event),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Событие с его колонкой при наложении.
class PlacedEvent {
  const PlacedEvent(this.event, this.lane, this.lanes);

  final VEvent event;
  final int lane;
  final int lanes;
}

/// Раскладка пересечений: группа считается по цепочке перекрытий.
/// Вынесено отдельно, потому что это единственная нетривиальная арифметика
/// в виде недели, и она проверяется тестом.
List<PlacedEvent> layoutOverlaps(List<VEvent> events) {
  final sorted = [...events]..sort((a, b) => a.start.compareTo(b.start));
  final result = <PlacedEvent>[];
  var i = 0;
  while (i < sorted.length) {
    final group = <VEvent>[sorted[i]];
    var groupEnd = sorted[i].end;
    var j = i + 1;
    while (j < sorted.length && sorted[j].start.isBefore(groupEnd)) {
      group.add(sorted[j]);
      if (sorted[j].end.isAfter(groupEnd)) groupEnd = sorted[j].end;
      j++;
    }
    for (var k = 0; k < group.length; k++) {
      result.add(PlacedEvent(group[k], k, group.length));
    }
    i = j;
  }
  return result;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.placed,
    required this.width,
    required this.firstHour,
    required this.hourHeight,
    required this.color,
    required this.icon,
  });

  final PlacedEvent placed;
  final double width;
  final double firstHour;
  final double hourHeight;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final e = placed.event;
    final ink = EventColors.of(color, Theme.of(context).brightness);

    final startHours = e.start.hour + e.start.minute / 60 - firstHour;
    final top = startHours * hourHeight;
    // Минимум — не ширина колонки: пятнадцатиминутка растягивалась до круга
    // и наезжала на следующее событие. 24 хватает, чтобы иконка читалась.
    final height =
        (e.duration.inMinutes / 60 * hourHeight).clamp(24.0, 1000.0);
    final laneWidth = (width - 6) / placed.lanes;
    final iconSize = height < 30 ? 13.0 : 17.0;

    return Positioned(
      top: top < 0 ? 0 : top,
      left: 3 + placed.lane * laneWidth,
      width: laneWidth - (placed.lanes > 1 ? 2 : 0),
      height: height,
      child: Container(
        decoration: ShapeDecoration(
          color: ink.background,
          shape: const StadiumBorder(),
        ),
        alignment: Alignment.center,
        child: Icon(VehaIcons.byName(icon), size: iconSize, color: ink.foreground),
      ),
    );
  }
}

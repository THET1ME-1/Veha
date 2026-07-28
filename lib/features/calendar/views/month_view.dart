import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../widgets/month_header.dart';

/// Как день показывает свою занятость.
enum MonthMode {
  /// Чипы с иконкой и коротким названием: видно, что именно в этот день.
  chips,

  /// Только иконки: в ячейку влезает втрое больше, день читается по цвету.
  icons,

  /// Тонированная ячейка: видно, чем занят день, без чтения текста.
  tint,
}

/// Месяц. Россыпь мелких кружков под числом отвергнута — по ней ничего
/// не прочитать, поэтому режимов два с половиной и они переключаются
/// в настройках вида.
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.month,
    required this.eventsOf,
    required this.spans,
    required this.inheritance,
    required this.today,
    this.mode = MonthMode.chips,
    this.maxChips = 2,
    this.onDayTap,
  });

  final DateTime month;
  final List<VEvent> Function(DateTime) eventsOf;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final DateTime today;
  final MonthMode mode;
  final int maxChips;

  /// Тап по дню: месяц отвечает «когда», день — «что именно».
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weeks = _weeks(month);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    DateFormat.E(locale)
                        .format(weeks.first[i])
                        .toLowerCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (final week in weeks) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final day in week)
                  Expanded(
                    child: _Cell(
                      day: day,
                      events: day.month == month.month ? eventsOf(day) : const [],
                      inheritance: inheritance,
                      isToday: _sameDay(day, today),
                      isOutside: day.month != month.month,
                      mode: mode,
                      maxChips: maxChips,
                      onTap: onDayTap == null ? null : () => onDayTap!(day),
                    ),
                  ),
              ],
            ),
            // Лента многодневного события идёт под неделей, которую оно
            // захватывает: внутри ячеек ей места нет.
            for (final s in spans)
              _SpanRow(
                event: s,
                week: week,
                inheritance: inheritance,
                isFirstWeek: week == weeks.first,
              ),
            const SizedBox(height: 3),
          ],
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Недели месяца с хвостами соседних: сетка всегда полная, иначе она
  /// прыгает по высоте от месяца к месяцу.
  static List<List<DateTime>> _weeks(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final start = first.subtract(Duration(days: first.weekday - 1));
    final weeks = <List<DateTime>>[];
    var cursor = start;
    while (true) {
      final week = List.generate(7, (i) => cursor.add(Duration(days: i)));
      weeks.add(week);
      cursor = cursor.add(const Duration(days: 7));
      if (cursor.month != month.month && cursor.day > 7) break;
      if (weeks.length >= 6) break;
    }
    return weeks;
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.events,
    required this.inheritance,
    required this.isToday,
    required this.isOutside,
    required this.mode,
    required this.maxChips,
    this.onTap,
  });

  final DateTime day;
  final List<VEvent> events;
  final Inheritance inheritance;
  final bool isToday;
  final bool isOutside;
  final MonthMode mode;
  final int maxChips;

  /// Тап по ячейке уводит в день: месяц отвечает на вопрос «когда», а
  /// подробности живут в дне.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Color? tint;
    if (mode == MonthMode.tint && events.isNotEmpty) {
      tint = EventColors.of(
              inheritance.colorOfEvent(events.first), theme.brightness)
          .soft;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
      opacity: isOutside ? 0.35 : 1,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        decoration: ShapeDecoration(
          color: tint ?? Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        child: Column(
          children: [
            // Не круг фиксированной ширины: в 24 пикселя двузначное число
            // Unbounded'ом не влезает и обрезается пополам.
            Container(
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: isToday ? scheme.primary : Colors.transparent,
                shape: const StadiumBorder(),
              ),
              child: Text(
                '${day.day}',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: isToday ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
            if (events.isNotEmpty) _content(context, theme),
          ],
        ),
      ),
    ),
    );
  }

  Widget _content(BuildContext context, ThemeData theme) => switch (mode) {
        MonthMode.chips => _Chips(
            events: events,
            inheritance: inheritance,
            brightness: theme.brightness,
            max: maxChips,
            scheme: theme.colorScheme,
          ),
        MonthMode.icons => _Icons(
            events: events,
            inheritance: inheritance,
            brightness: theme.brightness,
            scheme: theme.colorScheme,
          ),
        MonthMode.tint => Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${events.length}',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      };
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.events,
    required this.inheritance,
    required this.brightness,
    required this.scheme,
    required this.max,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final Brightness brightness;
  final ColorScheme scheme;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = events.take(max).toList();
    final rest = events.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in shown) ...[
            _chip(e),
            const SizedBox(height: 2),
          ],
          if (rest > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '+$rest',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(VEvent e) {
    final ink = EventColors.of(inheritance.colorOfEvent(e), brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: ShapeDecoration(
        color: ink.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(VehaIcons.byName(inheritance.iconOfEvent(e)),
              size: 9, color: ink.foreground),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              e.title,
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: ink.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Icons extends StatelessWidget {
  const _Icons({
    required this.events,
    required this.inheritance,
    required this.brightness,
    required this.scheme,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final Brightness brightness;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // Без переноса: вторая строка иконок делает ячейки разной высоты, и сетка
    // прыгает при перелистывании месяцев. В ячейку шириной 48 помещается три
    // значка либо два и счётчик — больше не влезает физически.
    final capacity = events.length > 3 ? 2 : 3;
    final shown = events.take(capacity).toList();
    final rest = events.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _dot(shown[i]),
          ],
          if (rest > 0)
            Text(
              ' +$rest',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _dot(VEvent e) {
    final ink = EventColors.of(inheritance.colorOfEvent(e), brightness);
    // 13 логических пикселей — предел: три значка с зазорами ровно укладываются
    // в ячейку шириной 48 вместе с её внутренними отступами.
    return Container(
      width: 13,
      height: 13,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: ink.background, shape: const CircleBorder()),
      child: Icon(VehaIcons.byName(inheritance.iconOfEvent(e)),
          size: 8.5, color: ink.foreground),
    );
  }
}

/// Отрезок многодневного события внутри одной недели.
class _SpanRow extends StatelessWidget {
  const _SpanRow({
    required this.event,
    required this.week,
    required this.inheritance,
    required this.isFirstWeek,
  });

  final VEvent event;
  final List<DateTime> week;
  final Inheritance inheritance;

  /// Событие, начавшееся до этого месяца, подписывается в первой видимой
  /// неделе: безымянная полоса через весь месяц ничего не сообщает.
  final bool isFirstWeek;

  @override
  Widget build(BuildContext context) {
    final from = event.start;
    final to = event.end;

    var startIdx = -1;
    var endIdx = -1;
    for (var i = 0; i < week.length; i++) {
      final d = DateTime(week[i].year, week[i].month, week[i].day);
      if (!d.isBefore(DateTime(from.year, from.month, from.day)) &&
          !d.isAfter(DateTime(to.year, to.month, to.day))) {
        if (startIdx < 0) startIdx = i;
        endIdx = i;
      }
    }
    if (startIdx < 0) return const SizedBox.shrink();

    final ink = EventColors.of(
        inheritance.colorOfEvent(event), Theme.of(context).brightness);
    final startsHere = _sameDay(week[startIdx], from);
    final endsHere = _sameDay(week[endIdx], to);

    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 2),
      child: Row(
        children: [
          // Полоса — один контейнер на весь захваченный отрезок, а не заливка
          // по ячейкам: иначе подпись обрезается шириной одной колонки.
          if (startIdx > 0) Spacer(flex: startIdx),
          Expanded(
            flex: endIdx - startIdx + 1,
            child: Container(
              height: 14,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: ShapeDecoration(
                color: ink.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(startsHere ? 999 : 0),
                    right: Radius.circular(endsHere ? 999 : 0),
                  ),
                ),
              ),
              child: startsHere || isFirstWeek
                  ? Text(
                      endsHere ? event.title : '${event.title} →',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: ink.foreground,
                      ),
                    )
                  : null,
            ),
          ),
          if (endIdx < 6) Spacer(flex: 6 - endIdx),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

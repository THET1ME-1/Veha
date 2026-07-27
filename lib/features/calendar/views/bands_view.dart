import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/brand.dart';
import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/month_header.dart';

/// Дни лентами: крупная дата слева, горизонтальная шкала часов справа.
///
/// Под свободным часом стоит кружок с плюсом — единственное место, где событие
/// заводится сразу в конкретный час, без диалога выбора времени.
class BandsView extends StatelessWidget {
  const BandsView({
    super.key,
    required this.days,
    required this.eventsOf,
    required this.inheritance,
    required this.today,
  });

  final List<DateTime> days;
  final List<VEvent> Function(DateTime) eventsOf;
  final Inheritance inheritance;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 4, VehaInsets.screen, 120),
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final day = days[i];
        final events = eventsOf(day);
        return _Band(
          day: day,
          events: events,
          inheritance: inheritance,
          isToday: _sameDay(day, today),
          isPast: day.isBefore(DateTime(today.year, today.month, today.day)),
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Band extends StatelessWidget {
  const _Band({
    required this.day,
    required this.events,
    required this.inheritance,
    required this.isToday,
    required this.isPast,
  });

  final DateTime day;
  final List<VEvent> events;
  final Inheritance inheritance;
  final bool isToday;
  final bool isPast;

  /// Преобладающий календарь дня — тот, на который ушло больше времени.
  /// По числу событий считать нельзя: три пятиминутки перевесят полуторачасовую
  /// планёрку, и день покрасится не тем, чем он на самом деле занят.
  Color? _dominant() {
    if (events.isEmpty) return null;
    final minutes = <Color, int>{};
    for (final e in events) {
      final c = inheritance.colorOfEvent(e);
      minutes[c] = (minutes[c] ?? 0) + e.duration.inMinutes;
    }
    var best = minutes.entries.first;
    for (final e in minutes.entries) {
      if (e.value > best.value) best = e;
    }
    return best.key;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final dominant = _dominant();
    final ink = dominant == null
        ? null
        : EventColors.of(dominant, theme.brightness);

    // Сегодняшний день выделяется более насыщенной заливкой того же оттенка,
    // а не обводкой.
    final background = ink == null
        ? scheme.surfaceContainerLow
        : (isToday ? ink.background : ink.soft);
    final foreground = ink?.foreground ?? scheme.onSurfaceVariant;

    return Opacity(
      opacity: isPast ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: ShapeDecoration(
          color: background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.EEEE(locale).format(day),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: foreground.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 38,
                      height: 0.95,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w800,
                      color: foreground,
                    ),
                  ),
                  Text(
                    DateFormat.MMMM(locale).format(day),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 20,
                      height: 1.1,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w300,
                      color: foreground.withValues(alpha: 0.9),
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                      decoration: ShapeDecoration(
                        color: foreground.withValues(alpha: 0.18),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        l.today,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: events.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        l.nothingPlanned,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: foreground.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : _Track(
                      events: events,
                      inheritance: inheritance,
                      foreground: foreground,
                      brightness: theme.brightness,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.events,
    required this.inheritance,
    required this.foreground,
    required this.brightness,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final Color foreground;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    // Между занятыми часами показываем свободный слот с плюсом: он и есть
    // главный смысл этого вида.
    final slots = <Widget>[];
    for (var i = 0; i < events.length && slots.length < 4; i++) {
      final e = events[i];
      slots.add(_Slot(
        hour: e.start,
        foreground: foreground,
        child: _Chip(
          event: e,
          ink: EventColors.of(inheritance.colorOfEvent(e), brightness),
          icon: inheritance.iconOfEvent(e),
        ),
      ));

      if (i + 1 < events.length) {
        final gap = events[i + 1].start.difference(e.end);
        if (gap.inMinutes >= 90 && slots.length < 4) {
          slots.add(_Slot(
            hour: e.end.add(const Duration(minutes: 30)),
            foreground: foreground,
            child: _AddDot(foreground: foreground),
          ));
        }
      }
    }

    // Трек листается вбок: в 250 пикселей помещается три слота, а день бывает
    // и на шесть. Обрезать молча нельзя — половина дня просто исчезнет.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            slots[i],
          ],
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.hour,
    required this.foreground,
    required this.child,
  });

  final DateTime hour;
  final Color foreground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
      decoration: ShapeDecoration(
        color: foreground.withValues(alpha: 0.08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${hour.hour.toString().padLeft(2, '0')}:${hour.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: foreground.withValues(alpha: 0.75),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.event, required this.ink, required this.icon});

  final VEvent event;
  final EventInk ink;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: ShapeDecoration(
        color: ink.chip,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(VehaIcons.byName(icon), size: 13, color: ink.onChip),
          const SizedBox(width: 5),
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: ink.onChip,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddDot extends StatelessWidget {
  const _AddDot({required this.foreground});

  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: foreground.withValues(alpha: 0.16),
        shape: const CircleBorder(),
      ),
      child: Icon(Symbols.add_rounded, size: 14, color: foreground),
    );
  }
}

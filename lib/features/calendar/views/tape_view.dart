import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../core/veha_theme.dart';
import '../../../data/models.dart';
import '../../../domain/free_time.dart';
import '../../../l10n/app_localizations.dart';

/// Лента дня: высота блока равна длительности события.
///
/// Пришла на смену цепочке. Цепочка ставила пятнадцатиминутку вровень с
/// четырёхчасовой парой, и по ней нельзя было понять, занят день или свободен.
/// Здесь занятое и пустое время делят экран в тех же пропорциях, в каких
/// делят сутки, а окно между делами подписано и работает кнопкой.
class TapeView extends StatelessWidget {
  const TapeView({
    super.key,
    required this.day,
    required this.events,
    required this.inheritance,
    this.now,
    this.onEventTap,
    this.onEventLongPress,
    this.onFreeTap,
    this.selected = const {},
  });

  final DateTime day;
  final List<VEvent> events;
  final Inheritance inheritance;

  /// Время риски «сейчас». `null` — день не сегодняшний, риски нет.
  final DateTime? now;

  final ValueChanged<VEvent>? onEventTap;
  final ValueChanged<VEvent>? onEventLongPress;

  /// Тап по свободному окну заводит событие внутри него.
  final void Function(TimeSlot slot)? onFreeTap;

  final Set<String> selected;

  /// Ниже этой высоты подпись не читается: блок сжимается до одной строки.
  static const double _minEvent = 40;
  static const double _minGap = 30;

  /// Сколько точек даём минуте, когда день пустой. Подобрано так, чтобы
  /// полуторачасовая пара занимала примерно четверть экрана телефона.
  static const double _perMinute = 1.15;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final timed = [
      for (final e in events)
        if (!e.isMultiDay) e,
    ]..sort((a, b) => a.start.compareTo(b.start));

    if (timed.isEmpty) return _Empty(day: day, onTap: onFreeTap);

    // Окна берём тем же расчётом, что и подсказки «когда я свободен»: одна
    // правда на всё приложение, иначе лента и быстрый лист разойдутся.
    final gaps = freeSlots(
      timed,
      day,
      atLeast: const Duration(minutes: 30),
      bounds: const DayBounds(from: 0, to: 24),
    );

    final rows = <_Row>[
      for (final e in timed) _Row.event(e),
      for (final g in gaps) _Row.gap(g),
    ]..sort((a, b) => a.start.compareTo(b.start));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final row = rows[i];
        final minutes = row.end.difference(row.start).inMinutes;
        final height = row.event != null
            ? (minutes * _perMinute).clamp(_minEvent, 420.0)
            : (minutes * _perMinute).clamp(_minGap, 150.0);

        final crossed = _crossedByNow(row);

        return SizedBox(
          height: height,
          child: row.event != null
              ? _EventSlab(
                  event: row.event!,
                  inheritance: inheritance,
                  height: height,
                  past: now != null && row.end.isBefore(now!),
                  selected: selected.contains(row.event!.id),
                  onTap: onEventTap == null ? null : () => onEventTap!(row.event!),
                  onLongPress: onEventLongPress == null
                      ? null
                      : () => onEventLongPress!(row.event!),
                )
              : _GapSlab(
                  slot: row.slot!,
                  label: l.tapeFree(_span(context, minutes)),
                  crossedByNow: crossed,
                  onTap: onFreeTap == null ? null : () => onFreeTap!(row.slot!),
                ),
        );
      },
    );
  }

  bool _crossedByNow(_Row row) {
    final moment = now;
    if (moment == null) return false;
    return !moment.isBefore(row.start) && moment.isBefore(row.end);
  }

  /// Длительность окна словами: «45 мин», «2 ч», «1 ч 30 мин».
  static String _span(BuildContext context, int minutes) {
    final l = L.of(context);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return l.durationMinutes(m);
    if (m == 0) return l.durationHours(h);
    return l.durationHoursMinutes(h, m);
  }
}

/// Строка ленты: либо событие, либо окно между событиями.
class _Row {
  _Row.event(VEvent e)
      : event = e,
        slot = null,
        start = e.start,
        end = e.end;

  _Row.gap(TimeSlot s)
      : event = null,
        slot = s,
        start = s.start,
        end = s.end;

  final VEvent? event;
  final TimeSlot? slot;
  final DateTime start;
  final DateTime end;
}

class _EventSlab extends StatelessWidget {
  const _EventSlab({
    required this.event,
    required this.inheritance,
    required this.height,
    required this.past,
    required this.selected,
    this.onTap,
    this.onLongPress,
  });

  final VEvent event;
  final Inheritance inheritance;
  final double height;
  final bool past;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = EventColors.of(
      inheritance.colorOfEvent(event),
      Theme.of(context).brightness,
    );
    final fill = selected ? scheme.primaryContainer : ink.background;
    final mark = selected ? scheme.onPrimaryContainer : ink.foreground;
    final icon = VehaIcons.byName(
      selected ? 'check' : inheritance.iconOfEvent(event),
    );

    // У события без окончания второго времени нет: «14:00 — 14:00» читается
    // как ошибка, поэтому подпись остаётся одна, с предлогом.
    final time = event.isAllDay
        ? L.of(context).allDay
        : event.isOpenEnded
            ? L.of(context).timeFrom(DateFormat.Hm().format(event.start))
            : '${DateFormat.Hm().format(event.start)} — '
                '${DateFormat.Hm().format(event.end)}';

    return Opacity(
      opacity: past ? 0.55 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
          decoration: ShapeDecoration(
            color: fill,
            shape: RoundedRectangleBorder(
              borderRadius: VehaShape.of(context).forHeight(height),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 17, color: mark),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      event.title,
                      maxLines: height > 60 ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.3,
                        color: mark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: mark.withValues(alpha: .74),
                    ),
                  ),
                ],
              ),
              if (height >= 58 && (event.location?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    event.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: mark.withValues(alpha: .74),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Свободное окно: пунктирная рамка, длительность словами и знак «плюс».
class _GapSlab extends StatelessWidget {
  const _GapSlab({
    required this.slot,
    required this.label,
    required this.crossedByNow,
    this.onTap,
  });

  final TimeSlot slot;
  final String label;

  /// Окно, внутри которого текущий момент: у него своя риска.
  final bool crossedByNow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorder(
          color: scheme.outlineVariant,
          radius: VehaShape.of(context).corner,
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(right: 13),
                child: Icon(
                  VehaIcons.byName('add'),
                  size: 17,
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Пунктир рисуется вручную: обводок в приложении нет, а у пустоты она
/// единственная — это не рамка блока, а обозначение отсутствия блока.
class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius.clamp(0, size.height / 2)),
    );
    final path = Path()..addRRect(rect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 5;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + 4;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) =>
      old.color != color || old.radius != radius;
}

class _Empty extends StatelessWidget {
  const _Empty({required this.day, this.onTap});

  final DateTime day;
  final void Function(TimeSlot slot)? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.dayFreeTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l.dayFreeHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

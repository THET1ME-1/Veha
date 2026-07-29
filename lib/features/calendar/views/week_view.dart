import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/auto_scroll_grid.dart';
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
    this.onEventTap,
    this.onEventLongPress,
    this.onEventMoved,
    this.selected = const {},
  });

  final List<DateTime> week;
  final List<VEvent> Function(DateTime) eventsOf;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final DateTime today;
  final ValueChanged<VEvent>? onEventTap;
  final ValueChanged<VEvent>? onEventLongPress;

  /// Отмеченные события: пачку переносят и удаляют разом.
  final Set<String> selected;

  /// Блок перетащили: сдвиг по времени и по дням сразу. В неделе это одно
  /// движение — палец идёт наискосок, и требовать двух отдельных жестов
  /// значит спорить с рукой.
  final void Function(VEvent event, Duration shift)? onEventMoved;

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

    return LayoutBuilder(builder: (context, constraints) => AutoScrollGrid(
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
            _SpanStrip(
              event: s,
              inheritance: inheritance,
              today: today,
              onTap: onEventTap == null ? null : () => onEventTap!(s),
              onLongPress:
                  onEventLongPress == null ? null : () => onEventLongPress!(s),
            ),
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
                      onEventTap: onEventTap,
                      onEventLongPress: onEventLongPress,
                      onEventMoved: onEventMoved,
                      selected: selected,
                      // Ширина колонки нужна пилюле, чтобы перевести сдвиг
                      // пальца вбок в дни.
                      dayWidth: (constraints.maxWidth - _gutter -
                              _gap * week.length) /
                          week.length +
                          _gap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Лента многодневного события над сеткой. Тянется через захваченные дни.
class _SpanStrip extends StatelessWidget {
  const _SpanStrip({
    this.onTap,
    this.onLongPress,
    required this.event,
    required this.inheritance,
    required this.today,
  });

  final VEvent event;
  final Inheritance inheritance;
  final DateTime today;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
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
    this.onEventTap,
    this.onEventLongPress,
    this.onEventMoved,
    this.dayWidth = 0,
    this.selected = const {},
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final bool isWeekend;
  final bool isPast;
  final double firstHour;
  final double hourHeight;
  final ValueChanged<VEvent>? onEventTap;
  final ValueChanged<VEvent>? onEventLongPress;
  final void Function(VEvent event, Duration shift)? onEventMoved;
  final Set<String> selected;

  /// Ширина колонки вместе с зазором: по ней сдвиг вбок переводится в дни.
  final double dayWidth;

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
                  onTap: onEventTap == null ? null : () => onEventTap!(p.event),
                  onLongPress: onEventLongPress == null
                      ? null
                      : () => onEventLongPress!(p.event),
                  onMoved: onEventMoved,
                  dayWidth: dayWidth,
                  isSelected: selected.contains(p.event.id),
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

class _Pill extends StatefulWidget {
  const _Pill({
    required this.placed,
    required this.width,
    required this.firstHour,
    required this.hourHeight,
    required this.color,
    required this.icon,
    this.onTap,
    this.onLongPress,
    this.onMoved,
    this.dayWidth = 0,
    this.isSelected = false,
  });

  final PlacedEvent placed;
  final double width;
  final double firstHour;
  final double hourHeight;
  final Color color;
  final String icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(VEvent event, Duration shift)? onMoved;
  final double dayWidth;
  final bool isSelected;

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  /// Смещение пальца от точки, с которой начали тащить.
  Offset _pointer = Offset.zero;

  /// Прокрутка сетки на момент последнего движения пальца: у края она едет
  /// сама, и пилюля обязана ехать вместе с ней.
  double _scrollMark = 0;
  double _scrolled = 0;

  bool _dragging = false;
  GridScroll? _grid;

  /// Шаг сетки: четверть часа по вертикали, целый день по горизонтали.
  static const int _stepMinutes = 15;

  double get _stepPixels => widget.hourHeight * _stepMinutes / 60;

  /// Куда пилюля уехала с начала жеста: пальцем и вместе с сеткой.
  Offset get _drag => Offset(
        widget.dayWidth == 0
            ? 0
            : (_pointer.dx / widget.dayWidth).round() * widget.dayWidth,
        ((_pointer.dy + _scrolled) / _stepPixels).round() * _stepPixels,
      );

  /// Сдвиг пальца — в минуты и дни. Наискосок работает: в неделе перенос на
  /// другой день и другое время — одно движение.
  Duration _shiftOf(Offset offset) {
    final minutes =
        (offset.dy / _stepPixels).round() * _stepMinutes;
    final days = widget.dayWidth == 0
        ? 0
        : (offset.dx / widget.dayWidth).round();
    return Duration(days: days, minutes: minutes);
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() => _scrolled = (_grid?.offset ?? _scrollMark) - _scrollMark);
    _publishDrag();
  }

  /// Куда пилюля метит прямо сейчас — по этому времени соседи и красятся.
  void _publishDrag() {
    final grid = _grid;
    if (grid == null) return;
    final e = widget.placed.event;
    final shift = _shiftOf(_drag);
    grid.drag.value = GridDrag(
      eventId: e.id,
      start: e.start.add(shift),
      end: e.end.add(shift),
    );
  }

  void _releaseGrid() {
    _grid?.onPointer(null);
    _grid?.drag.value = null;
    _grid?.controller.removeListener(_onScroll);
  }

  @override
  void dispose() {
    _releaseGrid();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placed = widget.placed;
    final width = widget.width;
    final firstHour = widget.firstHour;
    final hourHeight = widget.hourHeight;
    final color = widget.color;
    final icon = widget.icon;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
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

    final canDrag = widget.onMoved != null;

    return Positioned(
      key: ValueKey('pill-${e.id}'),
      top: (top < 0 ? 0 : top) + _drag.dy,
      left: 3 + placed.lane * laneWidth + _drag.dx,
      width: laneWidth - (placed.lanes > 1 ? 2 : 0),
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        onLongPressStart: canDrag
            ? (details) {
                HapticFeedback.mediumImpact();
                _grid = GridScroll.of(context);
                _scrollMark = _grid?.offset ?? 0;
                _scrolled = 0;
                _pointer = Offset.zero;
                _grid?.controller.addListener(_onScroll);
                _grid?.onPointer(details.globalPosition.dy);
                _publishDrag();
                setState(() => _dragging = true);
              }
            : null,
        onLongPressMoveUpdate: canDrag
            ? (details) {
                _grid?.onPointer(details.globalPosition.dy);
                final previous = _drag;
                // Локальное смещение уже включает уехавшую сетку: метку
                // сбрасываем, иначе прокрутка засчитается дважды.
                _pointer = details.localOffsetFromOrigin;
                _scrollMark = _grid?.offset ?? _scrollMark;
                _scrolled = 0;
                if (_drag == previous) return;
                HapticFeedback.selectionClick();
                _publishDrag();
                setState(() {});
              }
            : null,
        onLongPressEnd: canDrag
            ? (_) {
                final shift = _shiftOf(_drag);
                _releaseGrid();
                _grid = null;
                setState(() {
                  _pointer = Offset.zero;
                  _scrolled = 0;
                  _dragging = false;
                });
                if (shift.inMinutes != 0) widget.onMoved!(e, shift);
              }
            : null,
        child: GridClashSkin(
          span: VEventSpan(
            id: e.id,
            start: e.start,
            end: e.end,
            isMultiDay: e.isMultiDay,
          ),
          builder: (clash) {
            final scheme = Theme.of(context).colorScheme;
            // Пилюля, в которую метят, красится тоном ошибки целиком:
            // обводок и свечения в приложении нет. Отмеченная в пачке —
            // заливкой выбора с галочкой вместо знака занятия.
            final selected = widget.isSelected;
            final fill = clash
                ? scheme.errorContainer
                : selected
                    ? scheme.primaryContainer
                    : ink.background;
            final mark = clash
                ? scheme.onErrorContainer
                : selected
                    ? scheme.onPrimaryContainer
                    : ink.foreground;
            return Container(
              decoration: ShapeDecoration(
                // Оторванная пилюля светлеет тоном: теней в приложении нет.
                color: _dragging
                    ? ink.foreground.withValues(alpha: 0.24)
                    : fill,
                shape: const StadiumBorder(),
              ),
              alignment: Alignment.center,
              child: Icon(
                VehaIcons.byName(selected ? 'check' : icon),
                size: iconSize,
                color: mark,
              ),
            );
          },
        ),
      ),
    );
  }
}

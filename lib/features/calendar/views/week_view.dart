import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../core/veha_theme.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/settings.dart';
import '../../common/snap_physics.dart';
import '../widgets/auto_scroll_grid.dart';
import '../widgets/month_header.dart';

/// Неделя колонками пилюль — самый узнаваемый вид.
///
/// Колонки живут в бесконечной горизонтальной ленте: календарь прокручивается
/// пальцем, как список, с инерцией и на любое число дней. Пейджер, который
/// требовал дотянуть жест до конца, а потом прыгал целым периодом, отсюда
/// убран — «либо эта неделя, либо прошлая» и была главная жалоба на вид.
///
/// Высота блока пропорциональна длительности, а чем он подписан — решает
/// настройка: иконкой, названием или обоими сразу.
/// Пересекающиеся события делят ширину колонки: место, которое ломается тише
/// всего, поэтому раскладка вынесена в отдельную функцию с тестом.
class WeekView extends ConsumerStatefulWidget {
  const WeekView({
    super.key,
    required this.anchor,
    required this.columns,
    required this.eventsOf,
    required this.spans,
    required this.inheritance,
    required this.today,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventMoved,
    this.onAnchorChanged,
    this.onDayTap,
    this.selected = const {},
  });

  /// Первая видимая колонка.
  final DateTime anchor;

  /// Сколько дней показывать разом.
  final int columns;

  final List<VEvent> Function(DateTime) eventsOf;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final DateTime today;
  final ValueChanged<VEvent>? onEventTap;
  final ValueChanged<VEvent>? onEventLongPress;

  /// Лента уехала: первым видимым стал другой день. По нему экран решает,
  /// какое окно событий держать загруженным.
  final ValueChanged<DateTime>? onAnchorChanged;

  /// Тап по колонке мимо занятий. Неделя отвечает на вопрос «когда», и
  /// свободное место дня — самая короткая дорога к его подробностям.
  final ValueChanged<DateTime>? onDayTap;

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
  /// Высота часа при обычном масштабе. Щипок двумя пальцами растягивает её —
  /// как и в сетке дня.
  static const double _hourHeight = 34;
  static const double _gutter = 34;
  static const double _gap = 5;

  /// Боковые отступы сетки. Учитываются при расчёте колонки: измерение идёт
  /// снаружи прокрутки, а padding применяется внутри неё — без вычитания
  /// седьмая колонка вылезала за край экрана.
  static const double _side = 14;

  /// Высота строки с названием дня над колонкой.
  static const double _headerHeight = 22;

  /// Начало отсчёта ленты. Индекс элемента — число суток от этой даты:
  /// список не умеет отрицательных номеров, а календарь должен листаться и
  /// назад.
  ///
  /// Отсчёт ведётся в UTC: в местном времени сутки перевода часов длятся 23
  /// или 25 часов, и разница в днях за четверть века набегает на единицу —
  /// лента вставала не на тот день.
  static final DateTime epoch = DateTime.utc(2000);

  /// Номер дня в ленте.
  static int indexOf(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).difference(epoch).inDays;

  /// День по номеру — уже в местном календаре.
  static DateTime dayAt(int index) {
    final utc = epoch.add(Duration(days: index));
    return DateTime(utc.year, utc.month, utc.day);
  }

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  /// Контроллер живёт со времени создания вида, а не пересоздаётся в
  /// построении: контроллер, заведённый прямо в `build`, встаёт не на тот
  /// день — позиция прежнего списка успевает восстановиться поверх новой.
  final ScrollController _controller = ScrollController();
  double _columnWidth = 0;

  /// Встали ли уже на нужный день. Первая установка возможна только когда
  /// известна ширина колонки, то есть после первого измерения.
  bool _placed = false;

  /// Какой день лента показывает первым прямо сейчас.
  late DateTime _visible = widget.anchor;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(WeekView old) {
    super.didUpdateWidget(old);
    // Дату сменили снаружи — полосой дней или кнопкой «сегодня». Лента едет
    // туда же, но только если она сама не стоит уже на этом дне: иначе
    // прокрутка дёргалась бы под пальцем.
    if (!_sameDay(widget.anchor, _visible) && _controller.hasClients) {
      _visible = widget.anchor;
      _controller.jumpTo(WeekView.indexOf(widget.anchor) * _columnWidth);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Ставит ленту на нужный день, когда ширина колонки уже известна.
  void _placeOnAnchor() {
    if (!_controller.hasClients || _columnWidth <= 0) return;
    _controller.jumpTo(WeekView.indexOf(_visible) * _columnWidth);
    _placed = true;
  }

  void _onScroll() {
    if (_columnWidth <= 0 || !_placed) return;
    final first =
        WeekView.dayAt((_controller.offset / _columnWidth).round());
    if (_sameDay(first, _visible)) return;

    _visible = first;
    // Щелчок на каждом дне: палец считает дни, даже когда глаз смотрит на
    // события, а не на подписи.
    HapticFeedback.selectionClick();
    // Наружу сообщаем сменившийся день, а не каждый пиксель: окно событий
    // перечитывать на каждом кадре прокрутки незачем.
    widget.onAnchorChanged?.call(first);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hourHeight = WeekView._hourHeight * ref.watch(gridZoomProvider);
    final gridHeight = (WeekView._lastHour - WeekView._firstHour) * hourHeight;

    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth -
              WeekView._side * 2 -
              WeekView._gutter) /
          widget.columns;
      if ((width - _columnWidth).abs() > 0.5 || !_placed) {
        _columnWidth = width;
        // После кадра: до построения списка у контроллера нет позиции, и
        // прыгать некуда.
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _placeOnAnchor());
      }

      return AutoScrollGrid(
        padding: const EdgeInsets.fromLTRB(
            WeekView._side, 6, WeekView._side, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in widget.spans)
              _SpanStrip(
                event: s,
                inheritance: widget.inheritance,
                today: widget.today,
                onTap: widget.onEventTap == null
                    ? null
                    : () => widget.onEventTap!(s),
                onLongPress: widget.onEventLongPress == null
                    ? null
                    : () => widget.onEventLongPress!(s),
              ),
            const SizedBox(height: 2),
            SizedBox(
              height: WeekView._headerHeight + gridHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: WeekView._gutter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Отступ под строку с датами: часы должны начинаться
                        // там же, где верх колонок.
                        const SizedBox(height: WeekView._headerHeight),
                        for (var h = WeekView._firstHour;
                            h < WeekView._lastHour;
                            h += 2)
                          SizedBox(
                            height: hourHeight * 2,
                            child: Text(
                              h.toInt().toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      itemExtent: width,
                      // Лента встаёт на день: остановиться на половине
                      // колонки нельзя, а каждый пройденный день отзывается
                      // щелчком в пальце.
                      physics: SnapToStep(step: width),
                      itemBuilder: (context, i) {
                        final day = WeekView.dayAt(i);
                        return _Column(
                          day: day,
                          events: widget.eventsOf(day),
                          inheritance: widget.inheritance,
                          today: widget.today,
                          gridHeight: gridHeight,
                          hourHeight: hourHeight,
                          dayWidth: width,
                          onEventTap: widget.onEventTap,
                          onEventLongPress: widget.onEventLongPress,
                          onEventMoved: widget.onEventMoved,
                          onEmptyTap: widget.onDayTap == null
                              ? null
                              : () => widget.onDayTap!(day),
                          selected: widget.selected,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Колонка одного дня: подпись сверху, события под ней.
class _Column extends StatelessWidget {
  const _Column({
    required this.day,
    required this.events,
    required this.inheritance,
    required this.today,
    required this.gridHeight,
    required this.hourHeight,
    required this.dayWidth,
    required this.selected,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventMoved,
    this.onEmptyTap,
  });

  final DateTime day;
  final List<VEvent> events;
  final Inheritance inheritance;
  final DateTime today;
  final double gridHeight;
  final double hourHeight;
  final double dayWidth;
  final Set<String> selected;
  final ValueChanged<VEvent>? onEventTap;
  final ValueChanged<VEvent>? onEventLongPress;
  final void Function(VEvent event, Duration shift)? onEventMoved;
  final VoidCallback? onEmptyTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final isToday = _WeekViewState._sameDay(day, today);

    return Padding(
      padding: const EdgeInsets.only(left: WeekView._gap),
      child: Column(
        children: [
          SizedBox(
            height: WeekView._headerHeight,
            child: Text(
              '${DateFormat.E(locale).format(day).toLowerCase()} ${day.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                color: isToday ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            height: gridHeight,
            child: _DayColumn(
              events: events,
              inheritance: inheritance,
              isWeekend: day.weekday >= 6,
              isPast: day.isBefore(DateTime(today.year, today.month, today.day)),
              firstHour: WeekView._firstHour,
              hourHeight: hourHeight,
              onEventTap: onEventTap,
              onEventLongPress: onEventLongPress,
              onEventMoved: onEventMoved,
              onEmptyTap: onEmptyTap,
              selected: selected,
              dayWidth: dayWidth,
            ),
          ),
        ],
      ),
    );
  }
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
    final total = event.lastDay.difference(event.start).inDays + 1;
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
    this.onEmptyTap,
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

  /// Тап мимо занятий: неделя отвечает «когда», подробности живут в дне.
  final VoidCallback? onEmptyTap;
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
              // Свободное место колонки уводит в день. Лежит под пилюлями:
              // тап по занятию открывает занятие, мимо занятия — день.
              if (onEmptyTap != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onEmptyTap,
                  ),
                ),
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

class _Pill extends ConsumerStatefulWidget {
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
  ConsumerState<_Pill> createState() => _PillState();
}

class _PillState extends ConsumerState<_Pill> {
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

  /// Чем подписан блок внутри колонки.
  ///
  /// Место здесь считанное: колонка недели — это сорок точек ширины. Поэтому
  /// текст рисуется только когда блок выше 26 точек, а время — когда выше 42:
  /// обрезанное пополам слово хуже честной иконки.
  Widget _label({
    required LabelMode mode,
    required IconData icon,
    required double iconSize,
    required Color mark,
    required String title,
    required DateTime start,
    required double height,
    required double width,
  }) {
    final glyph = Icon(icon, size: iconSize, color: mark);
    // Колонка недели на телефоне — сорок точек ширины. Ниже тридцати текста
    // не остаётся вовсе: два наложенных события делят её пополам, и честнее
    // показать знак, чем обрубок слова.
    if (mode == LabelMode.icon || height < 20 || width < 30) return glyph;

    // Три плотности: узкая колонка недели, широкая колонка планшета и
    // промежуток между ними.
    final micro = width < 62;
    final tight = width < 88;
    final pad = micro ? 3.0 : (tight ? 5.0 : 8.0);
    final nameSize = micro ? 8.5 : (tight ? 10.0 : 11.5);

    final name = Text(
      title,
      maxLines: height < 38 ? 1 : (micro ? 3 : 2),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: nameSize,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: -.1,
        color: mark,
      ),
    );
    final time = Text(
      DateFormat.Hm().format(start),
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: micro ? 7.5 : 9,
        fontWeight: FontWeight.w600,
        color: mark.withValues(alpha: .78),
      ),
    );

    // Иконка рядом с названием влезает только там, где после неё остаётся
    // место под слово. В узкой колонке она уходит, название важнее.
    final withIcon = mode == LabelMode.both && width >= 58;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon)
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Icon(icon, size: tight ? 11 : 13, color: mark),
                  SizedBox(width: tight ? 3 : 5),
                  Expanded(child: name),
                ],
              ),
            )
          else
            SizedBox(width: double.infinity, child: name),
          if (height >= 40) ...[const SizedBox(height: 2), time],
        ],
      ),
    );
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
    final labelMode = ref.watch(appearanceProvider).labelMode;

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
        // Как и в сетке дня: жест принадлежит перетаскиванию, меню живёт
        // в превью по тапу.
        onLongPress: canDrag ? null : onLongPress,
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
            isSpan: e.isSpan,
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
                shape: RoundedRectangleBorder(
                  borderRadius: VehaShape.of(context).forHeight(height),
                ),
              ),
              alignment: Alignment.center,
              child: _label(
                mode: selected ? LabelMode.icon : labelMode,
                icon: VehaIcons.byName(selected ? 'check' : icon),
                iconSize: iconSize,
                mark: mark,
                title: e.title,
                start: e.start,
                height: height,
                width: laneWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}

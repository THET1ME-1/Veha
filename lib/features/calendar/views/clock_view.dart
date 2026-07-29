import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/brand.dart';
import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../data/providers.dart';
import '../widgets/auto_scroll_grid.dart';
import '../widgets/month_header.dart';

/// Часы: настоящая шкала времени.
///
/// Отвечает на вопрос «когда я свободен»: пустые промежутки видны, высота
/// блока пропорциональна длительности, пересекающиеся события делят ширину.
class ClockView extends StatelessWidget {
  const ClockView({
    super.key,
    required this.events,
    required this.inheritance,
    this.now,
    this.onEventTap,
    this.onEventLongPress,
    this.onHourTap,
    this.onEventMoved,
    this.onEventResized,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final DateTime? now;
  final ValueChanged<VEvent>? onEventTap;
  final ValueChanged<VEvent>? onEventLongPress;

  /// Блок перетащили: событие уехало на столько-то минут.
  final void Function(VEvent event, Duration shift)? onEventMoved;

  /// Блок потянули за нижний край: длительность стала другой.
  final void Function(VEvent event, Duration duration)? onEventResized;

  /// Тап по свободному часу: сюда и заводят событие, не открывая формы.
  final ValueChanged<int>? onHourTap;

  /// Высота часа. Меньше 60 — короткое событие превращается в полоску,
  /// в которую не влезает даже название.
  static const double hourHeight = 60;
  static const double _timeGutter = 42;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final firstHour = events
        .map((e) => e.start.hour)
        .reduce((a, b) => a < b ? a : b);
    final lastHour = events
        .map((e) => e.end.hour + (e.end.minute > 0 ? 1 : 0))
        .reduce((a, b) => a > b ? a : b);

    final hours = [for (var h = firstHour; h <= lastHour; h++) h];
    final height = hours.length * hourHeight;
    final lanes = _layout(events);

    // Ширину колонок считаем здесь: Positioned обязан быть прямым ребёнком
    // Stack, поэтому LayoutBuilder внутри блока события не годится.
    return LayoutBuilder(
      builder: (context, constraints) {
        final laneArea =
            constraints.maxWidth - VehaInsets.screen * 2 - _timeGutter - 10;
        return AutoScrollGrid(
          padding: const EdgeInsets.fromLTRB(
            VehaInsets.screen,
            6,
            VehaInsets.screen,
            120,
          ),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                for (var i = 0; i < hours.length; i++)
                  _HourRow(
                    hour: hours[i],
                    top: i * hourHeight,
                    stripe: i.isEven,
                    gutter: _timeGutter,
                    onTap: onHourTap == null
                        ? null
                        : () => onHourTap!(hours[i]),
                  ),
                for (final placed in lanes)
                  _EventBlock(
                    placed: placed,
                    firstHour: firstHour,
                    gutter: _timeGutter,
                    laneWidth: laneArea / placed.lanes,
                    color: inheritance.colorOfEvent(placed.event),
                    icon: inheritance.iconOfEvent(placed.event),
                    onTap: onEventTap == null
                        ? null
                        : () => onEventTap!(placed.event),
                    onLongPress: onEventLongPress == null
                        ? null
                        : () => onEventLongPress!(placed.event),
                    onMoved: onEventMoved,
                    onResized: onEventResized,
                  ),
                if (now != null &&
                    now!.hour >= firstHour &&
                    now!.hour <= lastHour)
                  Positioned(
                    left: _timeGutter,
                    right: 0,
                    top:
                        (now!.hour - firstHour) * hourHeight +
                        now!.minute / 60 * hourHeight,
                    child: const _NowMark(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Раскладка пересечений: события, наложенные по времени, делят ширину
  /// поровну. Группа считается по цепочке перекрытий, а не попарно, иначе
  /// три события подряд разъедутся на разное число колонок.
  static List<_Placed> _layout(List<VEvent> events) {
    final sorted = [...events]..sort((a, b) => a.start.compareTo(b.start));
    final result = <_Placed>[];
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
        result.add(_Placed(group[k], k, group.length));
      }
      i = j;
    }
    return result;
  }
}

class _Placed {
  const _Placed(this.event, this.lane, this.lanes);

  final VEvent event;
  final int lane;
  final int lanes;
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.top,
    required this.stripe,
    required this.gutter,
    this.onTap,
  });

  final int hour;
  final double top;
  final bool stripe;
  final double gutter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      height: ClockView.hourHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: gutter,
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          // Разлиновка чередованием заливок: линии между часами были бы
          // обводкой, а её в приложении нет нигде.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                decoration: ShapeDecoration(
                  color: stripe
                      ? scheme.surfaceContainerLow
                      : Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventBlock extends ConsumerStatefulWidget {
  const _EventBlock({
    required this.placed,
    required this.firstHour,
    required this.gutter,
    required this.laneWidth,
    required this.color,
    required this.icon,
    this.onTap,
    this.onLongPress,
    this.onMoved,
    this.onResized,
  });

  final _Placed placed;
  final int firstHour;
  final double gutter;
  final double laneWidth;
  final Color color;
  final String icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(VEvent event, Duration shift)? onMoved;
  final void Function(VEvent event, Duration duration)? onResized;

  @override
  ConsumerState<_EventBlock> createState() => _EventBlockState();
}

class _EventBlockState extends ConsumerState<_EventBlock> {
  /// Смещение пальца от точки, с которой начали тащить. Пока тянут, событие
  /// в базе не трогаем: правка на каждый кадр — это сотня записей за жест.
  double _pointerDy = 0;

  /// Прокрутка сетки на момент последнего движения пальца. Пока палец стоит
  /// у края, сетка едет сама, и блок обязан ехать вместе с ней — иначе он
  /// остаётся на месте, а время под ним меняется.
  double _scrollMark = 0;
  double _scrolled = 0;

  /// Прибавка к высоте, когда тянут за нижний край.
  double _stretch = 0;

  bool _dragging = false;
  GridScroll? _grid;

  /// Шаг сетки. Пятнадцать минут — то, чем человек мыслит расписание;
  /// попытки ставить встречу на 10:07 обычно означают промах пальцем.
  static const int _stepMinutes = 15;
  static double get _stepPixels =>
      ClockView.hourHeight * _stepMinutes / 60;

  double _snap(double value) =>
      (value / _stepPixels).round() * _stepPixels;

  /// Куда блок уехал с начала жеста: пальцем и вместе с сеткой.
  double get _drag => _snap(_pointerDy + _scrolled);

  Duration _minutesOf(double pixels) => Duration(
        minutes: (pixels / ClockView.hourHeight * 60).round(),
      );

  void _onScroll() {
    if (!mounted) return;
    setState(() => _scrolled = (_grid?.offset ?? _scrollMark) - _scrollMark);
    _publishDrag();
  }

  /// Куда блок метит прямо сейчас. Сосед под этим временем подсветится сам.
  void _publishDrag() {
    final grid = _grid;
    if (grid == null) return;
    final e = widget.placed.event;
    final shift = _minutesOf(_drag);
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
    final gutter = widget.gutter;
    final laneWidth = widget.laneWidth;
    final color = widget.color;
    final icon = widget.icon;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
    final firstHour = widget.firstHour;
    final ref = this.ref;
    final e = placed.event;
    final defs = ref.watch(fieldDefsByIdProvider);
    final ink = EventColors.of(color, Theme.of(context).brightness);

    final top =
        (e.start.hour - firstHour) * ClockView.hourHeight +
        e.start.minute / 60 * ClockView.hourHeight;
    // Нижняя граница — не «покрасивее», а чтобы название события помещалось
    // целиком: в 26 логических пикселей строка 14-го кегля уже не влезает.
    final height = (e.duration.inMinutes / 60 * ClockView.hourHeight).clamp(
      32.0,
      1000.0,
    );

    // Короткое событие сжимается до полоски: две строки требуют 50 пикселей
    // вместе с отступами, поэтому ниже 54 остаётся только название.
    final tight = height < 54;

    final canDrag = widget.onMoved != null;

    return Positioned(
      key: ValueKey('block-${e.id}'),
      left: gutter + 10 + placed.lane * laneWidth,
      width: laneWidth - (placed.lanes > 1 ? 6 : 0),
      // Пока блок под пальцем, он живёт своим смещением: правка в базу на
      // каждый кадр означала бы сотню записей за один жест.
      top: top + _drag,
      height: (height + _stretch).clamp(32.0, 2000.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        // Перетаскивание начинается только после долгого нажатия: иначе
        // прокрутка дня превращалась бы в случайные переносы.
        onLongPressStart: canDrag
            ? (details) {
                HapticFeedback.mediumImpact();
                _grid = GridScroll.of(context);
                _scrollMark = _grid?.offset ?? 0;
                _scrolled = 0;
                _pointerDy = 0;
                _grid?.controller.addListener(_onScroll);
                _grid?.onPointer(details.globalPosition.dy);
                _publishDrag();
                setState(() => _dragging = true);
              }
            : null,
        onLongPressMoveUpdate: canDrag
            ? (details) {
                // Палец у края сетки разгоняет её саму.
                _grid?.onPointer(details.globalPosition.dy);
                final previous = _drag;
                // Локальное смещение уже включает уехавшую сетку — блок
                // двигался вместе с ней. Метку сбрасываем, иначе прокрутка
                // засчитается дважды.
                _pointerDy = details.localOffsetFromOrigin.dy;
                _scrollMark = _grid?.offset ?? _scrollMark;
                _scrolled = 0;
                if (_drag == previous) return;
                _publishDrag();
                // Щелчок на каждом делении: палец чувствует сетку, даже
                // когда смотрит не на неё.
                HapticFeedback.selectionClick();
                setState(() {});
              }
            : null,
        onLongPressEnd: canDrag
            ? (_) {
                final shift = _minutesOf(_drag);
                _releaseGrid();
                _grid = null;
                setState(() {
                  _pointerDy = 0;
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
        // Блок, в который метят, красится тоном ошибки целиком: обводки и
        // свечения в приложении нет, выделять нечем, кроме заливки.
        final fill = clash ? scheme.errorContainer : ink.background;
        final mark = clash ? scheme.onErrorContainer : ink.foreground;
        return Container(
          // В поделённой колонке горизонтальные отступы режем: иначе название
          // обрывается там, где оно ещё помещалось.
          padding: EdgeInsets.symmetric(
            horizontal: placed.lanes > 1 ? 10 : 13,
            vertical: tight ? 4 : 9,
          ),
          decoration: ShapeDecoration(
            // Оторванный блок светлеет и приподнимается тоном: теней в
            // приложении нет, глубина строится заливкой.
            color: _dragging ? ink.foreground.withValues(alpha: 0.22) : fill,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
          ),
          child: Stack(
            children: [
              if (widget.onResized != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -9,
                  height: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) => setState(
                      () => _stretch = _snap(_stretch + details.delta.dy),
                    ),
                    onVerticalDragEnd: (_) {
                      final grown = _minutesOf(_stretch);
                      setState(() => _stretch = 0);
                      if (grown.inMinutes == 0) return;
                      HapticFeedback.selectionClick();
                      // Пятнадцать минут — пол длительности: событие короче
                      // человек всё равно не разглядит в сетке.
                      final next = e.duration + grown;
                      widget.onResized!(
                        e,
                        next.inMinutes < 15 ? const Duration(minutes: 15) : next,
                      );
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 34,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: ShapeDecoration(
                          color: ink.foreground.withValues(alpha: 0.35),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              Row(
            crossAxisAlignment: tight
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Icon(VehaIcons.byName(icon), size: 19, color: mark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 14,
                        height: 1.2,
                        letterSpacing: -0.14,
                        fontWeight: FontWeight.w600,
                        color: mark,
                      ),
                    ),
                    if (!tight)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _subtitle(e, defs),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: mark.withValues(alpha: 0.85),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
            ],
          ),
        );
          },
        ),
      ),
    );
  }

  /// В блок помещается одна строка: либо время, либо поле, отмеченное
  /// «в карточке». Поле полезнее — время видно по положению на шкале.
  static String _subtitle(VEvent e, Map<String, VFieldDef> defs) {
    final field = e.fields.firstOrNull;
    if (field != null) {
      final def = defs[field.fieldId];
      if (def != null && def.showInCard) return field.value;
    }
    return '${_hhmm(e.start)} – ${_hhmm(e.end)}';
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _NowMark extends StatelessWidget {
  const _NowMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: ShapeDecoration(
            color: scheme.error,
            shape: const CircleBorder(),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: ShapeDecoration(
              color: scheme.error,
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

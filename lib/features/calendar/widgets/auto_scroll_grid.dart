import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/settings.dart';
import '../../../domain/edge_scroll.dart';
import '../../../domain/free_time.dart';

/// Сетка, которая крутится сама, пока блок держат у её края.
///
/// Общая обёртка для часов и недели: без неё утреннюю встречу нельзя было
/// перенести на вечер — палец упирался в край экрана, а сетка стояла.
class AutoScrollGrid extends ConsumerStatefulWidget {
  const AutoScrollGrid({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.initialOffset = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Куда встать при первом появлении. Сетка рисует сутки целиком, а смотреть
  /// их с полуночи незачем: день открывается на первом деле.
  final double initialOffset;

  @override
  ConsumerState<AutoScrollGrid> createState() => _AutoScrollGridState();
}

class _AutoScrollGridState extends ConsumerState<AutoScrollGrid>
    with SingleTickerProviderStateMixin {
  /// Пальцы на сетке. Щипок считается по ним напрямую, а не жестом из арены:
  /// распознаватель масштаба забирает и одиночное движение, и вертикальная
  /// прокрутка сетки после этого перестаёт работать.
  final Map<int, Offset> _fingers = {};

  /// Вертикальный разброс пальцев и масштаб на начало щипка.
  double? _spanAtStart;
  double _zoomAtStart = 1;

  void _onDown(PointerDownEvent e) {
    _fingers[e.pointer] = e.position;
    if (_fingers.length == 2) _startPinch();
  }

  void _onUp(int pointer) {
    _fingers.remove(pointer);
    if (_fingers.length < 2) _spanAtStart = null;
  }

  void _startPinch() {
    final span = _verticalSpan();
    // Пальцы, поставленные на одну высоту, дают нулевой разброс: делить на
    // него нельзя, а щипок по горизонтали к сетке отношения не имеет.
    if (span < 24) return;
    _spanAtStart = span;
    _zoomAtStart = ref.read(gridZoomProvider);
  }

  void _onMove(PointerMoveEvent e) {
    if (!_fingers.containsKey(e.pointer)) return;
    _fingers[e.pointer] = e.position;
    if (_fingers.length < 2) return;
    if (_spanAtStart == null) {
      _startPinch();
      return;
    }

    final span = _verticalSpan();
    if (span < 8) return;
    ref.read(gridZoomProvider.notifier).set(_zoomAtStart * span / _spanAtStart!);
  }

  double _verticalSpan() {
    final ys = _fingers.values.map((o) => o.dy).toList()..sort();
    return ys.last - ys.first;
  }

  late final ScrollController _controller =
      ScrollController(initialScrollOffset: widget.initialOffset);

  /// Куда метит блок, пока он в воздухе. Живёт здесь, а не в самом блоке:
  /// подсветить накладку должен сосед, а он о чужом жесте иначе не узнает.
  final ValueNotifier<GridDrag?> _drag = ValueNotifier<GridDrag?>(null);

  /// Тикер заводится сразу, а не по первому жесту: `late final` создавал бы
  /// его в `dispose`, а искать `TickerMode` в разбираемом дереве нельзя.
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  /// Где палец на экране. `null` — блок отпустили, крутить нечего.
  double? _pointerY;
  Duration? _last;

  void _pointer(double? globalY) {
    _pointerY = globalY;
    if (globalY == null) {
      _ticker.stop();
      _last = null;
      return;
    }
    if (!_ticker.isActive) {
      _last = null;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final pointer = _pointerY;
    final previous = _last;
    _last = elapsed;
    if (pointer == null || previous == null) return;

    final seconds = (elapsed - previous).inMicroseconds / 1000000;
    if (seconds <= 0) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !_controller.hasClients) return;

    final top = box.localToGlobal(Offset.zero).dy;
    final speed = edgeScrollSpeed(
      pointer: pointer,
      top: top,
      bottom: top + box.size.height,
    );
    if (speed == 0) return;

    final position = _controller.position;
    final next = (position.pixels + speed * seconds)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (next != position.pixels) _controller.jumpTo(next);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    _drag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GridScroll(
        controller: _controller,
        onPointer: _pointer,
        drag: _drag,
        child: Listener(
          // Слушаем указатели, а не заводим жест: `Listener` не участвует в
          // разборе жестов, поэтому прокрутка и перетаскивание блока остаются
          // при своём.
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: (e) => _onUp(e.pointer),
          onPointerCancel: (e) => _onUp(e.pointer),
          child: SingleChildScrollView(
            controller: _controller,
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      );
}

/// Блок в воздухе: что тащат и в какое время оно метит прямо сейчас.
///
/// Время абсолютное, поэтому в неделе подсветка ловит накладку и в соседней
/// колонке — блок там едет наискосок, сразу на другой день и другой час.
class GridDrag {
  const GridDrag({
    required this.eventId,
    required this.start,
    required this.end,
  });

  final String eventId;
  final DateTime start;
  final DateTime end;

  /// Метит ли блок в чужое время. Своё событие не считается: оно и есть
  /// то, что тащат.
  /// Событие без окончания времени не занимает — ни то, что тащат, ни то,
  /// во что метят: «накладка» с ним была бы выдумкой.
  bool clashesWith(VEventSpan other) =>
      other.id != eventId &&
      !other.isSpan &&
      end.isAfter(start) &&
      other.end.isAfter(other.start) &&
      intervalsOverlap(start, end, other.start, other.end);

  // Равенство нужно уведомлению: без него каждый кадр автоскролла
  // перестраивал бы все блоки сетки, даже когда время под пальцем не
  // изменилось.
  @override
  bool operator ==(Object other) =>
      other is GridDrag &&
      other.eventId == eventId &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(eventId, start, end);
}

/// То немногое, что подсветке нужно знать о событии. Отдельный вид вместо
/// `VEvent` держит сетку независимой от модели: блокам недели и часов важны
/// границы, а не поля.
class VEventSpan {
  const VEventSpan({
    required this.id,
    required this.start,
    required this.end,
    this.isSpan = false,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final bool isSpan;
}

/// Оболочка блока: пока сосед метит в это время, тело строится подсвеченным.
///
/// Вне сетки (превью, снимок обложки) слушать нечего — тогда тело строится
/// напрямую, без лишнего слоя.
class GridClashSkin extends StatelessWidget {
  const GridClashSkin({
    super.key,
    required this.span,
    required this.builder,
  });

  final VEventSpan span;
  final Widget Function(bool clash) builder;

  @override
  Widget build(BuildContext context) {
    final drag = GridScroll.of(context)?.drag;
    if (drag == null) return builder(false);
    return ValueListenableBuilder<GridDrag?>(
      valueListenable: drag,
      builder: (context, value, _) => builder(value?.clashesWith(span) ?? false),
    );
  }
}

/// Сетка, видимая изнутри блока: его смещение считается от прокрутки, а не
/// только от пальца — иначе разогнавшаяся сетка уезжает из-под блока.
class GridScroll extends InheritedWidget {
  const GridScroll({
    super.key,
    required this.controller,
    required this.onPointer,
    required this.drag,
    required super.child,
  });

  final ScrollController controller;

  /// Куда указывает палец по вертикали экрана. `null` — жест кончился.
  final ValueChanged<double?> onPointer;

  /// Блок, который сейчас в воздухе. Соседи слушают и красятся.
  final ValueNotifier<GridDrag?> drag;

  static GridScroll? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GridScroll>();

  /// Сколько сетка прокрутилась с момента [since].
  double scrolledSince(double since) =>
      controller.hasClients ? controller.offset - since : 0;

  double get offset => controller.hasClients ? controller.offset : 0;

  @override
  bool updateShouldNotify(GridScroll oldWidget) =>
      oldWidget.controller != controller || oldWidget.drag != drag;
}

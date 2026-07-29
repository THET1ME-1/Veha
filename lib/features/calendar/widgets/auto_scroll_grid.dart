import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../domain/edge_scroll.dart';
import '../../../domain/free_time.dart';

/// Сетка, которая крутится сама, пока блок держат у её края.
///
/// Общая обёртка для часов и недели: без неё утреннюю встречу нельзя было
/// перенести на вечер — палец упирался в край экрана, а сетка стояла.
class AutoScrollGrid extends StatefulWidget {
  const AutoScrollGrid({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  State<AutoScrollGrid> createState() => _AutoScrollGridState();
}

class _AutoScrollGridState extends State<AutoScrollGrid>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();

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
        child: SingleChildScrollView(
          controller: _controller,
          padding: widget.padding,
          child: widget.child,
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
  bool clashesWith(VEventSpan other) =>
      other.id != eventId &&
      !other.isMultiDay &&
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
    this.isMultiDay = false,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final bool isMultiDay;
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

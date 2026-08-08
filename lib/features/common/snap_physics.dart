import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Прокрутка, которая останавливается на элементе, а не между элементами.
///
/// Свободная лента оставляет половину дня за краем экрана: расписание
/// читается обрезанным, и где начинается день — непонятно. Прилипание считает
/// ближайшую границу с учётом броска: медленный жест возвращает на место,
/// быстрый переносит на соседний.
class SnapToStep extends ScrollPhysics {
  const SnapToStep({required this.step, super.parent});

  /// Ширина одного шага: колонка дня, ячейка ленты дат.
  final double step;

  /// Ниже этой скорости решает ближайшая граница, выше — направление броска.
  static const double _throw = 300;

  @override
  SnapToStep applyTo(ScrollPhysics? ancestor) =>
      SnapToStep(step: step, parent: buildParent(ancestor));

  double _target(ScrollMetrics position, double velocity) {
    final current = position.pixels / step;
    final index = velocity.abs() < _throw
        ? current.roundToDouble()
        : (velocity > 0 ? current.ceilToDouble() : current.floorToDouble());
    return (index * step)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final target = _target(position, velocity);
    if ((target - position.pixels).abs() < toleranceFor(position).distance) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: toleranceFor(position),
    );
  }

  /// Инерцию гасим: лента доезжает до соседнего дня, а не пролетает неделю от
  /// одного щелчка пальцем.
  @override
  bool get allowImplicitScrolling => false;
}

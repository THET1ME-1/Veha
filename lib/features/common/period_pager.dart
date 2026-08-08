import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/morph.dart';

/// Листание календаря пальцем.
///
/// Раньше свайп был кнопкой без вида: жест засчитывался по скорости и
/// мгновенно перекидывал целый период — в неделе только на неделю, в месяце
/// только на месяц. Сдвинуться на пару дней было нельзя вовсе, а движение
/// показывали уже свершившимся.
///
/// Теперь содержимое едет за пальцем, а по отпусканию календарь сдвигается на
/// столько шагов, сколько человек протащил: в неделе шаг — сутки, поэтому
/// «назад на два дня» получается само.
class VPeriodPager extends StatefulWidget {
  const VPeriodPager({
    super.key,
    required this.child,
    required this.onShift,
    required this.step,
  });

  final Widget child;

  /// Сдвиг календаря на столько шагов. Отрицательное — назад.
  final ValueChanged<int> onShift;

  /// Ширина одного шага в пикселях: сутки в неделе, экран в месяце.
  final double step;

  @override
  State<VPeriodPager> createState() => _VPeriodPagerState();
}

class _VPeriodPagerState extends State<VPeriodPager>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  /// Куда уехало содержимое под пальцем, в пикселях.
  double _drag = 0;

  /// Дальше этого содержимое не тянется: на пустом ходу лист улетал бы за
  /// край, ничего не показывая.
  double get _limit => widget.step * 4;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d) {
    setState(() {
      _drag = (_drag + d.delta.dx).clamp(-_limit, _limit);
      _c.value = _drag;
    });
  }

  void _end(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    // Бросок засчитывается за шаг даже без длинного пути: палец, ушедший
    // быстро, означает «дальше», а не «чуть-чуть».
    final thrown = velocity.abs() > 700 ? (velocity > 0 ? 1 : -1) : 0;
    final dragged = (_drag / widget.step).round();
    final steps = dragged != 0 ? dragged : thrown;

    _drag = 0;
    if (steps != 0) {
      // Содержимое уже уехало в сторону жеста — новое приходит с той же
      // стороны и пружиной встаёт на место.
      widget.onShift(-steps);
    }

    if (!motionAllowed(context)) {
      _c.value = 0;
      setState(() {});
      return;
    }
    _c.animateWith(SpringSimulation(VehaSprings.standard, _c.value, 0, -velocity));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _update,
        onHorizontalDragEnd: _end,
        onHorizontalDragCancel: () {
          _drag = 0;
          _c.animateWith(SpringSimulation(VehaSprings.standard, _c.value, 0, 0));
        },
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) => Transform.translate(
            offset: Offset(_c.value, 0),
            child: child,
          ),
          child: widget.child,
        ),
      );
}

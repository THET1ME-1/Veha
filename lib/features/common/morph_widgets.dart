import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/morph.dart';

/// Индикатор загрузки: фигура перетекает по кругу вместо спиннера.
///
/// Одно из трёх мест, где живёт морфинг. Крутящаяся дуга Material узнаваема,
/// но принадлежит не нам; фигура, меняющая форму, — принадлежит.
class MorphLoader extends StatefulWidget {
  const MorphLoader({super.key, this.size = 44, this.color});

  final double size;
  final Color? color;

  @override
  State<MorphLoader> createState() => _MorphLoaderState();
}

class _MorphLoaderState extends State<MorphLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  static const _cycle = [
    MorphShape.circle,
    MorphShape.clover,
    MorphShape.petal,
    MorphShape.squircle,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // При выключенных анимациях кольцо не крутится: человек просил не двигать
    // интерфейс, а не остаться без признака работы.
    if (motionAllowed(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final progress = _c.value * _cycle.length;
          final from = _cycle[progress.floor() % _cycle.length];
          final to = _cycle[(progress.floor() + 1) % _cycle.length];
          final shape = MorphShape.lerp(from, to, progress - progress.floor());

          return DecoratedBox(
            decoration: ShapeDecoration(color: color, shape: MorphBorder(shape)),
          );
        },
      ),
    );
  }
}

/// Иконка в фигуре, которая меняет форму при отметке.
///
/// Второе место морфинга. Отметка выполнения есть у задачи: у события её нет
/// и не будет — событие либо состоялось, либо нет.
class MorphMark extends StatefulWidget {
  const MorphMark({
    super.key,
    required this.done,
    required this.child,
    required this.color,
    this.size = 36,
  });

  /// Отмечено ли. Смена значения запускает переход.
  final bool done;
  final Widget child;
  final Color color;
  final double size;

  @override
  State<MorphMark> createState() => _MorphMarkState();
}

class _MorphMarkState extends State<MorphMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    value: widget.done ? 1 : 0,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(MorphMark old) {
    super.didUpdateWidget(old);
    if (old.done == widget.done) return;

    if (!motionAllowed(context)) {
      _c.value = widget.done ? 1 : 0;
      return;
    }
    // Пружина с перелётом: отметка отзывается, а не просто перекрашивается.
    _c.animateWith(
      SpringSimulation(
        VehaSprings.bouncy,
        _c.value,
        widget.done ? 1 : 0,
        0,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value.clamp(0.0, 1.0);
            return DecoratedBox(
              decoration: ShapeDecoration(
                color: widget.color,
                shape: MorphBorder(
                  MorphShape.lerp(MorphShape.circle, MorphShape.clover, t),
                ),
              ),
              child: Center(child: child),
            );
          },
          child: widget.child,
        ),
      );
}

/// Кнопка «завести», которая раскрывается в форму.
///
/// Третье и последнее место морфинга. Дальше по интерфейсу его не
/// размазываем: фирменный приём, встречающийся всюду, перестаёт быть приёмом.
///
/// Внутри — стоковая кнопка Material: у неё правильная семантика, подсказка и
/// область нажатия, а фирменной делает её форма, а не собственная реализация
/// с нуля.
class MorphFab extends StatefulWidget {
  const MorphFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });

  final Future<void> Function() onPressed;
  final Widget child;
  final String? tooltip;

  @override
  State<MorphFab> createState() => _MorphFabState();
}

class _MorphFabState extends State<MorphFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (motionAllowed(context)) {
      // Кнопка успевает стать четырёхлистником до того, как форма закроет
      // экран: переход начинается на ней, а не поверх неё.
      await _c.forward();
    }
    await widget.onPressed();
    if (mounted) _c.reverse();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => FloatingActionButton(
          onPressed: _tap,
          tooltip: widget.tooltip,
          // Теней в приложении нет: глубину держит тональная поверхность.
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          shape: MorphBorder(
            MorphShape.lerp(MorphShape.circle, MorphShape.clover, _c.value),
          ),
          child: child,
        ),
        child: widget.child,
      );
}

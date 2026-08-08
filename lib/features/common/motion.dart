import 'package:flutter/material.dart';

import '../../core/morph.dart';

/// Появление списка каскадом.
///
/// ТЗ отводит на ступеньку 20–30 мс: при большем шаге список «сыплется», и
/// человек ждёт вместо того, чтобы читать. Задержка растёт только у первых
/// элементов — дальше она упирается в потолок, иначе двадцатое событие дня
/// появлялось бы через полсекунды после первого.
class VStagger extends StatelessWidget {
  const VStagger({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 25),
    this.maxIndex = 8,
  });

  final int index;
  final Widget child;
  final Duration step;

  /// Дальше этого номера задержка не растёт.
  final int maxIndex;

  @override
  Widget build(BuildContext context) {
    if (!motionAllowed(context)) return child;

    final delay = step * (index > maxIndex ? maxIndex : index);
    return _FadeSlideIn(delay: delay, child: child);
  }
}

class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );

  @override
  void initState() {
    super.initState();
    // Задержка через таймер кадра, а не `Future.delayed`: в тестах часы
    // поддельные, и настоящая задержка подвесила бы прогон.
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _c.animateTo(1, duration: const Duration(milliseconds: 240));
      _c.value = 0;
      Future<void>.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
          child: widget.child,
        ),
      );
}

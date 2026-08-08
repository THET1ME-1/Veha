import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

/// Держит «сегодня» настоящим.
///
/// `nowProvider` считается один раз и служит всему приложению общей точкой
/// отсчёта — иначе снимки экрана зависели бы от часов машины, а соседние
/// экраны показывали бы разное «сейчас». Обратная сторона: на телефоне
/// приложение не закрывают, а сворачивают, и через сутки в фоне календарь
/// открывался на вчерашнем дне. Заведённое событие уезжало туда же — со
/// стороны это выглядит как «событие не создалось».
///
/// Поэтому значение пересчитывается в двух местах: когда человек вернулся в
/// приложение и когда открытый календарь пережил полночь.
class FreshNow extends ConsumerStatefulWidget {
  const FreshNow({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<FreshNow> createState() => _FreshNowState();
}

class _FreshNowState extends ConsumerState<FreshNow>
    with WidgetsBindingObserver {
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
    // Уборка корзины — после первого кадра. До него имеет право работать
    // только то, без чего экран не нарисовать.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(purgeProvider);
    });
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    ref.invalidate(nowProvider);
    _scheduleMidnight();
  }

  /// Один таймер до ближайшей полуночи вместо ежеминутного тика: календарь,
  /// оставленный открытым на ночь, должен перевернуть день сам, а будить
  /// дерево каждую минуту ради этого незачем.
  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    // Секунда сверху: таймер, сработавший ровно в полночь, попадает в
    // предыдущие сутки на устройствах, где часы чуть спешат.
    _midnight = Timer(
      tomorrow.difference(now) + const Duration(seconds: 1),
      _refresh,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

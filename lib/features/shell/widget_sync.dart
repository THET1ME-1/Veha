import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../services/widget_service.dart';

/// Держит виджеты рабочего стола в согласии с базой.
///
/// Живёт обёрткой вокруг приложения, а не на экране календаря: экран можно
/// закрыть, а виджет от этого устареть не должен. Снимок уходит на каждую
/// правку — событие, задачу, скрытый календарь.
class WidgetSync extends ConsumerStatefulWidget {
  const WidgetSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WidgetSync> createState() => _WidgetSyncState();
}

class _WidgetSyncState extends ConsumerState<WidgetSync> {
  String? _last;

  @override
  Widget build(BuildContext context) {
    // Виджеты рабочего стола есть только на Android: в браузере и на планшете
    // без них считать день впустую незачем.
    if (!hasAlarms) return widget.child;

    final now = ref.watch(nowProvider);
    final today = DateTime(now.year, now.month, now.day);
    final window = (from: today, to: today.add(const Duration(days: 1)));

    final range = ref.watch(rangeProvider(window)).valueOrNull;
    final tasks = ref.watch(tasksInRangeProvider(window)).valueOrNull;
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;

    if (range != null && inheritance != null) {
      _send(
        events: [...range.eventsOn(today), ...range.spansOn(today)],
        tasks: tasks ?? const [],
        inheritance: inheritance,
        now: now,
      );
    }

    return widget.child;
  }

  void _send({
    required List<VEvent> events,
    required List<VTask> tasks,
    required Inheritance inheritance,
    required DateTime now,
  }) {
    final snapshot = buildWidgetSnapshot(
      l: L.of(context),
      locale: Localizations.localeOf(context).toLanguageTag(),
      now: now,
      events: events,
      tasks: tasks,
      inheritance: inheritance,
    );

    // Сравниваем с прошлым: перестроение дерева случается на каждый кадр
    // прокрутки, а запись файла и обход виджетов — работа на десятки
    // миллисекунд.
    final encoded = snapshot.toJson().toString();
    if (encoded == _last) return;
    _last = encoded;

    // После кадра: отправка трогает платформу, а мы посреди построения.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(widgetServiceProvider).push(snapshot),
    );
  }
}

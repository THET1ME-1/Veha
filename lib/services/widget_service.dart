import 'dart:convert';

import 'package:flutter/services.dart';
import '../core/platform.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';

/// Данные для виджетов рабочего стола.
///
/// Считает их приложение, а не виджет. Развёртка повторений, наследование
/// цвета и выбор видимых календарей живут в Dart; второй счётчик в Kotlin
/// разошёлся бы с первым на первом же переводе часов. Подписи тоже собираются
/// здесь — Kotlin не знает выбранный язык.
class WidgetService {
  const WidgetService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('veha/widgets');

  final MethodChannel _channel;

  Future<void> push(WidgetSnapshot snapshot) async {
    // На чужих платформах канала нет, и разговаривать не с кем.
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('refresh', jsonEncode(snapshot.toJson()));
    } on MissingPluginException {
      // Виджеты — украшение рабочего стола: их отсутствие не должно мешать
      // приложению работать.
    }
  }
}

/// Строка виджета: дело с временем или без.
class WidgetLine {
  const WidgetLine({
    required this.title,
    required this.time,
    required this.color,
    this.done = false,
  });

  final String title;
  final String time;
  final int color;
  final bool done;

  Map<String, Object?> toJson() => {
        'title': title,
        'time': time,
        'color': color,
        'done': done,
      };
}

class WidgetSnapshot {
  const WidgetSnapshot({
    required this.heading,
    required this.day,
    required this.weekday,
    required this.empty,
    required this.count,
    required this.items,
  });

  final String heading;
  final String day;
  final String weekday;
  final String empty;
  final String count;
  final List<WidgetLine> items;

  Map<String, Object?> toJson() => {
        'heading': heading,
        'day': day,
        'weekday': weekday,
        'empty': empty,
        'count': count,
        'items': [for (final i in items) i.toJson()],
      };
}

/// Сборка снимка для виджетов.
///
/// Берётся сегодняшний день целиком: события с временем, многодневные полосы
/// и задачи со сроком. Прошедшее не выкидывается — «во сколько была планёрка»
/// спрашивают чаще, чем кажется, а к вечеру виджет иначе пустеет совсем.
WidgetSnapshot buildWidgetSnapshot({
  required L l,
  required String locale,
  required DateTime now,
  required List<VEvent> events,
  required List<VTask> tasks,
  required Inheritance inheritance,
}) {
  final lines = <({DateTime at, WidgetLine line})>[];

  for (final e in events) {
    lines.add((
      at: e.start,
      line: WidgetLine(
        title: e.title,
        time: e.isMultiDay || e.isAllDay ? '' : DateFormat.Hm(locale).format(e.start),
        color: inheritance.colorOfEvent(e).toARGB32(),
      ),
    ));
  }

  for (final t in tasks) {
    if (t.due == null) continue;
    lines.add((
      at: t.due!,
      line: WidgetLine(
        title: t.title,
        time: t.hasTime ? DateFormat.Hm(locale).format(t.due!) : '',
        color: inheritance.colorOfTask(t).toARGB32(),
        done: t.isDone,
      ),
    ));
  }

  // По времени, дела без времени — первыми: они относятся ко всему дню.
  lines.sort((a, b) {
    final byTime = a.at.compareTo(b.at);
    if (byTime != 0) return byTime;
    return a.line.title.compareTo(b.line.title);
  });

  final open = lines.where((e) => !e.line.done).length;

  return WidgetSnapshot(
    heading: l.today,
    day: '${now.day}',
    weekday: DateFormat.EEEE(locale).format(now),
    empty: l.nothingPlanned,
    count: open == 0 ? '' : '$open',
    items: [for (final e in lines) e.line],
  );
}

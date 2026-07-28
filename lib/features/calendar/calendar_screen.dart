import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/icon_registry.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../data/seed.dart';
import '../event/event_flow.dart';
import 'views/bands_view.dart';
import 'views/chain_view.dart';
import 'views/clock_view.dart';
import 'views/month_view.dart';
import 'views/week_view.dart';
import 'widgets/month_header.dart';
import 'widgets/span_bar.dart';
import 'widgets/view_switcher.dart';
import 'widgets/week_strip.dart';

/// Сколько дней показывает лента.
const _bandsLength = 10;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarView _view = CalendarView.day;
  final MonthMode _monthMode = MonthMode.chips;
  DayReading _reading = DayReading.chain;
  DateTime? _selected;

  List<DateTime> get _week {
    final day = _selected!;
    final monday = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Видимое окно плюс запас: ряды разворачиваются на него, и при листании
  /// соседний месяц уже посчитан.
  ({DateTime from, DateTime to}) get _window {
    final day = _selected!;
    final (DateTime from, DateTime to) = switch (_view) {
      CalendarView.day => (day, day.add(const Duration(days: 1))),
      CalendarView.week => (_week.first, _week.last.add(const Duration(days: 1))),
      CalendarView.bands => (day, day.add(const Duration(days: _bandsLength))),
      CalendarView.month => (
          DateTime(day.year, day.month, 1),
          DateTime(day.year, day.month + 1, 1),
        ),
    };
    return (
      from: from.subtract(const Duration(days: 7)),
      to: to.add(const Duration(days: 7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(nowProvider);
    final today = DateTime(now.year, now.month, now.day);
    _selected ??= today;

    // Пока база отдаёт первую порцию, экран показывает каркас без событий:
    // спиннер на пять секунд открытого календаря — худшее, что можно сделать.
    final inheritance =
        ref.watch(inheritanceProvider).valueOrNull ?? Seed.inheritance;
    final range = ref.watch(rangeProvider(_window)).valueOrNull ?? RangeData.empty;

    return Column(
      children: [
        MonthHeader(
          date: _selected!,
          dayReading: _view == CalendarView.day ? _reading : null,
          onReadingChanged: (r) => setState(() => _reading = r),
        ),
        if (_view == CalendarView.day)
          WeekStrip(
            week: _week,
            selected: _selected!,
            busyDays: {
              for (final d in _week)
                if (range.eventsOn(d).isNotEmpty) d.day,
            },
            onSelect: (d) => setState(() => _selected = d),
          ),
        ViewSwitcher(value: _view, onChanged: (v) => setState(() => _view = v)),
        if (_view != CalendarView.week && _view != CalendarView.month)
          SpanBars(
            events: range.spansOn(_selected!),
            today: _selected!,
            inheritance: inheritance,
          ),
        Expanded(child: _body(range, inheritance, now, today)),
      ],
    );
  }

  bool _isToday(DateTime today) =>
      _selected!.year == today.year &&
      _selected!.month == today.month &&
      _selected!.day == today.day;

  /// Долгое нажатие: то, ради чего не стоит открывать форму — отменить одно
  /// занятие ряда или удалить событие целиком.
  Future<void> _showEventMenu(VEvent event) async {
    final flow = EventFlow(context, ref);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(VehaIcons.byName('pencil')),
              title: const Text('Изменить'),
              onTap: () {
                Navigator.pop(sheetContext);
                flow.edit(event);
              },
            ),
            if (event.isOccurrence)
              ListTile(
                leading: Icon(VehaIcons.byName('repeat')),
                title: Text('Отменить ${_dayLabel(event.start)}'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  flow.skip(event);
                },
              ),
            ListTile(
              leading: Icon(VehaIcons.byName('trash'),
                  color: Theme.of(context).colorScheme.error),
              title: Text(
                event.isOccurrence ? 'Удалить весь ряд' : 'Удалить событие',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                flow.deleteWhole(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _dayLabel(DateTime d) =>
      DateFormat('d MMMM', 'ru').format(d);

  Widget _body(
    RangeData range,
    Inheritance inheritance,
    DateTime now,
    DateTime today,
  ) {
    return switch (_view) {
      CalendarView.day when _reading == DayReading.chain => ChainView(
          events: range.eventsOn(_selected!),
          inheritance: inheritance,
          now: _isToday(today) ? now : null,
          onEventTap: (e) => EventFlow(context, ref).edit(e),
          onEventLongPress: _showEventMenu,
        ),
      CalendarView.day => ClockView(
          events: range.eventsOn(_selected!),
          inheritance: inheritance,
          now: _isToday(today) ? now : null,
          onEventTap: (e) => EventFlow(context, ref).edit(e),
          onEventLongPress: _showEventMenu,
          onHourTap: (hour) => EventFlow(context, ref).create(
            at: DateTime(_selected!.year, _selected!.month, _selected!.day, hour),
          ),
        ),
      CalendarView.month => MonthView(
          month: _selected!,
          eventsOf: range.eventsOn,
          spans: range.spans,
          inheritance: inheritance,
          today: today,
          mode: _monthMode,
        ),
      CalendarView.week => WeekView(
          week: _week,
          eventsOf: range.eventsOn,
          spans: range.spans,
          inheritance: inheritance,
          today: today,
        ),
      CalendarView.bands => BandsView(
          days: List.generate(
              _bandsLength, (i) => _selected!.add(Duration(days: i))),
          eventsOf: range.eventsOn,
          inheritance: inheritance,
          today: today,
        ),
    };
  }
}

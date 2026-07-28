import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/icon_registry.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../data/settings.dart';
import '../../domain/week_layout.dart';
import '../common/blocks.dart' show vBack;
import '../search/search_screen.dart';
import '../tasks/day_tasks.dart';
import '../settings/month_settings_screen.dart';
import '../event/event_flow.dart';
import 'views/bands_view.dart';
import 'views/chain_view.dart';
import 'views/clock_view.dart';
import 'views/month_view.dart';
import 'views/week_view.dart';
import 'widgets/month_header.dart';
import 'widgets/span_bar.dart';
import 'widgets/view_switcher.dart';
import 'widgets/week_setup_sheet.dart';
import 'widgets/week_strip.dart';

/// Сколько дней показывает лента.
const _bandsLength = 10;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// `null` — экран только открыли: вид берётся из настроек.
  CalendarView? _view;
  DateTime? _selected;

  /// Полоска дней над видом «День» — всегда семь суток подряд.
  List<DateTime> get _strip {
    final day = _selected!;
    final monday = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Колонки вида «Неделя» — столько, сколько дней выбрал человек.
  List<DateTime> _weekColumns(WeekLayout layout) => layout.daysOf(_selected!);

  /// Видимое окно плюс запас: ряды разворачиваются на него, и при листании
  /// соседний месяц уже посчитан.
  ({DateTime from, DateTime to}) get _window {
    final day = _selected!;
    final (DateTime from, DateTime to) = switch (_view ?? CalendarView.day) {
      CalendarView.day => (day, day.add(const Duration(days: 1))),
      CalendarView.week => (_strip.first, _strip.last.add(const Duration(days: 1))),
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
    // Пока база отдаёт первую порцию, показываем пустой каркас, а не
    // демо-данные: чужие календари в первом кадре человек принимает за свои.
    final inheritance = ref.watch(inheritanceProvider).valueOrNull ??
        const Inheritance(calendars: {}, subcategories: {});
    _view ??= ref.watch(startViewProvider);
    final view = _view!;
    final reading = ref.watch(dayReadingProvider);
    final monthMode = ref.watch(monthModeProvider);
    final range = ref.watch(rangeProvider(_window)).valueOrNull ?? RangeData.empty;

    return Column(
      children: [
        MonthHeader(
          date: _selected!,
          dayReading: view == CalendarView.day ? reading : null,
          onReadingChanged: (r) => ref.read(dayReadingProvider.notifier).set(r),
          onSearch: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
        if (view == CalendarView.day)
          WeekStrip(
            week: _strip,
            selected: _selected!,
            busyDays: {
              for (final d in _strip)
                if (range.eventsOn(d).isNotEmpty) d.day,
            },
            onSelect: (d) => setState(() => _selected = d),
          ),
        ViewSwitcher(
          value: view,
          onChanged: (v) => setState(() => _view = v),
          onSetup: switch (view) {
            CalendarView.week => _setupWeek,
            CalendarView.month => _setupMonth,
            _ => null,
          },
        ),
        // Задачи со сроком на этот день — над видом, а не внутри сетки часов:
        // у задачи срок, а не длительность.
        if (view == CalendarView.day) DayTasks(day: _selected!),
        if (view != CalendarView.week && view != CalendarView.month)
          SpanBars(
            events: range.spansOn(_selected!),
            today: _selected!,
            inheritance: inheritance,
            onEventTap: (e) => EventFlow(context, ref).edit(e),
            onEventLongPress: _showEventMenu,
          ),
        Expanded(child: _body(range, inheritance, now, today, reading, monthMode)),
      ],
    );
  }

  /// Настройка вида «Неделя»: какие дни показывать и с какого начинать.
  Future<void> _setupWeek() async {
    final chosen =
        await askWeekLayout(context, ref.read(weekLayoutProvider));
    if (chosen == null) return;
    await ref.read(weekLayoutProvider.notifier).set(chosen);
  }

  /// Настройка вида «Месяц»: чем показывать занятость дня.
  Future<void> _setupMonth() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
          body: const MonthSettingsScreen(),
        ),
      ),
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
              title: Text(L.of(context).actionEdit),
              onTap: () {
                Navigator.pop(sheetContext);
                flow.edit(event);
              },
            ),
            if (event.isOccurrence)
              ListTile(
                leading: Icon(VehaIcons.byName('repeat')),
                title: Text(L.of(context).eventCancelOn(_dayLabel(context, event.start))),
                onTap: () {
                  Navigator.pop(sheetContext);
                  flow.skip(event);
                },
              ),
            ListTile(
              leading: Icon(VehaIcons.byName('trash'),
                  color: Theme.of(context).colorScheme.error),
              title: Text(
                event.isOccurrence
                    ? L.of(context).eventDeleteSeries
                    : L.of(context).eventDelete,
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

  static String _dayLabel(BuildContext context, DateTime d) => DateFormat(
        'd MMMM',
        Localizations.localeOf(context).toLanguageTag(),
      ).format(d);

  Widget _body(
    RangeData range,
    Inheritance inheritance,
    DateTime now,
    DateTime today,
    DayReading reading,
    MonthMode monthMode,
  ) {
    return switch (_view ?? CalendarView.day) {
      CalendarView.day when reading == DayReading.chain => ChainView(
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
          mode: monthMode,
          maxChips: ref.watch(monthChipsProvider),
          // Тап по дню уводит в день: месяц отвечает «когда», подробности
          // живут там.
          onDayTap: (d) => setState(() {
            _selected = d;
            _view = CalendarView.day;
          }),
        ),
      CalendarView.week => WeekView(
          week: _weekColumns(ref.watch(weekLayoutProvider)),
          eventsOf: range.eventsOn,
          spans: range.spans,
          inheritance: inheritance,
          today: today,
          onEventTap: (e) => EventFlow(context, ref).edit(e),
          onEventLongPress: _showEventMenu,
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

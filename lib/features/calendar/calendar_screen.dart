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

  /// Отмеченные события. Пустая карта — обычный режим: тап открывает превью.
  /// Держим целые события, а не одни id: пачку надо перенести и вернуть,
  /// а вернуть по id уже нечего — записи в базе к тому времени другие.
  final Map<String, VEvent> _picked = {};

  bool get _picking => _picked.isNotEmpty;

  /// Тап в режиме выбора отмечает и снимает отметку; последняя снятая
  /// отметка закрывает режим — панель без выбранного бессмысленна.
  void _toggle(VEvent event) => setState(() {
        if (_picked.remove(event.id) == null) _picked[event.id] = event;
      });

  void _clearPicked() => setState(_picked.clear);

  /// Действие над пачкой закрывает режим: полоска «Вернуть» уже показана,
  /// а отметки на уехавших событиях висели бы поверх пустых мест.
  Future<void> _bulk(Future<void> Function(List<VEvent>) action) async {
    final events = _picked.values.toList();
    _clearPicked();
    await action(events);
  }

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
            onPrevious: () => _shift(-1),
            onNext: () => _shift(1),
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
            onEventTap: (e) => EventFlow(context, ref).preview(e),
            onEventLongPress: _showEventMenu,
          ),
        // Свайп листает период. Без него календарь показывал только тот день,
        // на который его открыли: соседняя неделя была недостижима вовсе.
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              // Порог отсекает случайный сдвиг пальца при прокрутке часов.
              if (v.abs() < 220) return;
              _shift(v < 0 ? 1 : -1);
            },
            child: _body(range, inheritance, now, today, reading, monthMode),
          ),
        ),
        if (_picking) _BulkBar(
          count: _picked.length,
          onMove: () => _askBulkMove(),
          onCalendar: () => _bulk(EventFlow(context, ref).changeCalendarMany),
          onDelete: () => _bulk(EventFlow(context, ref).deleteMany),
          onClose: _clearPicked,
        ),
      ],
    );
  }

  /// Куда переносим пачку. Те же три ответа, что и у одного события:
  /// на завтра, через неделю, на выбранную дату.
  Future<void> _askBulkMove() async {
    final l = L.of(context);
    final flow = EventFlow(context, ref);
    final chosen = await showModalBottomSheet<Duration?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(VehaIcons.byName('calendar_today')),
              title: Text(l.moveTomorrow),
              onTap: () =>
                  Navigator.pop(sheetContext, const Duration(days: 1)),
            ),
            ListTile(
              leading: Icon(VehaIcons.byName('calendar_view_week')),
              title: Text(l.moveNextWeek),
              onTap: () =>
                  Navigator.pop(sheetContext, const Duration(days: 7)),
            ),
            ListTile(
              leading: Icon(VehaIcons.byName('calendar_month')),
              title: Text(l.movePickDate),
              // Нулевой сдвиг — знак «спросить дату»: выбор даты живёт
              // в потоке события, а не в этом листе.
              onTap: () => Navigator.pop(sheetContext, Duration.zero),
            ),
          ],
        ),
      ),
    );
    if (chosen == null) return;

    await _bulk((events) => chosen == Duration.zero
        ? flow.moveManyToPickedDate(events)
        : flow.moveMany(events, chosen));
  }

  /// Шаг листания зависит от вида: день — сутки, лента — свою длину, неделя —
  /// семь дней, месяц — месяц.
  void _shift(int direction) {
    setState(() {
      final view = _view ?? CalendarView.day;
      if (view == CalendarView.month) {
        _selected = DateTime(
          _selected!.year,
          _selected!.month + direction,
          // День месяца может не существовать в соседнем (31 марта → 31
          // апреля), поэтому берём первое и возвращаем ближайшее к прежнему.
          1,
        );
        return;
      }
      final step = switch (view) {
        CalendarView.day => 1,
        CalendarView.week => 7,
        CalendarView.bands => _bandsLength,
        CalendarView.month => 0,
      };
      _selected = _selected!.add(Duration(days: step * direction));
    });
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
            // Вход в режим выбора: долгий жест в сетке уже занят
            // перетаскиванием, а тап открывает превью — свободного жеста
            // не осталось, зато меню под рукой.
            ListTile(
              leading: Icon(VehaIcons.byName('check')),
              title: Text(L.of(context).actionSelect),
              onTap: () {
                Navigator.pop(sheetContext);
                _toggle(event);
              },
            ),
            ListTile(
              leading: Icon(VehaIcons.byName('content_copy')),
              title: Text(L.of(context).eventDuplicate),
              onTap: () {
                Navigator.pop(sheetContext);
                flow.duplicate(event);
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
    // В режиме выбора тап отмечает, а не открывает превью: подробности
    // смотрят по одному событию, а пачку — набирают.
    void onTap(VEvent e) =>
        _picking ? _toggle(e) : EventFlow(context, ref).preview(e);

    return switch (_view ?? CalendarView.day) {
      CalendarView.day when reading == DayReading.chain => ChainView(
          events: range.eventsOn(_selected!),
          inheritance: inheritance,
          now: _isToday(today) ? now : null,
          onEventTap: onTap,
          onEventLongPress: _showEventMenu,
          selected: _picked.keys.toSet(),
        ),
      CalendarView.day => ClockView(
          events: range.eventsOn(_selected!),
          inheritance: inheritance,
          now: _isToday(today) ? now : null,
          onEventTap: onTap,
          onEventLongPress: _showEventMenu,
          selected: _picked.keys.toSet(),
          // Долгое нажатие отрывает блок и тащит его по сетке, нижний край
          // тянет длительность. Шаг — пятнадцать минут. В режиме выбора
          // перетаскивание молчит: пачку двигают панелью, а не пальцем.
          onEventMoved: _picking
              ? null
              : (e, shift) => EventFlow(context, ref).moveBy(e, shift),
          onEventResized: _picking
              ? null
              : (e, duration) => EventFlow(context, ref).resize(e, duration),
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
          onEventTap: onTap,
          onEventLongPress: _showEventMenu,
          selected: _picked.keys.toSet(),
          // В неделе перенос идёт наискосок: и на другой час, и на другой
          // день одним движением.
          onEventMoved: _picking
              ? null
              : (e, shift) => EventFlow(context, ref).moveBy(e, shift),
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

/// Панель действий над пачкой: сколько отмечено и что с ними делать.
///
/// Живёт внизу экрана, над системными кнопками: до верхней шапки в этот
/// момент не дотянуться — палец занят отметками.
class _BulkBar extends StatelessWidget {
  const _BulkBar({
    required this.count,
    required this.onMove,
    required this.onCalendar,
    required this.onDelete,
    required this.onClose,
  });

  final int count;
  final VoidCallback onMove;
  final VoidCallback onCalendar;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('bulk-close'),
              onPressed: onClose,
              icon: Icon(VehaIcons.byName('close')),
              tooltip: l.actionCancel,
            ),
            Expanded(
              child: Text(
                l.selectedCount(count),
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('bulk-move'),
              onPressed: onMove,
              icon: Icon(VehaIcons.byName('calendar_clock')),
              tooltip: l.bulkMove,
            ),
            IconButton(
              key: const ValueKey('bulk-calendar'),
              onPressed: onCalendar,
              icon: Icon(VehaIcons.byName('calendar_month')),
              tooltip: l.bulkCalendar,
            ),
            IconButton(
              key: const ValueKey('bulk-delete'),
              onPressed: onDelete,
              icon: Icon(VehaIcons.byName('trash'), color: scheme.error),
              tooltip: l.eventDelete,
            ),
          ],
        ),
      ),
    );
  }
}

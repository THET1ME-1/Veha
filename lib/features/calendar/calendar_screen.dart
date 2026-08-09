import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/icon_registry.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../data/settings.dart';
import '../common/blocks.dart' show vBack;
import '../common/period_pager.dart';
import '../search/search_screen.dart';
import '../tasks/day_tasks.dart';
import '../settings/month_settings_screen.dart';
import '../settings/settings_screen.dart';
import '../event/event_flow.dart';
import 'views/tape_view.dart';
import 'views/clock_view.dart';
import 'views/month_view.dart';
import 'views/week_view.dart';
import '../../domain/day_review.dart';
import 'widgets/day_review_sheet.dart';
import 'widgets/day_sheet.dart';
import 'widgets/month_header.dart';
import 'widgets/span_bar.dart';
import 'widgets/view_switcher.dart';
import 'widgets/week_setup_sheet.dart';
import 'widgets/week_strip.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// `null` — экран только открыли: вид берётся из настроек.
  CalendarView? _view;
  DateTime? _selected;

  /// Первая колонка вида «Неделя». Живёт отдельно от выбранного дня: неделя
  /// листается посуточно и может начинаться с любого дня, а выбранный день
  /// при этом остаётся тем, что человек выбрал.
  DateTime? _weekAnchor;

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

  /// Окно, на котором разворачиваются ряды: месяц выбранного дня с запасом в
  /// неделю назад и две вперёд.
  ///
  /// Окно считается от месяца, а не от видимых суток, намеренно. Ключ окна —
  /// пара дат, и окно «день ± неделя» давало бы новый ключ на каждый свайп:
  /// новая подписка на базу, новый разворот рядов, и так на каждое движение
  /// пальца. От месяца ключ меняется двенадцать раз в году, а листание дней и
  /// недель внутри месяца обходится без единого запроса.
  ///
  /// Запас несимметричный: две недели вперёд закрывают ленту дней, которая с
  /// конца месяца заглядывает в следующий.
  ({DateTime from, DateTime to}) get _window {
    final day = _selected!;
    return (
      from: DateTime(day.year, day.month, 1).subtract(const Duration(days: 7)),
      to: DateTime(day.year, day.month + 1, 1).add(const Duration(days: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Сутки сменились, пока приложение лежало в фоне. Человек, смотревший на
    // «сегодня», должен увидеть новое сегодня, а не вчерашний день — но если
    // он ушёл листать другую неделю, его выбор не трогаем.
    ref.listen(nowProvider, (before, after) {
      if (before == null) return;
      final was = DateTime(before.year, before.month, before.day);
      final become = DateTime(after.year, after.month, after.day);
      if (was == become || _selected != was) return;
      setState(() => _selected = become);
    });

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
          // Разбор есть там, где есть день: месяц целиком разбирать нечего.
          onReview: view == CalendarView.month
              ? null
              : () => _reviewDay(range, inheritance, now),
          onAdd: () => EventFlow(context, ref).create(),
          period: _periodLabel(view),
          summary: _periodSummary(view, range),
          onPrev: () => _shift(-1),
          onNext: () => _shift(1),
          onToday:
              _isToday(today) ? null : () => setState(() => _selected = today),
        ),
        if (view == CalendarView.day)
          WeekStrip(
            selected: _selected!,
            // Занятые дни считаем на месяц вокруг: лента листается свободно,
            // и точки должны стоять там, куда человек ещё только доедет.
            busyDays: {
              for (final d in range.byDay.keys)
                if (range.eventsOn(d).isNotEmpty) d,
            },
            onSelect: (d) => setState(() => _selected = d),
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
          // Неделя листается собственной лентой колонок — жест принадлежит ей.
          // Остальные виды листает пейджер: сутки и месяц — единицы, которые
          // меняются целиком.
          child: view == CalendarView.week
              ? _body(range, inheritance, now, today, reading, monthMode)
              : LayoutBuilder(
                  builder: (context, box) => VPeriodPager(
                    step: box.maxWidth,
                    onShift: _shift,
                    child: _body(
                        range, inheritance, now, today, reading, monthMode),
                  ),
                ),
        ),
        if (_picking) _BulkBar(
          count: _picked.length,
          onMove: () => _askBulkMove(),
          onCalendar: () => _bulk(EventFlow(context, ref).changeCalendarMany),
          onDelete: () => _bulk(EventFlow(context, ref).deleteMany),
          onClose: _clearPicked,
        ),
        // Переключатель видов внизу: до верха экрана большой палец не достаёт.
        // В режиме выбора его нет — там свои действия над пачкой.
        if (!_picking)
          ViewDock(
            value: view,
            onChanged: (v) => setState(() => _view = v),
            onSettings: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(toolbarHeight: 56, leading: vBack(context)),
                  body: const SafeArea(top: false, child: SettingsScreen()),
                ),
              ),
            ),
            onSetup: switch (view) {
              CalendarView.week => _setupWeek,
              CalendarView.month => _setupMonth,
              _ => null,
            },
          ),
      ],
    );
  }

  /// Видимые колонки недели: раскладка решает, какие дни показывать.
  List<DateTime> _weekDays() {
    final layout = ref.read(weekLayoutProvider);
    final anchor = _weekAnchor;
    return anchor == null
        ? layout.daysOf(_selected!)
        : layout.window(anchor);
  }

  /// Подпись видимого отрезка. Месяц оставляем на откуп шапке: «Июль 2026»
  /// с годом второй гарнитурой — фирменная деталь экрана.
  String? _periodLabel(CalendarView view) {
    final day = _selected!;
    switch (view) {
      case CalendarView.month:
        return null;
      case CalendarView.day:
        // Короткий день недели: полное «Понедельник» обрезалось многоточием
        // ещё до месяца.
        final week = DateFormat.E('ru').format(day);
        return '${week[0].toUpperCase()}${week.substring(1)}, '
            '${DateFormat.MMMd('ru').format(day)}';
      case CalendarView.week:
        final days = _weekDays();
        return '${DateFormat.d('ru').format(days.first)} — '
            '${DateFormat.MMMd('ru').format(days.last)}';
    }
  }

  /// Строка под подписью: сколько событий и сколько времени занято.
  ///
  /// Считается по тем же данным, что рисует вид: второй счётчик разошёлся бы
  /// с картинкой на первом же скрытом календаре.
  String? _periodSummary(CalendarView view, RangeData range) {
    final l = L.of(context);
    final day = _selected!;
    final days = switch (view) {
      CalendarView.day => [day],
      CalendarView.week => _weekDays(),
      CalendarView.month => const <DateTime>[],
    };
    if (days.isEmpty) return null;

    var count = 0;
    var minutes = 0;
    for (final d in days) {
      for (final e in range.eventsOn(d)) {
        if (e.isMultiDay) continue;
        count++;
        minutes += e.duration.inMinutes;
      }
    }
    if (count == 0) return l.dayReviewFree;

    final busy = minutes >= 60
        ? (minutes % 60 == 0
            ? l.durationHours(minutes ~/ 60)
            : l.durationHoursMinutes(minutes ~/ 60, minutes % 60))
        : l.durationMinutes(minutes);
    return '${l.eventsCount(count)} · $busy';
  }

  /// День листом поверх месяца: события дня, а из него — либо событие, либо
  /// сам день целиком.
  Future<void> _openDaySheet(
    DateTime day,
    RangeData range,
    Inheritance inheritance,
  ) async {
    final choice = await showDaySheet(
      context,
      day: day,
      events: range.eventsOn(day),
      spans: range.spansOn(day),
      inheritance: inheritance,
    );
    if (choice == null || !mounted) return;

    if (choice.event != null) {
      await EventFlow(context, ref).preview(choice.event!);
      return;
    }
    setState(() {
      _selected = day;
      _view = CalendarView.day;
    });
  }

  /// Разбор дня: сколько занято, где окна, что наехало друг на друга.
  /// Выбранное окно тут же заводит событие — иначе разбор остался бы
  /// справкой, из которой всё равно идти в другое место.
  Future<void> _reviewDay(
    RangeData range,
    Inheritance inheritance,
    DateTime now,
  ) async {
    final day = _selected!;
    final slot = await showDayReview(
      context,
      review: reviewDay(
        range.eventsOn(day),
        day,
        now: _isToday(DateTime(now.year, now.month, now.day)) ? now : null,
      ),
      inheritance: inheritance,
    );
    if (slot == null || !mounted) return;
    await EventFlow(context, ref).create(at: slot.start);
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
  /// сутки за колонку, месяц — месяц.
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
      if (view == CalendarView.week) {
        // В неделе двигается окно, а не выбранный день: сдвиг на два дня
        // показывает конец прошлой недели рядом с началом этой.
        final layout = ref.read(weekLayoutProvider);
        final anchor = _weekAnchor ?? layout.weekStart(_selected!);
        _weekAnchor = anchor.add(Duration(days: direction));
        // Выбранный день едет следом, иначе окно событий перестанет совпадать
        // с тем, что видно на экране.
        _selected = _weekAnchor!;
        return;
      }

      final step = switch (view) {
        CalendarView.day => 1,
        CalendarView.week => 1,
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
      CalendarView.day when reading == DayReading.tape => TapeView(
          day: _selected!,
          events: range.eventsOn(_selected!),
          inheritance: inheritance,
          now: _isToday(today) ? now : null,
          onEventTap: onTap,
          onEventLongPress: _showEventMenu,
          selected: _picked.keys.toSet(),
          // Тап по свободному окну заводит событие с его началом: человек
          // ткнул в пустоту, значит хочет занять именно её.
          onFreeTap: _picking
              ? null
              : (slot) => EventFlow(context, ref).create(at: slot.start),
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
          // Лист поверх месяца, а не уход в другой вид: человек смотрит на
          // месяц, чтобы выбрать день, и терять картину целиком после первого
          // же тапа он не должен.
          onDayTap: (d) => _openDaySheet(d, range, inheritance),
          // Лента месяцев сама говорит, до какого долистали: по нему шапка
          // называет месяц, а окно событий держит нужный кусок базы.
          onMonthChanged: (month) => setState(() => _selected = month),
        ),
      CalendarView.week => WeekView(
          // Лента живёт своей прокруткой: экран отдаёт ей первый видимый день
          // и получает обратно тот, до которого долистали.
          anchor: _weekAnchor ??
              ref.watch(weekLayoutProvider).weekStart(_selected!),
          columns: ref.watch(weekLayoutProvider).weekdays.length,
          onAnchorChanged: (day) => setState(() {
            _weekAnchor = day;
            _selected = day;
          }),
          eventsOf: range.eventsOn,
          spans: range.spans,
          inheritance: inheritance,
          today: today,
          onEventTap: onTap,
          onEventLongPress: _showEventMenu,
          selected: _picked.keys.toSet(),
          // Тап мимо занятий уводит в этот день. В наборе пачки жест молчит:
          // человек отмечает события, и уход с вида сбил бы отбор.
          onDayTap: _picking
              ? null
              : (day) => setState(() {
                    _selected = day;
                    _weekAnchor = null;
                    _view = CalendarView.day;
                  }),
          // В неделе перенос идёт наискосок: и на другой час, и на другой
          // день одним движением.
          onEventMoved: _picking
              ? null
              : (e, shift) => EventFlow(context, ref).moveBy(e, shift),
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

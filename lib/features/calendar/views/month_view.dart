import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../widgets/month_header.dart';

/// Как день показывает свою занятость.
enum MonthMode {
  /// Чипы с иконкой и коротким названием: видно, что именно в этот день.
  chips,

  /// Только иконки: в ячейку влезает втрое больше, день читается по цвету.
  icons,

  /// Только подписи: без значков строка длиннее, и название читается целиком
  /// там, где иконка ничего не добавляет.
  labels,

  /// Тонированная ячейка: видно, чем занят день, без чтения текста.
  tint,

  /// Полоски по числу дел: цвет календаря и количество, без единой буквы.
  /// Названия в ячейку шириной в сорок точек всё равно не влезают, а плотность
  /// месяца читается с одного взгляда.
  bars,
}

/// Месяц. Россыпь мелких кружков под числом отвергнута — по ней ничего
/// не прочитать, поэтому режимов два с половиной и они переключаются
/// в настройках вида.
///
/// Сетка занимает всю высоту экрана и делит её между неделями поровну.
/// Прокрутки здесь нет намеренно: месяц отвечает на вопрос «когда», а ответ,
/// до которого надо доскроллить, на этот вопрос не отвечает.
class MonthView extends StatefulWidget {
  const MonthView({
    super.key,
    required this.month,
    required this.eventsOf,
    required this.spans,
    required this.inheritance,
    required this.today,
    this.mode = MonthMode.chips,
    this.maxChips = 2,
    this.onDayTap,
    this.onMonthChanged,
  });

  final DateTime month;
  final List<VEvent> Function(DateTime) eventsOf;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final DateTime today;
  final MonthMode mode;
  final int maxChips;

  /// Тап по дню: месяц отвечает «когда», день — «что именно».
  final ValueChanged<DateTime>? onDayTap;

  /// Лента доехала до другого месяца — шапка должна назвать его.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Начало отсчёта недель. Как и в неделе, счёт идёт в UTC: в местном
  /// времени сутки перевода часов длятся 23 или 25 часов, и номер недели за
  /// четверть века уезжает на единицу.
  static final DateTime epoch = DateTime.utc(1999, 12, 27);

  /// Номер недели в ленте.
  static int weekIndexOf(DateTime day) {
    final date = DateTime.utc(day.year, day.month, day.day);
    return date.difference(epoch).inDays ~/ 7;
  }

  /// Понедельник недели по её номеру, уже в местном календаре.
  static DateTime weekStartAt(int index) {
    final utc = epoch.add(Duration(days: index * 7));
    return DateTime(utc.year, utc.month, utc.day);
  }

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  final ScrollController _controller = ScrollController();

  /// Высота строки недели. Считается от высоты вида, чтобы месяц занимал
  /// экран целиком, а не жался вверху.
  double _rowHeight = 0;
  bool _placed = false;

  /// Месяц, который лента показывает сейчас.
  late DateTime _visible = widget.month;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MonthView old) {
    super.didUpdateWidget(old);
    // Месяц сменили снаружи — лента едет туда же, если сама там ещё не стоит.
    if ((widget.month.year != _visible.year ||
            widget.month.month != _visible.month) &&
        _controller.hasClients) {
      _visible = widget.month;
      _controller.jumpTo(
          MonthView.weekIndexOf(DateTime(widget.month.year, widget.month.month, 1)) *
              _rowHeight);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _place() {
    if (!_controller.hasClients || _rowHeight <= 0) return;
    _controller.jumpTo(
        MonthView.weekIndexOf(DateTime(_visible.year, _visible.month, 1)) *
            _rowHeight);
    _placed = true;
  }

  void _onScroll() {
    if (_rowHeight <= 0 || !_placed) return;
    // Месяцем считается тот, которому принадлежит середина экрана: по верхней
    // строке заголовок менялся бы на неделю раньше, чем месяц реально viden.
    final middle =
        ((_controller.offset + _controller.position.viewportDimension / 2) /
                _rowHeight)
            .floor();
    final day = MonthView.weekStartAt(middle).add(const Duration(days: 3));
    if (day.year == _visible.year && day.month == _visible.month) return;

    _visible = DateTime(day.year, day.month, 1);
    widget.onMonthChanged?.call(_visible);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return LayoutBuilder(builder: (context, box) {
      // Шесть строк на экран: столько недель бывает в месяце, и на этой
      // высоте ячейка ещё вмещает пару чипов.
      final height = (box.maxHeight - 26) / 6;
      if ((height - _rowHeight).abs() > 0.5 || !_placed) {
        _rowHeight = height;
        WidgetsBinding.instance.addPostFrameCallback((_) => _place());
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Text(
                      DateFormat.E(locale)
                          .format(MonthView.weekStartAt(0).add(Duration(days: i)))
                          .toLowerCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemExtent: height,
                // Недели идут подряд, а не месяцами: календарь листается
                // вверх и вниз без границ, и конец месяца виден рядом с
                // началом следующего.
                itemBuilder: (context, i) {
                  final week = [
                    for (var d = 0; d < 7; d++)
                      MonthView.weekStartAt(i).add(Duration(days: d)),
                  ];
                  return _Week(
                    week: week,
                    month: _visible,
                    eventsOf: widget.eventsOf,
                    spans: [
                      for (final s in widget.spans)
                        if (_touches(s, week)) s,
                    ],
                    inheritance: widget.inheritance,
                    today: widget.today,
                    mode: widget.mode,
                    maxChips: widget.maxChips,
                    onDayTap: widget.onDayTap,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Задевает ли лента хоть один день недели.
  static bool _touches(VEvent event, List<DateTime> week) {
    final from = DateTime(event.start.year, event.start.month, event.start.day);
    final to = event.lastDay;
    final first = week.first;
    final last = DateTime(week.last.year, week.last.month, week.last.day);
    return !from.isAfter(last) && !to.isBefore(first);
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Строка месяца: семь дней и ленты событий, которые их накрывают.
class _Week extends StatelessWidget {
  const _Week({
    required this.week,
    required this.month,
    required this.eventsOf,
    required this.spans,
    required this.inheritance,
    required this.today,
    required this.mode,
    required this.maxChips,
    this.onDayTap,
  });

  final List<DateTime> week;
  final DateTime month;
  final List<VEvent> Function(DateTime) eventsOf;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final DateTime today;
  final MonthMode mode;
  final int maxChips;
  final ValueChanged<DateTime>? onDayTap;

  /// Больше двух лент подряд съедают строку целиком, и от недели остаются одни
  /// полосы. Остальные видны в дне.
  static const int _maxSpans = 2;

  @override
  Widget build(BuildContext context) {
    final shown = spans.take(_maxSpans).toList();

    return Column(
      children: [
        // Ленты идут над числами своей недели. Снизу они читались как шапка
        // следующей строки: неделя, к которой относится «Летний курс», по
        // виду была не та.
        for (final s in shown)
          _SpanRow(event: s, week: week, inheritance: inheritance),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final day in week)
                Expanded(
                  child: _Cell(
                    day: day,
                    events: day.month == month.month ? eventsOf(day) : const [],
                    inheritance: inheritance,
                    isToday: _MonthViewState.sameDay(day, today),
                    isOutside: day.month != month.month,
                    mode: mode,
                    maxChips: maxChips,
                    onTap: onDayTap == null ? null : () => onDayTap!(day),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.events,
    required this.inheritance,
    required this.isToday,
    required this.isOutside,
    required this.mode,
    required this.maxChips,
    this.onTap,
  });

  final DateTime day;
  final List<VEvent> events;
  final Inheritance inheritance;
  final bool isToday;
  final bool isOutside;
  final MonthMode mode;
  final int maxChips;

  /// Тап по ячейке уводит в день: месяц отвечает на вопрос «когда», а
  /// подробности живут в дне.
  final VoidCallback? onTap;

  /// Высота строки чипа вместе с зазором.
  static const double _chipStep = 15;

  /// Место под числом: сама плашка числа плюс отступ.
  static const double _numberRoom = 32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Color? tint;
    if (mode == MonthMode.tint && events.isNotEmpty) {
      tint = EventColors.of(
              inheritance.colorOfEvent(events.first), theme.brightness)
          .soft;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: isOutside ? 0.35 : 1,
        child: Container(
          margin: const EdgeInsets.all(1.5),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: ShapeDecoration(
            color: tint ?? Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, box) => Column(
              children: [
                // Не круг фиксированной ширины: в 24 пикселя двузначное число
                // Unbounded'ом не влезает и обрезается пополам.
                Container(
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: isToday ? scheme.primary : Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    '${day.day}',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isToday ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
                if (events.isNotEmpty) _content(context, theme, box),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ThemeData theme, BoxConstraints box) {
    // Подпись в ячейке уже ячейки самого узкого телефона не читается: от неё
    // остаётся «Подъё». Там, где имя не влезает, день читается значком и
    // цветом, а имена смотрят в дне.
    final tooNarrow = box.maxWidth < 54;
    final shown = switch (mode) {
      MonthMode.chips when tooNarrow => MonthMode.icons,
      final m => m,
    };

    return switch (shown) {
      MonthMode.chips || MonthMode.labels => _Chips(
          events: events,
          inheritance: inheritance,
          brightness: theme.brightness,
          withIcon: shown == MonthMode.chips,
          // Сколько строк влезло по высоте, столько и показываем: настройка
          // задаёт потолок, а не обязанность вылезать за край ячейки.
          max: _roomForChips(box.maxHeight).clamp(1, maxChips),
          scheme: theme.colorScheme,
        ),
      MonthMode.icons => _Icons(
          events: events,
          inheritance: inheritance,
          brightness: theme.brightness,
          scheme: theme.colorScheme,
        ),
      MonthMode.bars => _Bars(
          events: events,
          inheritance: inheritance,
          brightness: theme.brightness,
        ),
      MonthMode.tint => Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${events.length}',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
    };
  }

  static int _roomForChips(double height) {
    if (!height.isFinite) return 2;
    // Строка «+N» занимает место наравне с чипом, поэтому вычитается заранее.
    final rows = ((height - _numberRoom) / _chipStep).floor() - 1;
    return rows < 1 ? 1 : rows;
  }
}

/// Полоски дня: одна на событие, цвет — цвет календаря.
///
/// Больше пяти не рисуем: дальше полоски сливаются в заливку и перестают
/// считаться. Шестое и следующие уходят в общий счёт — день и так занят.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.events,
    required this.inheritance,
    required this.brightness,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final Brightness brightness;

  static const int _max = 4;
  static const double _bar = 3;
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // Сколько полосок влезло, столько и рисуем: ячейка в шесть недель
        // ниже, чем в пять, и лишняя полоска вылезала за край.
        final room = box.maxHeight.isFinite
            ? ((box.maxHeight - 4) / (_bar + _gap)).floor()
            : _max;
        final shown = events.take(room.clamp(1, _max)).toList();
        return Padding(
      padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: _gap),
              child: Container(
                height: _bar,
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: EventColors.of(
                    inheritance.colorOfEvent(e),
                    brightness,
                  ).chip,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
        ],
      ),
        );
      },
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.events,
    required this.inheritance,
    required this.brightness,
    required this.scheme,
    required this.max,
    this.withIcon = true,
  });

  /// Показывать ли значок рядом с подписью.
  final bool withIcon;

  final List<VEvent> events;
  final Inheritance inheritance;
  final Brightness brightness;
  final ColorScheme scheme;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = events.take(max).toList();
    final rest = events.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in shown) ...[
            _chip(e),
            const SizedBox(height: 2),
          ],
          if (rest > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '+$rest',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(VEvent e) {
    final ink = EventColors.of(inheritance.colorOfEvent(e), brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: ShapeDecoration(
        color: ink.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            Icon(VehaIcons.byName(inheritance.iconOfEvent(e)),
                size: 9, color: ink.foreground),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              e.title,
              maxLines: 1,
              // Обрыв многоточием, а не по живому: «Подъё» читается как
              // ошибка вёрстки, «Подъ…» — как продолжение, которое есть в дне.
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: ink.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Icons extends StatelessWidget {
  const _Icons({
    required this.events,
    required this.inheritance,
    required this.brightness,
    required this.scheme,
  });

  final List<VEvent> events;
  final Inheritance inheritance;
  final Brightness brightness;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // Без переноса: вторая строка иконок делает ячейки разной высоты, и сетка
    // прыгает при перелистывании месяцев. В ячейку шириной 48 помещается три
    // значка либо два и счётчик — больше не влезает физически.
    final capacity = events.length > 3 ? 2 : 3;
    final shown = events.take(capacity).toList();
    final rest = events.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _dot(shown[i]),
          ],
          if (rest > 0)
            Text(
              ' +$rest',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _dot(VEvent e) {
    final ink = EventColors.of(inheritance.colorOfEvent(e), brightness);
    // 13 логических пикселей — предел: три значка с зазорами ровно укладываются
    // в ячейку шириной 48 вместе с её внутренними отступами.
    return Container(
      width: 13,
      height: 13,
      alignment: Alignment.center,
      decoration:
          ShapeDecoration(color: ink.background, shape: const CircleBorder()),
      child: Icon(VehaIcons.byName(inheritance.iconOfEvent(e)),
          size: 8.5, color: ink.foreground),
    );
  }
}

/// Отрезок многодневного события внутри одной недели.
class _SpanRow extends StatelessWidget {
  const _SpanRow({
    required this.event,
    required this.week,
    required this.inheritance,
  });

  final VEvent event;
  final List<DateTime> week;
  final Inheritance inheritance;

  @override
  Widget build(BuildContext context) {
    final from = event.start;
    final to = event.lastDay;

    var startIdx = -1;
    var endIdx = -1;
    for (var i = 0; i < week.length; i++) {
      final d = DateTime(week[i].year, week[i].month, week[i].day);
      if (!d.isBefore(DateTime(from.year, from.month, from.day)) &&
          !d.isAfter(DateTime(to.year, to.month, to.day))) {
        if (startIdx < 0) startIdx = i;
        endIdx = i;
      }
    }
    if (startIdx < 0) return const SizedBox.shrink();

    final ink = EventColors.of(
        inheritance.colorOfEvent(event), Theme.of(context).brightness);
    final startsHere = _sameDay(week[startIdx], from);
    final endsHere = _sameDay(week[endIdx], to);

    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 2),
      child: Row(
        children: [
          // Полоса — один контейнер на весь захваченный отрезок, а не заливка
          // по ячейкам: иначе подпись обрезается шириной одной колонки.
          if (startIdx > 0) Spacer(flex: startIdx),
          Expanded(
            flex: endIdx - startIdx + 1,
            child: Container(
              height: 14,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: ShapeDecoration(
                color: ink.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(startsHere ? 999 : 0),
                    right: Radius.circular(endsHere ? 999 : 0),
                  ),
                ),
              ),
              // Подписана каждая неделя, а не только первая. Безымянная полоса
              // через полмесяца — цветной мусор: человек видит, что что-то
              // идёт, и не знает что.
              child: Text(
                endsHere ? event.title : '${event.title} →',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: ink.foreground,
                ),
              ),
            ),
          ),
          if (endIdx < 6) Spacer(flex: 6 - endIdx),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../common/snap_physics.dart';
import 'month_header.dart';

/// Горизонтальная лента дат под заголовком.
///
/// Листается пальцем в обе стороны без конца — как мини-календарь, а не
/// стрелками по краям. Стрелки отсюда убраны: они отнимали место у двух дней
/// и делали вид, что дальше недели ничего нет.
///
/// Лента встаёт на день и щёлкает на каждом пройденном: остановиться на
/// половине даты нельзя, а палец считает дни, даже когда глаз смотрит на
/// события.
class WeekStrip extends StatefulWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    this.busyDays = const {},
    this.onSelect,
    this.columns = 7,
  });

  /// Выбранный день: он подсвечен и от него лента считает своё положение.
  final DateTime selected;

  /// Дни, где что-то запланировано: под числом появляется точка.
  final Set<DateTime> busyDays;
  final ValueChanged<DateTime>? onSelect;

  /// Сколько дат видно разом.
  final int columns;

  /// Начало отсчёта ленты — то же, что у недели: счёт в UTC, иначе сутки
  /// перевода часов сдвигают номера.
  static final DateTime epoch = DateTime.utc(2000);

  static int indexOf(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).difference(epoch).inDays;

  static DateTime dayAt(int index) {
    final utc = epoch.add(Duration(days: index));
    return DateTime(utc.year, utc.month, utc.day);
  }

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  final ScrollController _controller = ScrollController();
  double _cellWidth = 0;
  bool _placed = false;

  /// Первая видимая дата.
  late DateTime _first = _weekStart(widget.selected);

  /// Понедельник недели выбранного дня: лента открывается началом недели, а
  /// не самим днём — так привычнее, чем «сегодня» в левом углу.
  static DateTime _weekStart(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(WeekStrip old) {
    super.didUpdateWidget(old);
    if (WeekStrip.indexOf(old.selected) == WeekStrip.indexOf(widget.selected)) {
      return;
    }
    // День выбрали снаружи: лента подтягивается, только если он ушёл из виду.
    final index = WeekStrip.indexOf(widget.selected);
    final firstIndex = WeekStrip.indexOf(_first);
    if (index >= firstIndex && index < firstIndex + widget.columns) return;
    if (!_controller.hasClients) return;

    _first = _weekStart(widget.selected);
    _controller.jumpTo(WeekStrip.indexOf(_first) * _cellWidth);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _place() {
    if (!_controller.hasClients || _cellWidth <= 0) return;
    _controller.jumpTo(WeekStrip.indexOf(_first) * _cellWidth);
    _placed = true;
  }

  void _onScroll() {
    if (_cellWidth <= 0 || !_placed) return;
    final day = WeekStrip.dayAt((_controller.offset / _cellWidth).round());
    if (WeekStrip.indexOf(day) == WeekStrip.indexOf(_first)) return;

    setState(() => _first = day);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Сокращения дней берём из локали, а не списком: в польском это «pon»,
    // в румынском «lun», руками такое не поддержать на семи языках.
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dow = DateFormat.E(locale);

    return LayoutBuilder(builder: (context, box) {
      final width = box.maxWidth / widget.columns;
      if ((width - _cellWidth).abs() > 0.5 || !_placed) {
        _cellWidth = width;
        WidgetsBinding.instance.addPostFrameCallback((_) => _place());
      }

      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          // Подпись дня, круг с числом и точка занятости: 68 — ровно столько,
          // сколько им нужно вместе с зазорами.
          height: 68,
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemExtent: width,
            physics: SnapToStep(step: width),
            padding: EdgeInsets.zero,
            itemBuilder: (context, i) {
              final day = WeekStrip.dayAt(i);
              return GestureDetector(
                onTap: () => widget.onSelect?.call(day),
                behavior: HitTestBehavior.opaque,
                child: _Day(
                  dow: dow.format(day).toLowerCase(),
                  date: day,
                  isSelected: WeekStrip.indexOf(day) ==
                      WeekStrip.indexOf(widget.selected),
                  isWeekend: day.weekday >= 6,
                  isBusy: widget.busyDays.any((d) =>
                      d.year == day.year &&
                      d.month == day.month &&
                      d.day == day.day),
                  scheme: scheme,
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.dow,
    required this.date,
    required this.isSelected,
    required this.isWeekend,
    required this.isBusy,
    required this.scheme,
  });

  final String dow;
  final DateTime date;
  final bool isSelected;
  final bool isWeekend;
  final bool isBusy;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dow,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            shape: const CircleBorder(),
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? scheme.onPrimary
                  : isWeekend
                      ? scheme.outline
                      : scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 5,
          child: isBusy
              ? Container(
                  width: 5,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: scheme.primary.withValues(alpha: 0.55),
                    shape: const CircleBorder(),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import 'month_header.dart';

/// Горизонтальная лента дат недели под заголовком.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.week,
    required this.selected,
    this.busyDays = const {},
    this.onSelect,
  });

  final List<DateTime> week;
  final DateTime selected;

  /// Дни, где что-то запланировано: под числом появляется точка.
  final Set<int> busyDays;
  final ValueChanged<DateTime>? onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Сокращения дней берём из локали, а не списком: в польском это «pon»,
    // в румынском «lun», руками такое не поддержать на семи языках.
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dow = DateFormat.E(locale);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 16, VehaInsets.screen, 0),
      child: Row(
        children: [
          for (var i = 0; i < week.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect?.call(week[i]),
                behavior: HitTestBehavior.opaque,
                child: _Day(
                  dow: dow.format(week[i]).toLowerCase(),
                  date: week[i],
                  isSelected: _sameDay(week[i], selected),
                  isWeekend: i >= 5,
                  isBusy: busyDays.contains(week[i].day),
                  scheme: scheme,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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

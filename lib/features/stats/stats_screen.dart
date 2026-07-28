import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/providers.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// Период итогов. Год отдельным пунктом: «сколько я в этом году учился» —
/// вопрос, ради которого статистику и открывают.
enum StatsPeriod { week, month, year }

/// Итоги: чем занято время и куда оно уходит.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsPeriod _period = StatsPeriod.week;

  ({DateTime from, DateTime to}) _window(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (_period) {
      StatsPeriod.week => (
          from: today.subtract(Duration(days: today.weekday - 1)),
          to: today
              .subtract(Duration(days: today.weekday - 1))
              .add(const Duration(days: 7)),
        ),
      StatsPeriod.month => (
          from: DateTime(today.year, today.month, 1),
          to: DateTime(today.year, today.month + 1, 1),
        ),
      StatsPeriod.year => (
          from: DateTime(today.year, 1, 1),
          to: DateTime(today.year + 1, 1, 1),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final window = _window(ref.watch(nowProvider));
    final range = ref.watch(rangeProvider(window)).valueOrNull;
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;

    final stats = range == null
        ? Stats.empty
        : computeStats(
            events: [for (final day in range.byDay.values) ...day, ...range.spans],
            tasks: tasks,
            from: window.from,
            to: window.to,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 40),
      children: [
        Text(
          l.statsTitle,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            letterSpacing: -1,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final p in StatsPeriod.values) ...[
              _PeriodChip(
                label: switch (p) {
                  StatsPeriod.week => l.statsWeek,
                  StatsPeriod.month => l.statsMonth,
                  StatsPeriod.year => l.statsYear,
                },
                selected: p == _period,
                onTap: () => setState(() => _period = p),
              ),
              if (p != StatsPeriod.values.last) const SizedBox(width: 7),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (stats.isEmpty)
          _Note(text: l.statsEmpty)
        else ...[
          Row(
            children: [
              Expanded(
                child: _Number(
                  icon: 'clock',
                  label: l.statsBusyTime,
                  value: _hours(l, stats.busy),
                  accent: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Number(
                  icon: 'calendar',
                  label: l.statsEventCount,
                  value: '${stats.events}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Number(
                  icon: 'check',
                  label: l.statsTasksClosed,
                  value: '${stats.tasksDone}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Number(
                  icon: 'today',
                  label: l.statsPerDay,
                  value: _hours(l, stats.perDay),
                ),
              ),
            ],
          ),
          if (inheritance != null && stats.byCalendar.isNotEmpty) ...[
            VBlockCap(l.statsByCalendar),
            VBlock(children: [
              for (final entry in _sorted(stats))
                _CalendarBar(
                  name: inheritance.calendars[entry.key]?.name ?? entry.key,
                  color: inheritance.calendars[entry.key]?.color ??
                      scheme.primary,
                  amount: _hours(l, entry.value),
                  share: stats.busy.inMinutes == 0
                      ? 0
                      : entry.value.inMinutes / stats.busy.inMinutes,
                ),
            ]),
          ],
          VBlockCap(l.statsByWeekday),
          _Weekdays(stats: stats, locale: locale),
          if (stats.busiestDay != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: VBlock(children: [
                VRow(
                  icon: 'bar_chart',
                  label: l.statsBusiestDay,
                  value: '${DateFormat('EEEE, d MMMM', locale).format(stats.busiestDay!)} · '
                      '${_hours(l, stats.busiestAmount)}',
                ),
              ]),
            ),
        ],
      ],
    );
  }

  /// Календари по убыванию времени: первым тот, куда его ушло больше.
  static List<MapEntry<String, Duration>> _sorted(Stats stats) {
    final entries = stats.byCalendar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// «7,5 ч». Минуты дробью, а не отдельной подписью: две единицы в одной
  /// цифре читаются медленнее.
  static String _hours(L l, Duration d) {
    final hours = d.inMinutes / 60;
    final text = hours >= 10
        ? hours.round().toString()
        : hours.toStringAsFixed(1).replaceAll('.', ',');
    return l.statsHoursShort(text);
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color:
              selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String icon;
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        accent ? scheme.primaryContainer : scheme.surfaceContainer;
    final foreground =
        accent ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: ShapeDecoration(
        color: background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(VehaIcons.byName(icon), size: 19, color: foreground),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 24,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
              color: accent ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Доля календаря полосой. Заливка, а не обводка: обводок в приложении нет.
class _CalendarBar extends StatelessWidget {
  const _CalendarBar({
    required this.name,
    required this.color,
    required this.amount,
    required this.share,
  });

  final String name;
  final Color color;
  final String amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(color, theme.brightness);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Row(
              children: [
                Expanded(
                  flex: (share * 1000).round().clamp(1, 1000),
                  // Долю красим самим цветом календаря: тон 10 почти чёрный,
                  // и на полосе «Учёба» неотличима от «Работы».
                  child: Container(height: 8, color: color),
                ),
                Expanded(
                  flex: ((1 - share) * 1000).round().clamp(0, 1000),
                  child: Container(height: 8, color: ink.background),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Столбики по дням недели: где неделя проседает и где её перегружают.
class _Weekdays extends StatelessWidget {
  const _Weekdays({required this.stats, required this.locale});

  final Stats stats;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final peak = stats.byWeekday
        .fold<int>(0, (max, d) => d.inMinutes > max ? d.inMinutes : max);

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 12),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 84,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: peak == 0
                              ? 4
                              : (stats.byWeekday[i].inMinutes / peak * 80)
                                  .clamp(4, 80),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: ShapeDecoration(
                            color: stats.byWeekday[i].inMinutes == peak &&
                                    peak > 0
                                ? scheme.primary
                                : scheme.primaryContainer,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _shortWeekday(i, locale),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Имена дней берём у intl: свой список означал бы семь языков вручную.
  static String _shortWeekday(int index, String locale) {
    final monday = DateTime(2026, 7, 27).add(Duration(days: index));
    return DateFormat.E(locale).format(monday);
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

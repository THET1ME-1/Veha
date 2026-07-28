import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../domain/recurrence.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';
import 'repeat_rule.dart';

/// Правило повторения. Собирается по частям, а внизу всегда видны ближайшие
/// даты: ошибку в правиле человек ловит сразу, а не через месяц.
///
/// Экран возвращает готовый RRULE либо `null`, если повторение отключили.
class RepeatScreen extends StatefulWidget {
  const RepeatScreen({super.key, required this.from, this.initial});

  final DateTime from;
  final String? initial;

  @override
  State<RepeatScreen> createState() => _RepeatScreenState();
}

class _RepeatScreenState extends State<RepeatScreen> {
  late RepeatRule _rule = RepeatRule.parse(widget.initial, widget.from);

  /// Единицы шага повторения. Функция, а не константа: слова приходят из
  /// словаря, а он знает язык только через контекст.
  static Map<RepeatUnit, String> _units(L l) => {
        RepeatUnit.day: l.unitDays,
        RepeatUnit.week: l.unitWeeks,
        RepeatUnit.month: l.unitMonths,
        RepeatUnit.year: l.unitYears,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final rrule = _rule.toRrule(widget.from);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              VehaInsets.screen, 6, VehaInsets.screen, 40),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      L.of(context).repeatTitle,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 27,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_Result(rrule)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(L.of(context).actionDone),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _Preset(
                  label: L.of(context).repeatNever2,
                  selected: !_rule.repeats,
                  onTap: () => setState(() => _rule = const RepeatRule.none()),
                ),
                _Preset(
                  label: L.of(context).repeatDaily,
                  selected: _rule.unit == RepeatUnit.day && _rule.interval == 1,
                  onTap: () => setState(() =>
                      _rule = const RepeatRule(unit: RepeatUnit.day)),
                ),
                _Preset(
                  label: L.of(context).repeatWeekdays,
                  selected: _rule.unit == RepeatUnit.week &&
                      _rule.interval == 1 &&
                      _rule.weekdays.length == 5 &&
                      _rule.weekdays.every((d) => d <= 5),
                  onTap: () => setState(() => _rule = const RepeatRule(
                        unit: RepeatUnit.week,
                        weekdays: {1, 2, 3, 4, 5},
                      )),
                ),
                _Preset(
                  label: L.of(context).repeatWeekly,
                  selected: _rule.unit == RepeatUnit.week &&
                      _rule.interval == 1 &&
                      _rule.weekdays.length <= 1,
                  onTap: () => setState(() => _rule = RepeatRule(
                        unit: RepeatUnit.week,
                        weekdays: {widget.from.weekday},
                      )),
                ),
              ],
            ),
            if (_rule.repeats) ...[
              const SizedBox(height: 14),
              VBlock(children: [
                _EveryRow(
                  value: _rule.interval,
                  unit: _units(L.of(context))[_rule.unit] ?? '',
                  onChanged: (v) =>
                      setState(() => _rule = _rule.copyWith(interval: v)),
                ),
                const VSep(inset: 15),
                _UnitRow(
                  value: _rule.unit,
                  onChanged: (v) =>
                      setState(() => _rule = _rule.copyWith(unit: v)),
                ),
                if (_rule.unit == RepeatUnit.week) ...[
                  const VSep(inset: 15),
                  _Weekdays(
                    selected: _rule.weekdays.isEmpty
                        ? {widget.from.weekday}
                        : _rule.weekdays,
                    onToggle: (d) => setState(() {
                      final next = (_rule.weekdays.isEmpty
                              ? {widget.from.weekday}
                              : _rule.weekdays)
                          .toSet();
                      next.contains(d) ? next.remove(d) : next.add(d);
                      _rule = _rule.copyWith(weekdays: next);
                    }),
                  ),
                ],
              ]),
              VBlockCap(L.of(context).repeatEndsWhen),
              VBlock(children: [
                VOption(
                  title: L.of(context).repeatNever,
                  selected: _rule.count == null && _rule.until == null,
                  onTap: () => setState(() =>
                      _rule = _rule.copyWith(count: null, until: null)),
                ),
                const VSep(inset: 15),
                VOption(
                  title: L.of(context).repeatAfterSome,
                  subtitle: _rule.count == null ? null : '${_rule.count} ${L.of(context).repeatTimes}',
                  selected: _rule.count != null,
                  onTap: () => setState(() =>
                      _rule = _rule.copyWith(count: _rule.count ?? 10, until: null)),
                ),
                if (_rule.count != null) ...[
                  const VSep(inset: 15),
                  _EveryRow(
                    value: _rule.count!,
                    unit: L.of(context).repeatTimes,
                    label: L.of(context).repeatCountLabel,
                    onChanged: (v) =>
                        setState(() => _rule = _rule.copyWith(count: v)),
                  ),
                ],
                const VSep(inset: 15),
                VOption(
                  title: L.of(context).repeatUntilDate,
                  subtitle: _rule.until == null
                      ? null
                      : DateFormat('d MMMM y', locale).format(_rule.until!),
                  selected: _rule.until != null,
                  onTap: _pickUntil,
                ),
              ]),
              VBlockCap(L.of(context).repeatNextDates),
              _Preview(rrule: rrule, from: widget.from, locale: locale),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rule.until ?? widget.from.add(const Duration(days: 90)),
      firstDate: widget.from,
      lastDate: DateTime(widget.from.year + 10),
    );
    if (picked == null) return;
    setState(() => _rule = _rule.copyWith(until: picked, count: null));
  }
}

/// Результат экрана. Обёртка нужна, чтобы отличить «выбрал не повторять»
/// (правило `null`) от «вышел кнопкой назад» (весь результат `null`).
class _Result {
  const _Result(this.rrule);

  final String? rrule;
}

/// Возвращает выбранное правило: `null` — человек ушёл, ничего не меняя.
Future<String?> askRepeatRule(
  BuildContext context, {
  required DateTime from,
  String? initial,
}) async {
  final result = await Navigator.of(context).push<_Result>(
    MaterialPageRoute(
      builder: (_) => RepeatScreen(from: from, initial: initial),
    ),
  );
  return result?.rrule;
}

/// Отдельно от экрана: без предпросмотра человек узнаёт об ошибке в правиле
/// через месяц, когда занятие не пришло.
class _Preview extends StatelessWidget {
  const _Preview({required this.rrule, required this.from, required this.locale});

  final String? rrule;
  final DateTime from;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (rrule == null) return const SizedBox.shrink();

    final dates = Recurrence.expand(
      rrule: rrule!,
      start: from,
      windowStart: from,
      windowEnd: from.add(const Duration(days: 400)),
    ).take(6).toList();

    if (dates.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      return Text(
        L.of(context).repeatNoDates,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: scheme.error,
        ),
      );
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (var i = 0; i < dates.length; i++)
          _DateChip(
            text: DateFormat('EEE d MMM', locale).format(dates[i]),
            first: i == 0,
          ),
      ],
    );
  }
}

class _Preset extends StatelessWidget {
  const _Preset({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: ShapeDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
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

class _EveryRow extends StatelessWidget {
  const _EveryRow({
    required this.value,
    required this.unit,
    required this.onChanged,
    this.label,
  });

  final int value;
  final String unit;

  /// Подпись строки. `null` — «Каждые» из словаря.
  final String? label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label ?? L.of(context).repeatEvery,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$value $unit',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          _Step(
            icon: 'add',
            onTap: value < 99 ? () => onChanged(value + 1) : null,
          ),
          const SizedBox(width: 8),
          _Step(
            icon: 'undo',
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHighest,
          shape: const CircleBorder(),
        ),
        child: Icon(
          VehaIcons.byName(icon),
          size: 18,
          color: onTap == null ? scheme.outline : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.value, required this.onChanged});

  final RepeatUnit value;
  final ValueChanged<RepeatUnit> onChanged;

  static Map<RepeatUnit, String> _labels(L l) => {
        RepeatUnit.day: l.unitDay,
        RepeatUnit.week: l.unitWeek,
        RepeatUnit.month: l.unitMonth,
        RepeatUnit.year: l.unitYear,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 4, 15, 12),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final entry in _labels(L.of(context)).entries)
            _Preset(
              label: entry.value,
              selected: value == entry.key,
              onTap: () => onChanged(entry.key),
            ),
        ],
      ),
    );
  }
}

class _Weekdays extends StatelessWidget {
  const _Weekdays({required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final short = DateFormat.E(locale);

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 4, 15, 14),
      child: Row(
        children: [
          for (var d = 1; d <= 7; d++) ...[
            Expanded(
              child: InkWell(
                onTap: () => onToggle(d),
                borderRadius: BorderRadius.circular(99),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: selected.contains(d)
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      shape: const CircleBorder(),
                    ),
                    child: Text(
                      short.format(DateTime(2026, 1, 4 + d)).toLowerCase(),
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected.contains(d)
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (d < 7) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.text, required this.first});

  final String text;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: first ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: first ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

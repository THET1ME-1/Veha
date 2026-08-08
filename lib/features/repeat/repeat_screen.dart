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

  /// Частота одной фразой: «каждую неделю», «каждые 3 месяца».
  ///
  /// Собирать её из числа и слова нельзя: в русском три формы множественного
  /// числа, и склейка выдавала «1 недели». Формы живут в словаре, по одной на
  /// язык — там же, где о них знают.
  static String _howOften(L l, RepeatUnit unit, int interval) => switch (unit) {
        RepeatUnit.day => l.everyDays(interval),
        RepeatUnit.week => l.everyWeeks(interval),
        RepeatUnit.month => l.everyMonths(interval),
        RepeatUnit.year => l.everyYears(interval),
        RepeatUnit.none => '',
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
                  // Готовая фраза вместо склейки «1» и «недели»: в русском
                  // число меняет форму слова, и склейка давала «1 недели».
                  text: _howOften(L.of(context), _rule.unit, _rule.interval),
                  label: L.of(context).repeatHowOften,
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
                // Месяц без этого выбора описывает только «27-го числа»:
                // расписание занятий и последний рабочий день так не задать,
                // а без них календарь не покрывает и половины реальных рядов.
                if (_rule.unit == RepeatUnit.month) ...[
                  const VSep(inset: 15),
                  _MonthRules(
                    from: widget.from,
                    value: _rule.monthRule,
                    onChanged: (v) =>
                        setState(() => _rule = _rule.copyWith(monthRule: v)),
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
                  // Число видно и до выбора: «после нескольких повторов» не
                  // говорит, скольких именно, и человек жмёт наугад.
                  subtitle:
                      '${_rule.count ?? 10} ${L.of(context).repeatTimes}',
                  selected: _rule.count != null,
                  onTap: () => setState(() =>
                      _rule = _rule.copyWith(count: _rule.count ?? 10, until: null)),
                ),
                if (_rule.count != null) ...[
                  const VSep(inset: 15),
                  _EveryRow(
                    value: _rule.count!,
                    text: '${_rule.count} ${L.of(context).repeatTimes}',
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
    required this.text,
    required this.onChanged,
    this.label,
  });

  final int value;

  /// Готовая фраза: «каждые 2 недели», «10 раз».
  final String text;

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
                  text[0].toUpperCase() + text.substring(1),
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
          // Минус слева от плюса: пара шаговых кнопок читается как ось, и
          // убывание слева — то, чего ждёт рука. Раньше на месте минуса стояла
          // стрелка «отменить» — она обещала откат правки, а не шаг вниз.
          _Step(
            icon: 'remove',
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          const SizedBox(width: 8),
          _Step(
            icon: 'add',
            onTap: value < 99 ? () => onChanged(value + 1) : null,
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

/// Чем месяц отмеряет дату повтора.
///
/// Подписи конкретные, а не «По числу» и «По позиции»: человек выбирает не
/// разновидность правила, а свой случай — «27-го числа» либо «второй вторник».
/// Число и день недели берутся из самого события, поэтому читать нечего.
class _MonthRules extends StatelessWidget {
  const _MonthRules({
    required this.from,
    required this.value,
    required this.onChanged,
  });

  final DateTime from;
  final MonthRule value;
  final ValueChanged<MonthRule> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Падеж порядкового зависит от рода дня недели: «второй вторник», но
    // «вторая пятница». Списки уже собраны для подписи правила в карточке.
    final ordinals = switch (RepeatRule.weekPosition(from)) {
      -1 => l.ordinalLast,
      1 => l.ordinal1,
      2 => l.ordinal2,
      3 => l.ordinal3,
      _ => l.ordinal4,
    }
        .split(',');
    final weekday = DateFormat.EEEE(locale).format(from).toLowerCase();
    final position = '${ordinals[from.weekday - 1]} $weekday';

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 4, 15, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.monthRuleTitle,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _Preset(
                label: l.monthOnDay(from.day),
                selected: value == MonthRule.byDate,
                onTap: () => onChanged(MonthRule.byDate),
              ),
              _Preset(
                label: position[0].toUpperCase() + position.substring(1),
                selected: value == MonthRule.byWeekday,
                onTap: () => onChanged(MonthRule.byWeekday),
              ),
              _Preset(
                label: l.monthLastWorkday,
                selected: value == MonthRule.lastWorkday,
                onTap: () => onChanged(MonthRule.lastWorkday),
              ),
            ],
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

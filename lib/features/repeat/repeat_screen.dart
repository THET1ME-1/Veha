import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

/// Что делать, если экземпляр выпал на выходной или праздник.
enum HolidayRule { keep, moveToWorkday, skip }

/// Правило повторения. Собирается по частям, а внизу всегда видны ближайшие
/// даты: ошибку в правиле человек ловит сразу, а не через месяц.
class RepeatScreen extends StatefulWidget {
  const RepeatScreen({super.key, required this.from});

  final DateTime from;

  @override
  State<RepeatScreen> createState() => _RepeatScreenState();
}

class _RepeatScreenState extends State<RepeatScreen> {
  int _every = 2;
  int _unit = 1; // 0 — день, 1 — неделя, 2 — месяц
  final Set<int> _weekdays = {1, 4};
  HolidayRule _holiday = HolidayRule.keep;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            'Повторение',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 27,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final p in const ['Не повторять', 'Каждый день', 'По будням'])
              _Preset(label: p, selected: false),
            const _Preset(label: 'Своё правило', selected: true),
          ],
        ),
        const SizedBox(height: 14),
        VBlock(children: [
          _EveryRow(
            value: _every,
            onChanged: (v) => setState(() => _every = v),
          ),
          const VSep(inset: 15),
          _UnitRow(
            value: _unit,
            onChanged: (v) => setState(() => _unit = v),
          ),
          const VSep(inset: 15),
          _Weekdays(
            selected: _weekdays,
            onToggle: (d) => setState(() {
              _weekdays.contains(d) ? _weekdays.remove(d) : _weekdays.add(d);
            }),
          ),
        ]),
        const VBlockCap('Если выпадает на выходной или праздник'),
        VBlock(children: [
          VOption(
            title: 'Оставить как есть',
            selected: _holiday == HolidayRule.keep,
            onTap: () => setState(() => _holiday = HolidayRule.keep),
          ),
          const VSep(inset: 15),
          VOption(
            title: 'Перенести на ближайший будний',
            subtitle: 'Вперёд, если это не конец правила',
            selected: _holiday == HolidayRule.moveToWorkday,
            onTap: () => setState(() => _holiday = HolidayRule.moveToWorkday),
          ),
          const VSep(inset: 15),
          VOption(
            title: 'Пропустить этот раз',
            selected: _holiday == HolidayRule.skip,
            onTap: () => setState(() => _holiday = HolidayRule.skip),
          ),
        ]),
        const VBlockCap('Ближайшие даты'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (var i = 0; i < nextDates(widget.from, _every, _weekdays, 6).length; i++)
              _DateChip(
                text: DateFormat('EEE d MMM', locale)
                    .format(nextDates(widget.from, _every, _weekdays, 6)[i]),
                first: i == 0,
              ),
          ],
        ),
      ],
    );
  }
}

/// Ближайшие даты по правилу «каждые N недель по выбранным дням».
///
/// Считается здесь, а не в UI: предпросмотр — единственная защита от
/// неверного правила, и он должен быть проверяем тестом.
List<DateTime> nextDates(
  DateTime from,
  int everyWeeks,
  Set<int> weekdays,
  int count,
) {
  if (weekdays.isEmpty || everyWeeks < 1) return const [];
  final result = <DateTime>[];
  final startWeek = _weekStart(from);
  var cursor = DateTime(from.year, from.month, from.day);

  while (result.length < count) {
    cursor = cursor.add(const Duration(days: 1));
    if (!weekdays.contains(cursor.weekday)) continue;
    final weeksPassed =
        _weekStart(cursor).difference(startWeek).inDays ~/ 7;
    if (weeksPassed % everyWeeks != 0) continue;
    result.add(cursor);
  }
  return result;
}

DateTime _weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

class _Preset extends StatelessWidget {
  const _Preset({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: ShapeDecoration(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: selected
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EveryRow extends StatelessWidget {
  const _EveryRow({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Повторять каждые',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Считается от первой даты',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: scheme.surfaceContainerHigh,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(
                  icon: 'add',
                  rotated: true,
                  onTap: () => onChanged(value > 1 ? value - 1 : 1),
                ),
                SizedBox(
                  width: 30,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                _StepButton(icon: 'add', onTap: () => onChanged(value + 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    this.rotated = false,
  });

  final String icon;
  final VoidCallback onTap;

  /// Минус рисуется тем же плюсом, повёрнутым и обрезанным по горизонтали:
  /// отдельная иконка ради одной черты в белый список не просится.
  final bool rotated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHighest,
          shape: const CircleBorder(),
        ),
        child: rotated
            ? Container(width: 13, height: 2.4, color: scheme.onSurface)
            : Icon(VehaIcons.byName(icon), size: 15, color: scheme.onSurface),
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const labels = ['дня', 'недели', 'месяца'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Единица',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          for (var i = 0; i < labels.length; i++) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: ShapeDecoration(
                  color: i == value
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHigh,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: i == value
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
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
    final fmt = DateFormat.E(locale);
    // Понедельник ближайшей недели — просто донор дат для подписей.
    final monday = DateTime(2026, 7, 27);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
          child: Text(
            'По дням недели',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
          child: Row(
            children: [
              for (var d = 1; d <= 7; d++) ...[
                if (d > 1) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onToggle(d),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: selected.contains(d)
                              ? scheme.primary
                              : scheme.surfaceContainerHigh,
                          shape: const CircleBorder(),
                        ),
                        child: Text(
                          fmt.format(monday.add(Duration(days: d - 1))).toLowerCase(),
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12.5,
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
              ],
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

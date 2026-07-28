import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import '../../../core/icon_registry.dart';
import '../../../domain/week_layout.dart';
import 'month_header.dart' show AppFonts;

/// Настройка вида «Неделя»: какие дни показывать и с какого начинать.
Future<WeekLayout?> askWeekLayout(
  BuildContext context,
  WeekLayout current,
) {
  return showModalBottomSheet<WeekLayout>(
    context: context,
    showDragHandle: true,
    builder: (context) => _WeekSetupSheet(layout: current),
  );
}

class _WeekSetupSheet extends StatefulWidget {
  const _WeekSetupSheet({required this.layout});

  final WeekLayout layout;

  @override
  State<_WeekSetupSheet> createState() => _WeekSetupSheetState();
}

class _WeekSetupSheetState extends State<_WeekSetupSheet> {
  late WeekLayout _layout = widget.layout;

  /// Готовые наборы дней. Функция, а не константа: подписи из словаря.
  static List<(String, Set<int>)> _presets(L l) => [
        (l.weekSetupAll, const {1, 2, 3, 4, 5, 6, 7}),
        (l.weekSetupWorkdays, const {1, 2, 3, 4, 5}),
        (l.weekSetupWeekend, const {6, 7}),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final short = DateFormat.E(locale);

    // 5 января 2026 — понедельник: от него берутся короткие названия дней.
    String nameOf(int weekday) =>
        short.format(DateTime(2026, 1, 4 + weekday)).toLowerCase();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 2, VehaInsets.screen, 2),
            child: Text(
              L.of(context).weekSetupTitle,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 0, VehaInsets.screen, 14),
            child: Text(
              L.of(context).weekSetupHint,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final (label, days) in _presets(L.of(context)))
                  _Chip(
                    label: label,
                    selected: _layout.weekdays.length == days.length &&
                        _layout.weekdays.containsAll(days),
                    onTap: () => setState(() => _layout = WeekLayout(
                          weekdays: days,
                          firstDay: _layout.firstDay,
                        )),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 14, VehaInsets.screen, 4),
            child: Row(
              children: [
                for (var d = 1; d <= 7; d++) ...[
                  Expanded(
                    child: _DayToggle(
                      label: nameOf(d),
                      selected: _layout.weekdays.contains(d),
                      onTap: () => setState(() => _layout = _layout.toggle(d)),
                    ),
                  ),
                  if (d < 7) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 18, VehaInsets.screen, 4),
            child: Text(
              L.of(context).weekSetupStartsWith,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Wrap(
              spacing: 7,
              children: [
                for (final d in const [DateTime.monday, DateTime.saturday, DateTime.sunday])
                  _Chip(
                    label: nameOf(d),
                    selected: _layout.firstDay == d,
                    onTap: () =>
                        setState(() => _layout = _layout.withFirstDay(d)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 18, VehaInsets.screen, 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(L.of(context).actionCancel),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, _layout),
                  icon: Icon(VehaIcons.byName('check'), size: 18),
                  label: Text(L.of(context).actionDone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

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

class _DayToggle extends StatelessWidget {
  const _DayToggle({
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
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: selected ? scheme.primary : scheme.surfaceContainerHigh,
            shape: const CircleBorder(),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Куда положить событие: календарь и ветка внутри него.
///
/// Ветки показаны рядом с календарём, а не отдельным шагом: человек думает
/// «английский» и «учёба» одновременно, а не последовательно.
Future<({String calendarId, String? subcategoryId})?> askCalendar(
  BuildContext context, {
  required Inheritance inheritance,
  required String calendarId,
  String? subcategoryId,
}) {
  return showModalBottomSheet<({String calendarId, String? subcategoryId})>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _CalendarPickerSheet(
      inheritance: inheritance,
      calendarId: calendarId,
      subcategoryId: subcategoryId,
    ),
  );
}

class _CalendarPickerSheet extends StatelessWidget {
  const _CalendarPickerSheet({
    required this.inheritance,
    required this.calendarId,
    required this.subcategoryId,
  });

  final Inheritance inheritance;
  final String calendarId;
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final calendars = inheritance.calendars.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VehaInsets.screen, 2, VehaInsets.screen, 10),
              child: Text(
                'Календарь и ветка',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
                children: [
                  for (final calendar in calendars) ...[
                    _CalendarRow(
                      calendar: calendar,
                      selected: calendar.id == calendarId &&
                          subcategoryId == null,
                      onTap: () => Navigator.pop(
                        context,
                        (calendarId: calendar.id, subcategoryId: null),
                      ),
                    ),
                    for (final sub in inheritance.subcategories.values
                        .where((s) => s.calendarId == calendar.id))
                      _SubcategoryRow(
                        subcategory: sub,
                        color: inheritance.colorOfSubcategory(sub),
                        icon: sub.iconName ?? calendar.iconName,
                        selected: sub.id == subcategoryId,
                        onTap: () => Navigator.pop(
                          context,
                          (calendarId: calendar.id, subcategoryId: sub.id),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.calendar,
    required this.selected,
    required this.onTap,
  });

  final VCalendar calendar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(calendar.color, theme.brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: ShapeDecoration(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const CircleBorder(),
              ),
              child: Icon(VehaIcons.byName(calendar.iconName),
                  size: 17, color: ink.foreground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                calendar.name,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? scheme.onSecondaryContainer
                      : scheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(VehaIcons.byName('check'),
                  size: 18, color: scheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }
}

class _SubcategoryRow extends StatelessWidget {
  const _SubcategoryRow({
    required this.subcategory,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final VSubcategory subcategory;
  final Color color;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(color, theme.brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(left: 34, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: ShapeDecoration(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const CircleBorder(),
              ),
              child: Icon(VehaIcons.byName(icon), size: 13, color: ink.foreground),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                subcategory.name,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? scheme.onSecondaryContainer
                      : scheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(VehaIcons.byName('check'),
                  size: 16, color: scheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }
}

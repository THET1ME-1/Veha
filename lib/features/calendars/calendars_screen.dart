import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/seed.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

/// Календари и их ветки. Плашка справа говорит, откуда взят цвет:
/// наследуется от календаря или задан у ветки.
class CalendarsScreen extends StatefulWidget {
  const CalendarsScreen({super.key, required this.inheritance});

  final Inheritance inheritance;

  @override
  State<CalendarsScreen> createState() => _CalendarsScreenState();
}

class _CalendarsScreenState extends State<CalendarsScreen> {
  final Set<String> _hidden = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            'Календари',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 30,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        for (final c in Seed.calendars.take(4)) ...[
          _Group(
            calendar: c,
            subcategories:
                Seed.subcategories.where((s) => s.calendarId == c.id).toList(),
            inheritance: widget.inheritance,
            visible: !_hidden.contains(c.id),
            onToggle: (v) => setState(() {
              v ? _hidden.remove(c.id) : _hidden.add(c.id);
            }),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.calendar,
    required this.subcategories,
    required this.inheritance,
    required this.visible,
    required this.onToggle,
  });

  final VCalendar calendar;
  final List<VSubcategory> subcategories;
  final Inheritance inheritance;
  final bool visible;
  final ValueChanged<bool> onToggle;

  /// Сколько событий в календаре за видимый период. Число полезнее списка
  /// веток: оно отвечает, живой календарь или заброшенный.
  int get eventCount => Seed.byDay.values
      .expand((e) => e)
      .where((e) => e.calendarId == calendar.id)
      .length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(calendar.color, theme.brightness);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Column(
        children: [
          VRow(
            icon: calendar.iconName,
            iconBackground: ink.background,
            iconColor: ink.foreground,
            value: calendar.name,
            label: [
              subcategories.isEmpty
                  ? 'Без подкатегорий'
                  : '${subcategories.length} ${_plural(subcategories.length)}',
              '$eventCount ${_eventPlural(eventCount)}',
            ].join(' · '),
            labelFirst: false,
            trailing: VSwitch(value: visible, onChanged: onToggle),
          ),
          for (final s in subcategories)
            _SubRow(sub: s, inheritance: inheritance, brightness: theme.brightness),
          if (subcategories.isNotEmpty) const _AddSub(),
        ],
      ),
    );
  }

  static String _eventPlural(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'событие';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'события';
    }
    return 'событий';
  }

  static String _plural(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'подкатегория';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'подкатегории';
    }
    return 'подкатегорий';
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({
    required this.sub,
    required this.inheritance,
    required this.brightness,
  });

  final VSubcategory sub;
  final Inheritance inheritance;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final own = inheritance.subcategoryHasOwnColor(sub);
    final ink = EventColors.of(inheritance.colorOfSubcategory(sub), brightness);

    return Container(
      margin: const EdgeInsets.only(left: 22, right: 6, top: 3),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
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
            child: Icon(VehaIcons.byName(sub.iconName ?? 'calendar'),
                size: 14, color: ink.foreground),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              sub.name,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          own
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: ShapeDecoration(
                    color: ink.background,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'свой',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ink.foreground,
                    ),
                  ),
                )
              : const VTag('наследует', accent: false),
        ],
      ),
    );
  }
}

class _AddSub extends StatelessWidget {
  const _AddSub();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 22, right: 6, top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      child: Row(
        children: [
          Icon(VehaIcons.byName('add'), size: 15, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            'Добавить подкатегорию',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

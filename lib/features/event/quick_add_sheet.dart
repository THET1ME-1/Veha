import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../../domain/draft.dart';

/// Быстрое создание события: лист поверх дня.
///
/// Здесь ровно то, без чего событие не существует: название, время, календарь.
/// Остальное живёт в полной форме, куда ведёт «Подробнее» — черновик уезжает
/// туда целиком, набранное не теряется.
class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({
    super.key,
    required this.draft,
    required this.inheritance,
    required this.onSave,
    required this.onDetails,
  });

  final EventDraft draft;
  final Inheritance inheritance;
  final ValueChanged<EventDraft> onSave;
  final ValueChanged<EventDraft> onDetails;

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  late EventDraft _draft = widget.draft;
  late final TextEditingController _title =
      TextEditingController(text: _draft.title);

  static const _durations = <(String, Duration)>[
    ('30 мин', Duration(minutes: 30)),
    ('1 ч', Duration(hours: 1)),
    ('1,5 ч', Duration(minutes: 90)),
    ('2 ч', Duration(hours: 2)),
  ];

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draft.start),
    );
    if (picked == null) return;
    setState(() => _draft = _draft.withStart(DateTime(
          _draft.start.year,
          _draft.start.month,
          _draft.start.day,
          picked.hour,
          picked.minute,
        )));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.start,
      firstDate: DateTime(_draft.start.year - 2),
      lastDate: DateTime(_draft.start.year + 5),
    );
    if (picked == null) return;
    setState(() => _draft = _draft.withStart(DateTime(picked.year, picked.month,
        picked.day, _draft.start.hour, _draft.start.minute)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calendars = widget.inheritance.calendars.values.toList();

    return Container(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: ShapeDecoration(
                color: scheme.outlineVariant,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 8, VehaInsets.screen, 2),
            child: TextField(
              controller: _title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: scheme.onSurface,
              ),
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Название',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: scheme.outline,
                ),
              ),
              onChanged: (v) => setState(() => _draft = _draft.withTitle(v)),
              onSubmitted: (_) => _save(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 12, VehaInsets.screen, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _TimeChip(
                  text: DateFormat('EEE d MMMM', locale).format(_draft.start),
                  onTap: _pickDate,
                ),
                _TimeChip(
                  text: _hhmm(_draft.start),
                  accent: true,
                  onTap: _pickTime,
                ),
                Text('–',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    )),
                _TimeChip(text: _hhmm(_draft.end)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 12, VehaInsets.screen, 0),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final (label, value) in _durations)
                  _Choice(
                    label: label,
                    selected: _draft.duration == value,
                    onTap: () =>
                        setState(() => _draft = _draft.withDuration(value)),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 12, VehaInsets.screen, 0),
              itemCount: calendars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, i) {
                final c = calendars[i];
                return _CalendarChip(
                  calendar: c,
                  selected: c.id == _draft.calendarId,
                  onTap: () =>
                      setState(() => _draft = _draft.withCalendar(c.id)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 16, VehaInsets.screen, 22),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => widget.onDetails(_draft),
                  child: Text(
                    'Подробнее',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _draft.isReady ? _save : null,
                  icon: Icon(VehaIcons.byName('check'), size: 18),
                  label: const Text('Готово'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_draft.isReady) return;
    widget.onSave(_draft);
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.text, this.accent = false, this.onTap});

  final String text;
  final bool accent;
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
          color: accent
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: accent ? scheme.onSecondaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CalendarChip extends StatelessWidget {
  const _CalendarChip({
    required this.calendar,
    required this.selected,
    this.onTap,
  });

  final VCalendar calendar;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(calendar.color, theme.brightness);

    final background = selected ? ink.background : scheme.surfaceContainerHigh;
    final foreground = selected ? ink.foreground : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 8, 13, 8),
        decoration: ShapeDecoration(
          color: background,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: foreground.withValues(alpha: 0.16),
                shape: const CircleBorder(),
              ),
              child: Icon(VehaIcons.byName(calendar.iconName),
                  size: 13, color: foreground),
            ),
            const SizedBox(width: 7),
            Text(
              calendar.name,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

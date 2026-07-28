import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../l10n/app_localizations.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';
import '../event/look_sheet.dart';
import '../event/reminders_sheet.dart';

/// Что вернул редактор: имя с внешностью либо просьба удалить.
class CalendarDraft {
  const CalendarDraft({
    required this.name,
    required this.iconName,
    required this.color,
    this.deleted = false,
    this.defaultReminders,
    this.defaultDuration,
  });

  const CalendarDraft.deleted()
      : name = '',
        iconName = 'calendar',
        color = VehaBrand.seed,
        deleted = true,
        defaultReminders = null,
        defaultDuration = null;

  final String name;
  final String iconName;
  final Color color;
  final bool deleted;

  /// Напоминания новых событий, минуты до начала. `null` — не настраивали.
  final List<int>? defaultReminders;

  /// Длительность новых событий. Пусто — час.
  final Duration? defaultDuration;
}

/// Заведение и правка календаря или ветки. Одна форма на оба случая: разница
/// только в заголовке и в том, обязателен ли свой цвет.
Future<CalendarDraft?> askCalendarDraft(
  BuildContext context, {
  required String title,
  String name = '',
  String iconName = 'calendar',
  Color? color,
  required Color inheritedColor,
  bool canDelete = false,
  bool colorOptional = false,
  List<int>? defaultReminders,
  Duration? defaultDuration,
  bool withDefaults = false,
}) {
  return showModalBottomSheet<CalendarDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _CalendarEditorSheet(
        title: title,
        name: name,
        iconName: iconName,
        color: color,
        inheritedColor: inheritedColor,
        canDelete: canDelete,
        colorOptional: colorOptional,
        defaultReminders: defaultReminders,
        defaultDuration: defaultDuration,
        withDefaults: withDefaults,
      ),
    ),
  );
}

class _CalendarEditorSheet extends StatefulWidget {
  const _CalendarEditorSheet({
    required this.title,
    required this.name,
    required this.iconName,
    required this.color,
    required this.inheritedColor,
    required this.canDelete,
    required this.colorOptional,
    required this.defaultReminders,
    required this.defaultDuration,
    required this.withDefaults,
  });

  final String title;
  final String name;
  final String iconName;
  final Color? color;
  final Color inheritedColor;
  final bool canDelete;
  final bool colorOptional;
  final List<int>? defaultReminders;
  final Duration? defaultDuration;

  /// У ветки своих значений по умолчанию нет: они живут на календаре.
  final bool withDefaults;

  @override
  State<_CalendarEditorSheet> createState() => _CalendarEditorSheetState();
}

class _CalendarEditorSheetState extends State<_CalendarEditorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.name);
  late String _icon = widget.iconName;
  late Color? _color = widget.color;
  late List<int> _reminders = [...(widget.defaultReminders ?? const [30])];
  late Duration? _duration = widget.defaultDuration;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final color = _color ?? widget.inheritedColor;
    final ink = EventColors.of(color, theme.brightness);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 2, VehaInsets.screen, 12),
            child: Text(
              widget.title,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Row(
              children: [
                InkWell(
                  onTap: _pickLook,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: ink.background,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(VehaIcons.byName(_icon),
                        size: 24, color: ink.foreground),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _name,
                    autofocus: widget.name.isEmpty,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
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
                      hintText: l.fieldName,
                      hintStyle: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: scheme.outline,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          // Напоминание и длительность задаются на календаре, а событие их
          // наследует: «Учёба» предупреждает за день и идёт полтора часа,
          // «Распорядок» молчит. Повторять этот выбор в каждой записи глупо.
          if (widget.withDefaults)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VehaInsets.screen, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VBlockCap(l.calendarDefaults),
                  VBlock(children: [
                    VRow(
                      icon: 'bell',
                      label: l.calendarDefaultReminder,
                      value: remindersLabel(l, _reminders),
                      onTap: () async {
                        final chosen =
                            await askReminders(context, current: _reminders);
                        if (chosen == null) return;
                        setState(() => _reminders = chosen);
                      },
                      trailing: Icon(VehaIcons.byName('chevron'),
                          size: 17, color: scheme.outline),
                    ),
                    const VSep(),
                    VRow(
                      icon: 'clock',
                      label: l.calendarDefaultDuration,
                      value: _durationLabel(l),
                      onTap: _pickDuration,
                      trailing: Icon(VehaIcons.byName('chevron'),
                          size: 17, color: scheme.outline),
                    ),
                  ]),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 18, VehaInsets.screen, 14),
            child: Row(
              children: [
                if (widget.canDelete)
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, const CalendarDraft.deleted()),
                    icon: Icon(VehaIcons.byName('trash'), size: 18),
                    label: Text(l.actionDelete),
                    style:
                        TextButton.styleFrom(foregroundColor: scheme.error),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _name.text.trim().isEmpty
                      ? null
                      : () => Navigator.pop(
                            context,
                            CalendarDraft(
                              name: _name.text.trim(),
                              iconName: _icon,
                              color: _color ?? widget.inheritedColor,
                              defaultReminders: _reminders,
                              defaultDuration: _duration,
                            ),
                          ),
                  icon: Icon(VehaIcons.byName('check'), size: 18),
                  label: Text(l.actionDone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(L l) {
    final d = _duration ?? const Duration(hours: 1);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return l.durationMinutes(m);
    if (m == 0) return l.durationHours(h);
    return l.durationHoursMinutes(h, m);
  }

  Future<void> _pickDuration() async {
    final l = L.of(context);
    final chosen = await showModalBottomSheet<Duration>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in const [
              Duration(minutes: 15),
              Duration(minutes: 30),
              Duration(minutes: 45),
              Duration(hours: 1),
              Duration(minutes: 90),
              Duration(hours: 2),
              Duration(hours: 3),
            ])
              ListTile(
                leading: Icon(VehaIcons.byName('clock')),
                title: Text(d.inMinutes < 60
                    ? l.durationMinutes(d.inMinutes)
                    : d.inMinutes % 60 == 0
                        ? l.durationHours(d.inHours)
                        : l.durationHoursMinutes(
                            d.inHours, d.inMinutes % 60)),
                onTap: () => Navigator.pop(sheet, d),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    setState(() => _duration = chosen);
  }

  Future<void> _pickLook() async {
    final look = await askEventLook(
      context,
      current: EventLook(iconName: _icon, color: _color),
      inheritedColor: widget.inheritedColor,
      inheritedIcon: _icon,
    );
    if (look == null) return;
    setState(() {
      _icon = look.iconName ?? _icon;
      _color = look.color ?? (widget.colorOptional ? null : _color);
    });
  }
}

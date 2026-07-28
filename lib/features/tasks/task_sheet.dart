import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';
import '../event/calendar_picker_sheet.dart';
import '../event/look_sheet.dart';

/// Что вернул лист правки: сама задача или намерение её удалить.
class TaskOutcome {
  const TaskOutcome({required this.task, this.deleted = false});

  final VTask task;
  final bool deleted;
}

/// Лист заведения и правки задачи.
///
/// Формой на весь экран задача не заслуживает: у неё название, срок и место.
/// Событию форма нужна — там время, повторение и напоминания.
Future<TaskOutcome?> askTask(
  BuildContext context, {
  required VTask task,
  required Inheritance inheritance,
  bool canDelete = false,
}) {
  return showModalBottomSheet<TaskOutcome>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _TaskSheet(
      task: task,
      inheritance: inheritance,
      canDelete: canDelete,
    ),
  );
}

class _TaskSheet extends ConsumerStatefulWidget {
  const _TaskSheet({
    required this.task,
    required this.inheritance,
    required this.canDelete,
  });

  final VTask task;
  final Inheritance inheritance;
  final bool canDelete;

  @override
  ConsumerState<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<_TaskSheet> {
  late VTask _task = widget.task;
  late final TextEditingController _title =
      TextEditingController(text: _task.title);
  late final TextEditingController _notes =
      TextEditingController(text: _task.notes ?? '');

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = widget.inheritance.colorOfTask(_task);
    final ink = EventColors.of(color, theme.brightness);
    final icon = widget.inheritance.iconOfTask(_task);

    final calendar = widget.inheritance.calendars[_task.calendarId];
    final sub = _task.subcategoryId == null
        ? null
        : widget.inheritance.subcategories[_task.subcategoryId];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 0, VehaInsets.screen, 16),
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _pickLook(color, icon),
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: ink.background,
                        shape: const CircleBorder(),
                      ),
                      child: Icon(VehaIcons.byName(icon),
                          size: 22, color: ink.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.canDelete ? l.taskOne : l.taskNew,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _title.text.trim().isEmpty ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l.actionDone),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                autofocus: !widget.canDelete,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: scheme.onSurface,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: scheme.surfaceContainerHigh,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintText: l.taskTitleHint,
                ),
                onChanged: (v) => setState(() => _task = _task.copyWith(title: v)),
              ),
              const SizedBox(height: 12),
              VBlock(children: [
                VRow(
                  icon: 'clock',
                  label: l.taskDue,
                  value: _task.due == null
                      ? l.taskNoDue
                      : _dueLabel(l, locale, _task.due!, _task.hasTime,
                          ref.watch(nowProvider)),
                  onTap: _pickDue,
                  trailing: _task.due == null
                      ? Icon(VehaIcons.byName('chevron'),
                          size: 17, color: scheme.outline)
                      : IconButton(
                          onPressed: () => setState(
                            () => _task = _task.copyWith(
                                due: null, hasTime: false),
                          ),
                          icon: Icon(VehaIcons.byName('close'), size: 18),
                          color: scheme.onSurfaceVariant,
                        ),
                ),
                if (_task.due != null) ...[
                  const VSep(),
                  VRow(
                    icon: 'bell',
                    label: l.taskAtTime,
                    value: _task.hasTime
                        ? DateFormat.Hm(locale).format(_task.due!)
                        : l.no,
                    onTap: _pickTime,
                    trailing: VSwitch(
                      value: _task.hasTime,
                      onChanged: (v) => v
                          ? _pickTime()
                          : setState(
                              () => _task = _task.copyWith(hasTime: false)),
                    ),
                  ),
                ],
                const VSep(),
                VRow(
                  icon: 'calendar',
                  label: l.eventCalendarAndBranch,
                  value: sub == null
                      ? calendar?.name ?? ''
                      : '${calendar?.name} · ${sub.name}',
                  onTap: _pickCalendar,
                  trailing: Icon(VehaIcons.byName('chevron'),
                      size: 17, color: scheme.outline),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.surfaceContainerHigh,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintText: l.taskNotesHint,
                ),
              ),
              if (widget.canDelete) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.pop(
                    context,
                    TaskOutcome(task: _task, deleted: true),
                  ),
                  icon: Icon(VehaIcons.byName('trash'), size: 18),
                  label: Text(l.taskDelete),
                  style: TextButton.styleFrom(foregroundColor: scheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final notes = _notes.text.trim();
    Navigator.pop(
      context,
      TaskOutcome(
        task: _task.copyWith(
          title: _title.text.trim(),
          notes: notes.isEmpty ? null : notes,
        ),
      ),
    );
  }

  Future<void> _pickDue() async {
    final base = _task.due ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(base.year - 2),
      lastDate: DateTime(base.year + 5),
    );
    if (picked == null) return;
    setState(() => _task = _task.copyWith(
          due: DateTime(picked.year, picked.month, picked.day,
              _task.hasTime ? base.hour : 0, _task.hasTime ? base.minute : 0),
        ));
  }

  Future<void> _pickTime() async {
    final base = _task.due ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null) return;
    setState(() => _task = _task.copyWith(
          due: DateTime(
              base.year, base.month, base.day, picked.hour, picked.minute),
          hasTime: true,
        ));
  }

  Future<void> _pickCalendar() async {
    final chosen = await askCalendar(
      context,
      inheritance: widget.inheritance,
      calendarId: _task.calendarId,
      subcategoryId: _task.subcategoryId,
    );
    if (chosen == null) return;
    setState(() => _task = _task.copyWith(
          calendarId: chosen.calendarId,
          subcategoryId: chosen.subcategoryId,
        ));
  }

  Future<void> _pickLook(Color inheritedColor, String inheritedIcon) async {
    final look = await askEventLook(
      context,
      current: EventLook(iconName: _task.iconName, color: _task.color),
      inheritedColor: inheritedColor,
      inheritedIcon: inheritedIcon,
    );
    if (look == null) return;
    setState(() =>
        _task = _task.copyWith(iconName: look.iconName, color: look.color));
  }
}

/// Подпись срока: сегодня и завтра называются словом, остальное — датой.
/// «22 октября» на вопрос «когда» отвечает хуже, чем «завтра».
String _dueLabel(L l, String locale, DateTime due, bool hasTime, DateTime now) {
  final day = DateTime(due.year, due.month, due.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = day.difference(today).inDays;

  final label = switch (diff) {
    0 => l.dueToday,
    1 => l.dueTomorrow,
    _ => DateFormat('d MMMM', locale).format(due),
  };
  return hasTime ? '$label · ${DateFormat.Hm(locale).format(due)}' : label;
}

/// Та же подпись нужна списку задач.
String taskDueLabel(L l, String locale, VTask task, DateTime now) =>
    _dueLabel(l, locale, task.due!, task.hasTime, now);

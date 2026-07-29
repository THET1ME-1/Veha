import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../core/platform.dart';
import '../../data/models.dart';
import '../../domain/draft.dart';
import '../../domain/note_markup.dart';
import '../../domain/time_label.dart';
import '../../services/file_service.dart';
import '../calendar/views/chain_view.dart' show recurrenceLabelOf;
import '../repeat/repeat_screen.dart' show askRepeatRule;
import 'calendar_picker_sheet.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'field_value_sheet.dart';
import 'history_sheet.dart';
import 'note_body.dart';
import 'note_sheet.dart';
import 'event_cover.dart';
import 'place_sheet.dart';
import 'look_sheet.dart';
import 'reminders_sheet.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// Полная форма события: та же вёрстка, что у просмотра.
///
/// Читать и править — один макет, поэтому человек не переучивается: строки
/// стоят на тех же местах, меняется только то, что они теперь нажимаются.
class EventEditScreen extends ConsumerStatefulWidget {
  const EventEditScreen({
    super.key,
    required this.draft,
    required this.inheritance,
    required this.onSave,
    this.onDelete,
    this.onDuplicate,
  });

  final EventDraft draft;
  final Inheritance inheritance;
  final ValueChanged<EventDraft> onSave;
  final VoidCallback? onDelete;

  /// Копия события: та же карточка с новым ключом, сразу в форме.
  final VoidCallback? onDuplicate;

  @override
  ConsumerState<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends ConsumerState<EventEditScreen> {
  late EventDraft _draft = widget.draft;
  late final TextEditingController _title = TextEditingController(
    text: _draft.title,
  );

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.start,
      firstDate: DateTime(_draft.start.year - 2),
      lastDate: DateTime(_draft.start.year + 5),
    );
    if (picked == null) return;
    setState(
      () => _draft = _draft.withStart(
        DateTime(
          picked.year,
          picked.month,
          picked.day,
          _draft.start.hour,
          _draft.start.minute,
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final base = isStart ? _draft.start : _draft.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null) return;

    final moment = DateTime(
      base.year,
      base.month,
      base.day,
      picked.hour,
      picked.minute,
    );
    setState(
      () =>
          _draft = isStart ? _draft.withStart(moment) : _draft.withEnd(moment),
    );
  }

  /// Сколько добираться до места. Полчаса пути — это занятые полчаса, и
  /// календарь обязан их видеть: иначе он предложит окно, из которого
  /// невозможно успеть.
  Future<void> _pickTravel() async {
    final l = L.of(context);
    final chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in const [0, 10, 15, 30, 45, 60, 90])
              ListTile(
                leading: Icon(VehaIcons.byName(
                    minutes == 0 ? 'close' : 'directions_walk')),
                title: Text(
                  minutes == 0
                      ? l.travelNone
                      : humanDuration(l, Duration(minutes: minutes)),
                ),
                selected: minutes == _draft.travelMinutes,
                onTap: () => Navigator.pop(sheetContext, minutes),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    setState(() => _draft = _draft.withTravel(chosen));
  }

  /// Снять окончание и вернуть его обратно.
  void _toggleOpenEnd() =>
      setState(() => _draft = _draft.withOpenEnd(!_draft.isOpenEnded));

  Future<void> _pickRepeat() async {
    final rrule = await askRepeatRule(
      context,
      from: _draft.start,
      initial: _draft.rrule,
    );
    if (!mounted) return;
    setState(() => _draft = _draft.withRrule(rrule));
  }

  /// Поля календаря, к которому приписано событие. Список ведёт экран полей,
  /// здесь его только заполняют.
  ///
  /// Встроенные (общие) записи сюда не идут: «Повтор» и «Место» — свойства
  /// самого события, у них свои строки выше, и второй раз спрашивать их
  /// значит предлагать две разные правды об одном.
  List<VFieldDef> get _defs {
    final all = ref.watch(fieldDefsProvider).valueOrNull ?? const <VFieldDef>[];
    return [
      for (final f in all)
        if (f.calendarId == _draft.calendarId) f,
    ];
  }

  Widget _fieldRow(VFieldDef def, ColorScheme scheme) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final value = _draft.fieldValue(def.id);
    return VRow(
      icon: def.iconName,
      label: def.name,
      value: value == null
          ? l.actionAdd
          : showFieldValue(l, def, value, locale),
      onTap: () => _pickField(def),
      trailing: def.type == VFieldType.checkbox
          ? VSwitch(
              value: isFieldChecked(value),
              onChanged: (_) => _pickField(def),
            )
          : Icon(VehaIcons.byName('chevron'), size: 17, color: scheme.outline),
    );
  }

  Future<void> _pickField(VFieldDef def) async {
    final value = await askFieldValue(
      context,
      def: def,
      current: _draft.fieldValue(def.id),
    );
    if (value == null) return;
    setState(() => _draft = _draft.withField(def.id, value));
  }

  /// Заметки внутри события. Пишутся сразу в базу, не дожидаясь «Сохранить»:
  /// событие уже существует, а записка — самостоятельная мысль.
  Widget _notes(Color eventColor) {
    final eventId = _draft.source!.recurrenceId ?? _draft.source!.id;
    final notes = ref.watch(notesProvider(eventId)).valueOrNull ?? const <VNote>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VBlockCap(L.of(context).notesTitle),
        VBlock(children: [
          for (var i = 0; i < notes.length; i++) ...[
            if (i > 0) const VSep(),
            _NoteRow(
              note: notes[i],
              eventColor: eventColor,
              onTap: () => _editNote(notes[i], eventColor),
              onToggle: (line) => _toggleNoteLine(notes[i], line),
              onLink: _openLink,
            ),
          ],
          if (notes.isNotEmpty) const VSep(),
          VRow(
            icon: 'add',
            value: L.of(context).noteAdd,
            onTap: () => _addNote(eventId, eventColor, notes.length),
          ),
        ]),
      ],
    );
  }

  /// Вложения события. Живут только на устройстве: сервер хранит записи и
  /// отдаёт дельты, файлового хранилища у него нет.
  Widget _files() {
    final l = L.of(context);
    final scheme = Theme.of(context).colorScheme;
    final eventId = _draft.source!.recurrenceId ?? _draft.source!.id;
    final files =
        ref.watch(filesProvider(eventId)).valueOrNull ?? const <VFile>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VBlockCap(l.filesTitle),
        VBlock(children: [
          for (var i = 0; i < files.length; i++) ...[
            if (i > 0) const VSep(),
            VRow(
              icon: fileIconOf(files[i].name),
              label: fileSizeLabel(l, files[i].size),
              value: files[i].name,
              labelFirst: false,
              onTap: () => _openFile(files[i]),
              trailing: IconButton(
                onPressed: () => _removeFile(files[i]),
                icon: Icon(VehaIcons.byName('close'), size: 18),
                tooltip: l.fileRemove,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (files.isNotEmpty) const VSep(),
          VRow(
            icon: 'attach_file',
            value: l.fileAttach,
            onTap: () => _attachFile(eventId),
          ),
        ]),
      ],
    );
  }

  Future<void> _attachFile(String eventId) async {
    final repo = ref.read(repositoryProvider);
    final id = repo.newId();
    final picked = await FileService.pick(id: id);
    if (picked == null) return;

    await repo.addFile(VFile(
      id: id,
      eventId: eventId,
      path: picked.path,
      name: picked.name,
      size: picked.size,
      addedAt: DateTime.now(),
    ));
  }

  Future<void> _openFile(VFile file) async {
    final l = L.of(context);
    final path = await attachmentPath(file.path);
    if (!await File(path).exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l.fileMissing)));
      }
      return;
    }
    await launchUrl(Uri.file(path), mode: LaunchMode.externalApplication);
  }

  Future<void> _removeFile(VFile file) async {
    final path = await ref.read(repositoryProvider).deleteFile(file.id);
    if (path != null) await FileService.erase(path);
  }

  /// История правок. Строка, а не блок: заходят сюда редко, а места она
  /// заняла бы столько же, сколько заметки.
  Widget _history() {
    final l = L.of(context);
    final scheme = Theme.of(context).colorScheme;
    final eventId = _draft.source!.recurrenceId ?? _draft.source!.id;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: VBlock(children: [
        VRow(
          icon: 'history',
          value: l.historyTitle,
          onTap: () async {
            final history =
                await ref.read(historyProvider(eventId).future);
            if (!mounted) return;
            await showEventHistory(context, history: history);
          },
          trailing: Icon(
            VehaIcons.byName('chevron'),
            size: 17,
            color: scheme.outline,
          ),
        ),
      ]),
    );
  }

  Future<void> _addNote(String eventId, Color eventColor, int count) async {
    final draft = await askNote(context, inheritedColor: eventColor);
    if (draft == null || draft.deleted) return;

    final repo = ref.read(repositoryProvider);
    await repo.upsertNote(VNote(
      id: repo.newId(),
      eventId: eventId,
      text: draft.text,
      color: draft.color,
      sortOrder: count,
    ));
  }

  /// Пункт отмечен сделанным. Пишется сразу в базу: заметка живёт своей
  /// жизнью и «Сохранить» у формы её не ждёт.
  Future<void> _toggleNoteLine(VNote note, int line) async {
    final next = toggleNoteCheck(note.text, line);
    if (next == note.text) return;
    await ref.read(repositoryProvider).upsertNote(
          VNote(
            id: note.id,
            eventId: note.eventId,
            text: next,
            color: note.color,
            sortOrder: note.sortOrder,
          ),
        );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _editNote(VNote note, Color eventColor) async {
    final draft = await askNote(
      context,
      text: note.text,
      color: note.color,
      inheritedColor: eventColor,
      canDelete: true,
    );
    if (draft == null) return;

    final repo = ref.read(repositoryProvider);
    if (draft.deleted) {
      await repo.deleteNote(note.id);
    } else {
      await repo.upsertNote(VNote(
        id: note.id,
        eventId: note.eventId,
        text: draft.text,
        color: draft.color,
        sortOrder: note.sortOrder,
      ));
    }
  }

  Future<void> _pickReminders() async {
    final chosen = await askReminders(context, current: _draft.reminders);
    if (chosen == null) return;
    setState(() => _draft = _draft.withReminders(chosen));
  }

  Future<void> _pickCalendar() async {
    final chosen = await askCalendar(
      context,
      inheritance: widget.inheritance,
      calendarId: _draft.calendarId,
      subcategoryId: _draft.subcategoryId,
    );
    if (chosen == null) return;
    setState(() => _draft = _draft
        .withCalendar(chosen.calendarId)
        .withSubcategory(chosen.subcategoryId));
  }

  Future<void> _pickLook(Color inheritedColor, String inheritedIcon) async {
    final look = await askEventLook(
      context,
      current: EventLook(iconName: _draft.iconName, color: _draft.color),
      inheritedColor: inheritedColor,
      inheritedIcon: inheritedIcon,
    );
    if (look == null) return;
    setState(() =>
        _draft = _draft.withIcon(look.iconName).withColor(look.color));
  }

  Future<void> _pickLocation() async {
    final value = await askPlace(context, current: _draft.location);
    if (value == null) return;
    setState(() => _draft = _draft.withLocation(
          value.trim().isEmpty ? null : value.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final calendar = widget.inheritance.calendars[_draft.calendarId];
    final sub = _draft.subcategoryId == null
        ? null
        : widget.inheritance.subcategories[_draft.subcategoryId];
    final color =
        _draft.color ?? sub?.color ?? calendar?.color ?? VehaBrand.seed;
    final ink = EventColors.of(color, theme.brightness);
    final icon =
        _draft.iconName ?? sub?.iconName ?? calendar?.iconName ?? 'calendar';

    final l = L.of(context);
    final repeat = _draft.rrule == null
        ? l.repeatNone
        : recurrenceLabelOf(l, _draft.toEvent(newId: () => 'preview')) ??
              l.repeatByRule;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _FormBar(
              title: _draft.isEditing ? l.eventOne : l.newEvent,
              onSave: _draft.isReady ? () => widget.onSave(_draft) : null,
            ),
            Expanded(
              child: _form(
                context,
                l,
                scheme,
                ink,
                color,
                icon,
                locale,
                calendar,
                sub,
                repeat,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(
    BuildContext context,
    L l,
    ColorScheme scheme,
    EventInk ink,
    Color color,
    String icon,
    String locale,
    VCalendar? calendar,
    VSubcategory? sub,
    String repeat,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        VehaInsets.screen,
        6,
        VehaInsets.screen,
        40,
      ),
      children: [
        _CoverCard(
          ink: ink,
          // Обложка живёт у сохранённого события: у нового ещё нет ключа,
          // к которому её привязать.
          eventId: _draft.isEditing
              ? (_draft.source!.recurrenceId ?? _draft.source!.id)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _pickLook(color, icon),
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: ink.foreground.withValues(alpha: 0.15),
                        shape: const CircleBorder(),
                      ),
                      child: Icon(
                        VehaIcons.byName(icon),
                        size: 23,
                        color: ink.foreground,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_draft.isEditing) ...[
                    CoverButton(
                      eventId:
                          _draft.source!.recurrenceId ?? _draft.source!.id,
                      ink: ink,
                      size: 36,
                    ),
                    const SizedBox(width: 8),
                  ],
                  InkWell(
                    onTap: () => _pickLook(color, icon),
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: ShapeDecoration(
                        color: ink.foreground.withValues(alpha: 0.14),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        L.of(context).lookTitle,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ink.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: ink.foreground,
                ),
                cursorColor: ink.foreground,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: L.of(context).fieldName,
                  hintStyle: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: ink.foreground.withValues(alpha: 0.45),
                  ),
                ),
                onChanged: (v) => setState(() => _draft = _draft.withTitle(v)),
              ),
              const SizedBox(height: 7),
              Text(
                '${DateFormat('EEE d MMMM', locale).format(_draft.start)} · '
                '${_draft.isOpenEnded ? l.timeFrom(_hhmm(_draft.start)) : '${_hhmm(_draft.start)} – ${_hhmm(_draft.end)}'}',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: ink.foreground.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        VBlock(
          children: [
            VRow(
              icon: 'clock',
              label: l.eventWhen,
              value: DateFormat('EEEE, d MMMM', locale).format(_draft.start),
              onTap: _pickDate,
              trailing: Icon(
                VehaIcons.byName('chevron'),
                size: 17,
                color: scheme.outline,
              ),
            ),
            const VSep(),
            _TimeRow(
              start: _hhmm(_draft.start),
              end: _hhmm(_draft.end),
              openEnded: _draft.isOpenEnded,
              onStart: () => _pickTime(isStart: true),
              onEnd: () => _pickTime(isStart: false),
            ),
            const VSep(),
            // «Зашёл в мастерскую», «сел писать»: начало известно, конец нет.
            // Час по умолчанию врал бы о занятости вечера.
            VRow(
              // Не часы: строкой выше уже двое часов подряд, и третьи
              // сливаются с ними в одну кашу.
              icon: 'hourglass_disabled',
              value: l.eventOpenEnd,
              onTap: _toggleOpenEnd,
              trailing: VSwitch(
                value: _draft.isOpenEnded,
                onChanged: (_) => _toggleOpenEnd(),
              ),
            ),
            const VSep(),
            VRow(
              icon: 'repeat',
              label: l.eventRepeat,
              value: repeat,
              onTap: _pickRepeat,
              trailing: Icon(
                VehaIcons.byName('chevron'),
                size: 17,
                color: scheme.outline,
              ),
            ),
            const VSep(),
            VRow(
              icon: 'calendar',
              label: l.eventCalendarAndBranch,
              value: sub == null
                  ? calendar?.name ?? ''
                  : '${calendar?.name} · ${sub.name}',
              onTap: _pickCalendar,
              trailing: Icon(
                VehaIcons.byName('chevron'),
                size: 17,
                color: scheme.outline,
              ),
            ),
            const VSep(),
            VRow(
              icon: 'bell',
              label: l.eventReminder,
              value: remindersLabel(l, _draft.reminders),
              onTap: _pickReminders,
              trailing: Icon(
                VehaIcons.byName('chevron'),
                size: 17,
                color: scheme.outline,
              ),
            ),
            const VSep(),
            VRow(
              icon: 'place',
              label: l.eventPlace,
              value: _draft.location ?? l.actionAdd,
              onTap: _pickLocation,
              trailing: Icon(
                VehaIcons.byName('chevron'),
                size: 17,
                color: scheme.outline,
              ),
            ),
            // Дорога стоит под местом: без адреса она бессмысленна, а рядом
            // с ним читается как продолжение той же мысли.
            const VSep(),
            VRow(
              icon: 'directions_walk',
              label: l.eventTravel,
              value: _draft.travelMinutes <= 0
                  ? l.travelNone
                  : '${humanDuration(l, Duration(minutes: _draft.travelMinutes))} · '
                      '${l.travelLeaveAt(_hhmm(_draft.start.subtract(Duration(minutes: _draft.travelMinutes))))}',
              onTap: _pickTravel,
              trailing: Icon(
                VehaIcons.byName('chevron'),
                size: 17,
                color: scheme.outline,
              ),
            ),
          ],
        ),
        if (_defs.isNotEmpty) ...[
          VBlockCap(L.of(context).fieldsTitle),
          VBlock(children: [
            for (var i = 0; i < _defs.length; i++) ...[
              if (i > 0) const VSep(),
              _fieldRow(_defs[i], scheme),
            ],
          ]),
        ],
        // Заметки и снимки принадлежат сохранённому событию: у нового ещё нет
        // ключа, к которому их привязать, и держать их в черновике значит
        // заводить вторую правду о том же.
        if (_draft.isEditing) _notes(color),
        // Вложения — только там, где есть файловая система: в браузере
        // приложенный документ некуда положить и нечем открыть.
        if (_draft.isEditing && hasFiles) _files(),
        if (_draft.isEditing) _history(),
        if (widget.onDuplicate != null || widget.onDelete != null) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              if (widget.onDuplicate != null)
                TextButton.icon(
                  onPressed: widget.onDuplicate,
                  icon: Icon(VehaIcons.byName('content_copy'), size: 18),
                  label: Text(l.eventDuplicate),
                ),
              const Spacer(),
              if (widget.onDelete != null)
                TextButton.icon(
                  onPressed: widget.onDelete,
                  icon: Icon(VehaIcons.byName('trash'), size: 18),
                  label: Text(l.eventDelete),
                  style: TextButton.styleFrom(foregroundColor: scheme.error),
                ),
            ],
          ),
        ],
      ],
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Шапка формы: круглая кнопка назад, название, кнопка сохранения пилюлей.
/// Стоковый AppBar здесь не годится — он растягивает кнопку на всю высоту
/// и обрезает заголовок.
class _FormBar extends StatelessWidget {
  const _FormBar({required this.title, this.onSave});

  final String title;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 6),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: scheme.surfaceContainerHigh,
                shape: const CircleBorder(),
              ),
              child: Icon(
                VehaIcons.byName('back'),
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(L.of(context).actionSave),
          ),
        ],
      ),
    );
  }
}

/// Начало и конец — два самостоятельных чипа: попасть пальцем в нужный конец
/// проще, чем в одну строку с двумя ролями.
class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.start,
    required this.end,
    required this.onStart,
    required this.onEnd,
    this.openEnded = false,
  });

  final String start;
  final String end;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  /// Событие без окончания: второй чип и тире между ними убираются —
  /// показывать там нечего.
  final bool openEnded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
            ),
            child: Icon(
              VehaIcons.byName('clock'),
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 13),
          Text(
            L.of(context).eventTime,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          _Stamp(text: start, onTap: onStart),
          if (!openEnded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                '–',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            _Stamp(text: end, onTap: onEnd),
          ],
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: ShapeDecoration(
          color: scheme.secondaryContainer,
          shape: const StadiumBorder(),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: scheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

/// Строка заметки: заливка цветом заметки, текст в тон.
class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.note,
    required this.eventColor,
    required this.onTap,
    required this.onToggle,
    required this.onLink,
  });

  final VNote note;
  final Color eventColor;
  final VoidCallback onTap;

  /// Галочку отмечают прямо в карточке: открывать правку ради вычеркнутого
  /// пункта значит превращать список покупок в анкету.
  final ValueChanged<int> onToggle;
  final ValueChanged<String> onLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = EventColors.of(note.color ?? eventColor, theme.brightness);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: ShapeDecoration(
            color: ink.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: NoteBody(
                  text: note.text,
                  ink: note.color ?? eventColor,
                  onToggle: onToggle,
                  onLink: onLink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Шапка формы со снимком на фоне.
///
/// Тот же приём, что и в просмотре: фотография заливается ровным слоем цвета
/// события, иначе белые буквы теряются на светлом небе. Градиентов в
/// приложении нет.
class _CoverCard extends ConsumerWidget {
  const _CoverCard({required this.ink, required this.eventId, required this.child});

  final EventInk ink;
  final String? eventId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = eventId == null ? null : ref.watch(coverProvider(eventId!));

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          if (cover != null)
            Positioned.fill(child: Image(image: cover, fit: BoxFit.cover)),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            color: cover == null
                ? ink.background
                : ink.background.withValues(alpha: coverScrim),
            child: child,
          ),
        ],
      ),
    );
  }
}

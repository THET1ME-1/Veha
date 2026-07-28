import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/draft.dart';
import '../calendar/views/chain_view.dart' show recurrenceLabelOf;
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/ics.dart';
import 'calendar_picker_sheet.dart';
import 'edit_scope_sheet.dart';
import 'event_edit_screen.dart';
import 'event_preview_sheet.dart';
import 'look_sheet.dart';
import 'quick_add_sheet.dart';
import 'reminders_sheet.dart';

/// Путь события от кнопки до базы.
///
/// Экран календаря знает про «завести событие здесь», а не про то, какой лист
/// за каким открывается и что делать с рядом: это всё живёт тут.
class EventFlow {
  const EventFlow(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  /// Быстрый лист. [at] — час, по которому ткнули; без него берётся ближайший
  /// круглый час впереди.
  Future<void> create({DateTime? at}) async {
    final inheritance = ref.read(inheritanceProvider).valueOrNull;
    if (inheritance == null || inheritance.calendars.isEmpty) return;

    final calendarId = inheritance.calendars.keys.first;
    final draft = at == null
        ? EventDraft.blank(now: ref.read(nowProvider), calendarId: calendarId)
        : EventDraft.at(at, calendarId: calendarId);

    await _openQuickSheet(draft, inheritance);
  }

  /// Правка существующего события — сразу полная форма: у него уже есть и
  /// повтор, и поля, и прятать их за «Подробнее» незачем.
  Future<void> edit(VEvent event) async {
    final inheritance = ref.read(inheritanceProvider).valueOrNull;
    if (inheritance == null) return;
    await _openFullForm(EventDraft.of(event), inheritance);
  }

  /// Превью: подробности и действия. Тап по блоку открывает его, а не форму —
  /// смотреть место или напоминание человек ходит чаще, чем править.
  Future<void> preview(VEvent event) async {
    final inheritance = ref.read(inheritanceProvider).valueOrNull;
    if (inheritance == null) return;

    final choice = await showEventPreview(
      context,
      event: event,
      inheritance: inheritance,
    );
    if (choice == null || !context.mounted) return;

    switch (choice.action) {
      case PreviewAction.edit:
        await edit(event);
      case PreviewAction.duplicate:
        await duplicate(event);
      case PreviewAction.moveTomorrow:
        await _move(event, const Duration(days: 1));
      case PreviewAction.moveNextWeek:
        await _move(event, const Duration(days: 7));
      case PreviewAction.movePickDate:
        await _moveToPickedDate(event);
      case PreviewAction.changeCalendar:
        await _changeCalendar(event, inheritance);
      case PreviewAction.changeLook:
        await _changeLook(event, inheritance);
      case PreviewAction.reminders:
        await _changeReminders(event);
      case PreviewAction.copyText:
        await _copyText(event, inheritance);
      case PreviewAction.exportIcs:
        await _exportOne(event);
      case PreviewAction.openMap:
        await _openMap(event);
      case PreviewAction.delete:
        await _delete(EventDraft.of(event));
      case PreviewAction.pauseSeries:
        await _pauseSeries(event, choice.weeks);
      case PreviewAction.resetLook:
        await _resetLook(event);
      case PreviewAction.toTask:
        await _toTask(event, inheritance);
      case PreviewAction.shiftRest:
        await _shiftRestOfDay(event);
      case PreviewAction.repeatDay:
        await _repeatDay(event);
      case PreviewAction.stretchToNext:
        await _stretchToNext(event);
    }
  }

  /// Блок перетащили в сетке. Событие едет молча, полоска предлагает
  /// вернуть — и заодно докладывает, если оно наехало на соседа.
  Future<void> moveBy(VEvent event, Duration shift) async {
    if (shift.inMinutes == 0) return;
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final moved = _shifted(event, shift);
    await repo.upsertEvent(moved);

    final clash = await _clashWith(moved);
    if (!context.mounted) return;

    _offerUndo(
      clash == null
          ? l.msgEventShifted(DateFormat.Hm(locale).format(moved.start))
          : l.msgOverlaps(clash.title),
      () => repo.upsertEvent(event),
    );
  }

  /// Блок потянули за нижний край: другая длительность, то же начало.
  Future<void> resize(VEvent event, Duration duration) async {
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final resized = _withEnd(event, event.start.add(duration));
    await repo.upsertEvent(resized);

    if (!context.mounted) return;
    _offerUndo(
      l.msgEventResized(DateFormat.Hm(locale).format(resized.end)),
      () => repo.upsertEvent(event),
    );
  }

  /// С кем событие пересеклось после переноса. Молча наехать на соседа
  /// календарь не должен — но и запрещать не его дело.
  Future<VEvent?> _clashWith(VEvent event) async {
    final day = await ref.read(repositoryProvider).eventsOfDay(event.start);
    for (final other in day) {
      if (other.id == event.id || other.isMultiDay) continue;
      if (other.start.isBefore(event.end) && other.end.isAfter(event.start)) {
        return other;
      }
    }
    return null;
  }

  VEvent _withEnd(VEvent event, DateTime end) => VEvent(
        id: event.id,
        calendarId: event.calendarId,
        subcategoryId: event.subcategoryId,
        title: event.title,
        start: event.start,
        end: end,
        color: event.color,
        iconName: event.iconName,
        isAllDay: event.isAllDay,
        rrule: event.isOccurrence ? null : event.rrule,
        recurrenceId: event.recurrenceId,
        originalStart: event.originalStart,
        isVirtual: event.isVirtual,
        timezone: event.timezone,
        location: event.location,
        fields: event.fields,
        reminders: event.reminders,
      );

  // ── Действия, каких нет у соседей ──────────────────────────────────────

  /// Пауза ряда: занятий не будет столько-то недель, ряд остаётся.
  ///
  /// Каникулы и отпуск раньше приходилось разбирать вручную — отменять по
  /// одному занятию. Ряд при этом должен жить: после паузы он продолжается
  /// сам.
  Future<void> _pauseSeries(VEvent event, int weeks) async {
    final series = event.recurrenceId;
    if (series == null || weeks <= 0) return;

    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final from = event.originalStart ?? event.start;
    final skipped = await repo.pauseSeries(
      series,
      DateTime(from.year, from.month, from.day),
      from.add(Duration(days: 7 * weeks)),
    );

    _offerUndo(
      l.msgSeriesPaused(skipped.length),
      () => repo.resumeSeries(series, skipped),
    );
  }

  /// Вернуть цвет и иконку ветке: событие снова наследует их по цепочке.
  Future<void> _resetLook(VEvent event) async {
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);

    await _save(EventDraft.of(event).withIcon(null).withColor(null));
    if (!context.mounted) return;
    _offerUndo(l.msgLookReset, () => repo.upsertEvent(event));
  }

  /// Событие оказалось делом, а не встречей.
  ///
  /// Отметки выполнения у события нет и не будет — она есть у задачи. Перенос
  /// сохраняет календарь, ветку, название и время: задача получает срок.
  Future<void> _toTask(VEvent event, Inheritance inheritance) async {
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);

    await repo.upsertTask(VTask(
      id: repo.newId(),
      calendarId: event.calendarId,
      subcategoryId: event.subcategoryId,
      title: event.title,
      notes: event.location,
      due: event.start,
      hasTime: !event.isAllDay,
      color: event.color,
      iconName: event.iconName,
    ));
    await repo.deleteEvent(event.recurrenceId ?? event.id);

    if (!context.mounted) return;
    _offerUndo(l.msgBecameTask, () => repo.upsertEvent(event));
  }

  /// Сдвинуть остаток дня следом за событием.
  ///
  /// День — цепочка: занятие уехало на полчаса, за ним едет всё, что дальше.
  /// Разбирать это по одному событию человек не должен.
  Future<void> _shiftRestOfDay(VEvent event) async {
    final l = L.of(context);
    final minutes = await _askMinutes();
    if (minutes == null || !context.mounted) return;

    final repo = ref.read(repositoryProvider);
    final day = await repo.eventsOfDay(event.start);
    final tail = [
      for (final e in day)
        if (!e.isMultiDay && !e.start.isBefore(event.start)) e,
    ];
    if (tail.isEmpty) {
      _say(l.nothingToShift);
      return;
    }

    final shift = Duration(minutes: minutes);
    for (final e in tail) {
      await repo.upsertEvent(_shifted(e, shift));
    }

    _offerUndo(l.msgDayShifted(tail.length), () async {
      for (final e in tail) {
        await repo.upsertEvent(e);
      }
    });
  }

  /// На сколько сдвигать. Полчаса и час покрывают почти всё: расписание
  /// уезжает круглыми кусками, а не на семнадцать минут.
  Future<int?> _askMinutes() {
    final l = L.of(context);
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in const [15, 30, 60, -15, -30, -60])
              ListTile(
                leading: Icon(VehaIcons.byName(m > 0 ? 'expand' : 'wand')),
                title: Text(m > 0
                    ? '+ ${l.reminderMinutes(m)}'
                    : '− ${l.reminderMinutes(-m)}'),
                onTap: () => Navigator.pop(sheet, m),
              ),
          ],
        ),
      ),
    );
  }

  /// Повторить день: весь набор событий переезжает копией на другую дату.
  ///
  /// Расписание повторяется днями, а не по одному занятию: «сделай завтра
  /// так же» — обычная просьба к календарю.
  Future<void> _repeatDay(VEvent event) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: event.start.add(const Duration(days: 1)),
      firstDate: DateTime(event.start.year - 1),
      lastDate: DateTime(event.start.year + 5),
    );
    if (picked == null || !context.mounted) return;

    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final source = DateTime(event.start.year, event.start.month, event.start.day);
    final target = DateTime(picked.year, picked.month, picked.day);
    final shift = target.difference(source);

    final day = await repo.eventsOfDay(event.start);
    final copies = <VEvent>[];
    for (final e in day) {
      if (e.isMultiDay) continue;
      final copy = VEvent(
        id: repo.newId(),
        calendarId: e.calendarId,
        subcategoryId: e.subcategoryId,
        title: e.title,
        start: e.start.add(shift),
        end: e.end.add(shift),
        color: e.color,
        iconName: e.iconName,
        isAllDay: e.isAllDay,
        location: e.location,
        fields: e.fields,
        reminders: e.reminders,
        timezone: e.timezone,
      );
      copies.add(copy);
      await repo.upsertEvent(copy);
    }

    if (!context.mounted) return;
    _offerUndo(
      l.msgDayCopied(DateFormat('d MMMM', locale).format(target), copies.length),
      () async {
        for (final c in copies) {
          await repo.deleteEvent(c.id);
        }
      },
    );
  }

  /// Занять промежуток до ближайшего события. Если дальше пусто — до конца
  /// дня: обед «до вечера» бывает и таким.
  Future<void> _stretchToNext(VEvent event) async {
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final day = await repo.eventsOfDay(event.start);
    final next = [
      for (final e in day)
        if (!e.isMultiDay && e.start.isAfter(event.start)) e,
    ]..sort((a, b) => a.start.compareTo(b.start));

    final until = next.isEmpty
        ? DateTime(event.start.year, event.start.month, event.start.day, 23, 59)
        : next.first.start;
    if (!until.isAfter(event.end)) {
      _say(l.nothingToShift);
      return;
    }

    final stretched = VEvent(
      id: event.id,
      calendarId: event.calendarId,
      subcategoryId: event.subcategoryId,
      title: event.title,
      start: event.start,
      end: until,
      color: event.color,
      iconName: event.iconName,
      isAllDay: event.isAllDay,
      rrule: event.isOccurrence ? null : event.rrule,
      recurrenceId: event.recurrenceId,
      originalStart: event.originalStart,
      isVirtual: event.isVirtual,
      timezone: event.timezone,
      location: event.location,
      fields: event.fields,
      reminders: event.reminders,
    );
    await repo.upsertEvent(stretched);

    if (!context.mounted) return;
    _offerUndo(
      l.msgStretched(DateFormat.Hm(locale).format(until)),
      () => repo.upsertEvent(event),
    );
  }

  /// Перенос на столько-то суток вперёд. Время суток сохраняется: «на завтра»
  /// означает тот же час, а не полночь.
  Future<void> _move(VEvent event, Duration shift) async {
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final moved = _shifted(event, shift);
    await repo.upsertEvent(moved);
    _offerUndo(
      l.msgEventMoved(DateFormat('d MMMM', locale).format(moved.start)),
      () => repo.upsertEvent(event),
    );
  }

  Future<void> _moveToPickedDate(VEvent event) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: event.start,
      firstDate: DateTime(event.start.year - 2),
      lastDate: DateTime(event.start.year + 5),
    );
    if (picked == null || !context.mounted) return;

    final day = DateTime(picked.year, picked.month, picked.day);
    final from = DateTime(event.start.year, event.start.month, event.start.day);
    await _move(event, day.difference(from));
  }

  /// Тот же event, сдвинутый по времени. Экземпляр ряда при переносе
  /// выламывается из него отдельной записью — так же, как при правке.
  VEvent _shifted(VEvent event, Duration shift) => VEvent(
        id: event.id,
        calendarId: event.calendarId,
        subcategoryId: event.subcategoryId,
        title: event.title,
        start: event.start.add(shift),
        end: event.end.add(shift),
        color: event.color,
        iconName: event.iconName,
        isAllDay: event.isAllDay,
        rrule: event.isOccurrence ? null : event.rrule,
        recurrenceId: event.recurrenceId,
        originalStart: event.originalStart,
        isVirtual: event.isVirtual,
        timezone: event.timezone,
        location: event.location,
        fields: event.fields,
        reminders: event.reminders,
      );

  Future<void> _changeCalendar(VEvent event, Inheritance inheritance) async {
    final chosen = await askCalendar(
      context,
      inheritance: inheritance,
      calendarId: event.calendarId,
      subcategoryId: event.subcategoryId,
    );
    if (chosen == null) return;

    await _saveEdited(
      EventDraft.of(event)
          .withCalendar(chosen.calendarId)
          .withSubcategory(chosen.subcategoryId),
    );
  }

  Future<void> _changeLook(VEvent event, Inheritance inheritance) async {
    final look = await askEventLook(
      context,
      current: EventLook(iconName: event.iconName, color: event.color),
      inheritedColor: inheritance.colorOfEvent(event),
      inheritedIcon: inheritance.iconOfEvent(event),
    );
    if (look == null) return;

    await _saveEdited(
      EventDraft.of(event).withIcon(look.iconName).withColor(look.color),
    );
  }

  Future<void> _changeReminders(VEvent event) async {
    final chosen = await askReminders(context, current: event.reminders);
    if (chosen == null) return;
    await _saveEdited(EventDraft.of(event).withReminders(chosen));
  }

  /// Правка из превью идёт тем же путём, что из формы: у экземпляра ряда
  /// спросят область, у разового события — нет.
  Future<void> _saveEdited(EventDraft draft) => _save(draft);

  Future<void> _copyText(VEvent event, Inheritance inheritance) async {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calendar = inheritance.calendars[event.calendarId]?.name ?? '';

    final text = [
      event.title,
      '${DateFormat('EEEE, d MMMM', locale).format(event.start)} · '
          '${DateFormat.Hm(locale).format(event.start)} – '
          '${DateFormat.Hm(locale).format(event.end)}',
      if (event.location != null) event.location!,
      if (calendar.isNotEmpty) calendar,
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    _say(l.msgEventCopiedText);
  }

  /// Одно событие файлом: тем же форматом, что и общая выгрузка.
  Future<void> _exportOne(VEvent event) async {
    final l = L.of(context);
    final repo = ref.read(repositoryProvider);
    final defs = {for (final f in await repo.fieldsFor(null)) f.id: f};
    if (!context.mounted) return;

    final bytes = utf8.encode(toIcs([event], defs: defs));
    final safe = event.title
        .replaceAll(RegExp('[^A-Za-zА-Яа-яЁё0-9 _-]'), '')
        .trim()
        .replaceAll(' ', '-');

    final path = await FilePicker.platform.saveFile(
      dialogTitle: l.icsSaveTitle,
      fileName: '${safe.isEmpty ? 'event' : safe}.ics',
      bytes: bytes,
    );
    if (!context.mounted || path == null) return;

    if (!Platform.isAndroid) await File(path).writeAsBytes(bytes);
    if (context.mounted) _say(l.icsExported(1));
  }

  Future<void> _openMap(VEvent event) async {
    final place = event.location;
    if (place == null) return;

    // geo: понимает любое картографическое приложение, включая офлайновые.
    final uri = Uri.parse('geo:0,0?q=${Uri.encodeComponent(place)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) _say(L.of(context).placeNoFix);
    }
  }

  Future<void> _openQuickSheet(EventDraft draft, Inheritance inheritance) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => QuickAddSheet(
        draft: draft,
        inheritance: inheritance,
        onSave: (value) {
          Navigator.pop(sheetContext);
          _save(value);
        },
        onDetails: (value) {
          Navigator.pop(sheetContext);
          _openFullForm(value, inheritance);
        },
      ),
    );
  }

  Future<void> _openFullForm(EventDraft draft, Inheritance inheritance) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (formContext) => EventEditScreen(
        draft: draft,
        inheritance: inheritance,
        onSave: (value) {
          Navigator.pop(formContext);
          _save(value);
        },
        onDelete: draft.isEditing
            ? () {
                Navigator.pop(formContext);
                _delete(draft);
              }
            : null,
        onDuplicate: draft.isEditing
            ? () {
                Navigator.pop(formContext);
                duplicate(draft.source!);
              }
            : null,
      ),
    ));
  }

  /// Копия события: та же карточка с новым ключом, сразу в форме.
  ///
  /// Открывается именно форма, а не тихое создание рядом: копируют, чтобы
  /// что-то поменять — время, место, название. Ряд копия не наследует: два
  /// одинаковых расписания на одном календаре человек не имел в виду.
  Future<void> duplicate(VEvent event) async {
    final inheritance = ref.read(inheritanceProvider).valueOrNull;
    if (inheritance == null) return;

    final l = L.of(context);
    final copy = VEvent(
      id: ref.read(repositoryProvider).newId(),
      calendarId: event.calendarId,
      subcategoryId: event.subcategoryId,
      title: l.eventCopySuffix(event.title),
      start: event.start,
      end: event.end,
      color: event.color,
      iconName: event.iconName,
      isAllDay: event.isAllDay,
      location: event.location,
      fields: event.fields,
      reminders: event.reminders,
      timezone: event.timezone,
    );

    // Черновик без `source`: экрану это новое событие, и вопроса про ряд он
    // не задаст.
    await _openFullForm(EventDraft.of(copy).asNew(), inheritance);
  }

  /// Сохранение. У экземпляра ряда спрашиваем область правки — одно и то же
  /// движение может значить «перенеси сегодняшнее» и «теперь всегда так».
  Future<void> _save(EventDraft draft) async {
    final l = L.of(context);
    final repo = ref.read(repositoryProvider);
    final event = draft.toEvent(newId: repo.newId);

    // Сохранение идёт мимо экрана, и упавшая запись раньше пропадала в
    // никуда: человек видел «сохранил», а в базе ничего. Ошибку показываем.
    try {
      if (!draft.needsScopeQuestion) {
        await repo.upsertEvent(event);
        return;
      }

      if (!context.mounted) return;
      final scope = await askEditScope(
        context,
        occurrence: event.originalStart ?? event.start,
        repeatLabel: recurrenceLabelOf(l, event) ?? l.repeatByRule,
      );
      // Лист закрыли, не выбрав: правка не применяется, но и молчать нельзя —
      // человек уверен, что сохранил.
      if (scope == null) {
        _say(l.msgNotSaved);
        return;
      }

      switch (scope) {
        case EditScope.single:
          await repo.upsertEvent(event);
        case EditScope.following:
          await repo.updateFromOccurrence(event);
        case EditScope.series:
          await repo.updateWholeSeries(event);
      }
    } on Exception catch (e) {
      _say('${l.msgSaveFailed}: $e');
    }
  }

  void _say(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Удаление: у ряда это отмена одного занятия, у разового события — само
  /// событие. Обе операции обратимы полоской «Вернуть».
  Future<void> _delete(EventDraft draft) async {
    final repo = ref.read(repositoryProvider);
    final l = L.of(context);
    final source = draft.source!;

    if (source.isOccurrence && source.recurrenceId != null) {
      final series = source.recurrenceId!;
      final moment = source.originalStart ?? source.start;

      // Раньше кнопка молча отменяла одно занятие, и удалить ряд из формы
      // было нельзя вовсе. Теперь спрашиваем — тем же листом, что и правка.
      final scope = await askEditScope(
        context,
        occurrence: moment,
        repeatLabel: recurrenceLabelOf(l, source) ?? l.repeatByRule,
        deleting: true,
      );
      if (scope == null) return;

      switch (scope) {
        case EditScope.single:
          await repo.skipOccurrence(series, moment);
          _offerUndo(
            l.msgOccurrenceSkipped,
            () => repo.unskipOccurrence(series, moment),
          );
        case EditScope.following:
          final before = await repo.eventById(series);
          await repo.trimSeriesAt(series, moment);
          _offerUndo(
            l.msgSeriesTrimmed,
            () async => before == null ? null : repo.upsertEvent(before),
          );
        case EditScope.series:
          await repo.deleteSeries(series);
          _offerUndo(l.msgSeriesDeleted, () => repo.restoreEvent(series));
      }
      return;
    }

    await repo.deleteEvent(source.id);
    _offerUndo(l.msgEventDeleted, () => repo.restoreEvent(source.id));
  }

  /// Отмена одного занятия прямо из списка, без открытия формы.
  Future<void> skip(VEvent occurrence) async {
    final l = L.of(context);
    final repo = ref.read(repositoryProvider);
    final series = occurrence.recurrenceId;
    if (series == null) return;

    final moment = occurrence.originalStart ?? occurrence.start;
    await repo.skipOccurrence(series, moment);
    _offerUndo(
      l.msgCancelledNamed(occurrence.title),
      () => repo.unskipOccurrence(series, moment),
    );
  }

  /// Удаление события целиком: у экземпляра ряда это удаление всего ряда.
  Future<void> deleteWhole(VEvent event) async {
    final l = L.of(context);
    final repo = ref.read(repositoryProvider);
    final id = event.recurrenceId ?? event.id;
    await repo.deleteEvent(id);
    _offerUndo(
      event.isOccurrence ? l.msgSeriesDeleted : l.msgEventDeleted,
      () => repo.restoreEvent(id),
    );
  }

  void _offerUndo(String message, Future<void> Function() undo) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: L.of(context).actionUndo, onPressed: () => undo()),
      ));
  }
}

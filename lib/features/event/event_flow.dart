import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/draft.dart';
import '../calendar/views/chain_view.dart' show recurrenceLabelOf;
import 'edit_scope_sheet.dart';
import 'event_edit_screen.dart';
import 'quick_add_sheet.dart';

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
      ),
    ));
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
      await repo.skipOccurrence(series, moment);
      _offerUndo(
        l.msgOccurrenceSkipped,
        () => repo.unskipOccurrence(series, moment),
      );
      return;
    }

    await repo.deleteEvent(source.id);
    _offerUndo(l.msgEventDeleted, () => repo.upsertEvent(source));
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

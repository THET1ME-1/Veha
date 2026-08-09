import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'note_body.dart';
import '../../domain/recurrence_label.dart';
import '../calendar/widgets/month_header.dart';
import 'event_cover.dart';
import 'reminders_sheet.dart' show remindersLabel;
import '../common/blocks.dart';

/// Событие целиком: шапка, поля одним блоком, заметки.
///
/// Плашка «в карточке» отмечает поля, которые видны в таймлайне. Остальные
/// живут здесь и попадают в поиск наравне с названием.
class EventScreen extends ConsumerWidget {
  const EventScreen({
    super.key,
    required this.event,
    required this.inheritance,
    this.notes = const [],
    this.today,
  });

  final VEvent event;
  final Inheritance inheritance;
  final List<VNote> notes;
  final DateTime? today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final defs = ref.watch(fieldDefsByIdProvider);
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = inheritance.colorOfEvent(event);
    final ink = EventColors.of(color, theme.brightness);

    final coverId = event.recurrenceId ?? event.id;
    final cover = ref.watch(coverProvider(coverId));

    final calendar = inheritance.calendars[event.calendarId];
    final sub = event.subcategoryId == null
        ? null
        : inheritance.subcategories[event.subcategoryId];

    final rows = <Widget>[];
    void add(Widget row) {
      if (rows.isNotEmpty) rows.add(const VSep());
      rows.add(row);
    }

    final repeat = recurrenceLabelOf(l, event, locale: locale);
    if (repeat != null) {
      add(VRow(
        icon: 'repeat',
        label: l.eventRepeat,
        value: repeat,
        trailing: VTag(l.inCard),
      ));
    }
    for (final v in event.fields) {
      final def = defs[v.fieldId];
      add(VRow(
        icon: def?.iconName ?? 'text',
        label: def?.name ?? v.fieldId,
        value: v.value,
        trailing: def?.showInCard == true ? VTag(l.inCard) : null,
      ));
    }
    if (event.location != null) {
      add(VRow(icon: 'place', label: l.eventPlace, value: event.location));
    }
    add(VRow(
      icon: 'bell',
      label: l.eventReminder,
      value: remindersLabel(l, event.reminders),
    ));
    add(VRow(
      icon: 'calendar',
      label: l.eventCalendarAndBranch,
      value: sub == null
          ? calendar?.name ?? ''
          : '${calendar?.name} · ${sub.name}',
      // Плашка отвечает на вопрос, откуда у события цвет: со своей ветки
      // или унаследован от календаря.
      trailing: sub != null && inheritance.subcategoryHasOwnColor(sub)
          ? VTag(l.colorOwn)
          : null,
    ));

    final progress = event.isSpan && today != null
        ? (today!.difference(event.start).inDays + 1) /
            (event.end.difference(event.start).inDays + 1)
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 14, VehaInsets.screen, 120),
      children: [
        VHero(
          icon: inheritance.iconOfEvent(event),
          title: event.title,
          subtitle: _subtitle(locale),
          background: ink.background,
          foreground: ink.foreground,
          progress: progress,
          image: cover,
          action: CoverButton(eventId: coverId, ink: ink),
        ),
        const SizedBox(height: 14),
        VBlock(children: rows),
        if (notes.isNotEmpty) ...[
          VBlockCap(l.notesTitle),
          for (final n in notes) ...[
            _Note(
              note: n,
              color: inheritance.colorOfNote(n, event),
              hasOwnColor: n.color != null,
            ),
            const SizedBox(height: 7),
          ],
          const _AddNote(),
        ],
      ],
    );
  }

  String _subtitle(String locale) {
    if (event.isSpan) {
      final total = event.end.difference(event.start).inDays + 1;
      final passed =
          today == null ? 0 : today!.difference(event.start).inDays + 1;
      final range =
          '${DateFormat.MMMd(locale).format(event.start)} – ${DateFormat.MMMd(locale).format(event.end)}';
      return today == null ? range : '$range · $passed-й день из $total';
    }
    // yMMMMEEEEd тянет за собой «г.» — в шапке события это шум.
    final day = DateFormat('EEEE, d MMMM', locale).format(event.start);
    return '$day · ${_hhmm(event.start)} – ${_hhmm(event.end)}';
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Заметка внутри события — четвёртый уровень цвета. По умолчанию берёт цвет
/// события, но может получить свой: так «паспорт!» видно среди спокойных строк.
class _Note extends StatelessWidget {
  const _Note({
    required this.note,
    required this.color,
    required this.hasOwnColor,
  });

  final VNote note;
  final Color color;
  final bool hasOwnColor;

  @override
  Widget build(BuildContext context) {
    final ink = EventColors.of(color, Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: ink.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: NoteBody(text: note.text, ink: color)),
          if (hasOwnColor) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: ShapeDecoration(
                color: ink.foreground.withValues(alpha: 0.16),
                shape: const StadiumBorder(),
              ),
              child: Text(
                L.of(context).levelOwn,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: ink.foreground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddNote extends StatelessWidget {
  const _AddNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      child: Row(
        children: [
          Icon(VehaIcons.byName('add'), size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            L.of(context).noteAdd,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

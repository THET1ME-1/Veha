import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';

import '../../core/brand.dart';
import '../../domain/phrase.dart';
import '../../l10n/app_localizations.dart';
import 'look_sheet.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../domain/recurrence_label.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../../domain/draft.dart';

/// Быстрое создание события: лист поверх дня.
///
/// Здесь ровно то, без чего событие не существует: название, время, календарь.
/// Остальное живёт в полной форме, куда ведёт «Подробнее» — черновик уезжает
/// туда целиком, набранное не теряется.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({
    super.key,
    required this.draft,
    required this.inheritance,
    required this.onSave,
    required this.onDetails,
    this.onFindSlot,
  });

  final EventDraft draft;
  final Inheritance inheritance;
  final ValueChanged<EventDraft> onSave;
  final ValueChanged<EventDraft> onDetails;

  /// Ближайшее свободное окно нужной длины. `null` — искать негде.
  final Future<DateTime?> Function(Duration length)? onFindSlot;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late EventDraft _draft = widget.draft;
  late final TextEditingController _title =
      TextEditingController(text: _draft.title);

  /// Время тронули руками — строка его больше не двигает. Разбор фразы
  /// помогает, но не спорит: последнее слово всегда за человеком.
  bool _timeTouched = false;

  /// Что вычитано из строки. Показывается плашкой, чтобы человек видел, что
  /// именно понял календарь, и мог поправить.
  String? _read;

  /// Строка разбирается на лету: «Созвон завтра в 15:00 на час» ставит день,
  /// время и длительность, а названием остаётся то, что не разобралось.
  void _readPhrase(String value) {
    if (_timeTouched || value.trim().isEmpty) {
      setState(() {
        _draft = _draft.withTitle(value);
        _read = null;
      });
      return;
    }

    // Точка отсчёта — день, на котором открыт лист, а не системное «сейчас»:
    // ткнули по среде и написали «завтра» — это четверг той же недели.
    final phrase = parsePhrase(value, now: widget.draft.start);
    final understood = phrase.title.trim() != value.trim();

    setState(() {
      _draft = _draft
          .withTitle(phrase.title.isEmpty ? value : phrase.title)
          .withStart(phrase.start)
          .withEnd(phrase.start.add(phrase.duration));
      // Правило из строки применяется вместе с датой: «английский каждый
      // вторник» без этого заводил одно занятие, и человек узнавал об этом
      // через неделю.
      if (phrase.rrule != null) _draft = _draft.withRrule(phrase.rrule);
      _read = understood ? _readLabel(phrase) : null;
    });
  }

  /// Ищет ближайшее окно под текущую длительность и переносит туда событие.
  Future<void> _findSlot() async {
    final found = await widget.onFindSlot!(_draft.duration);
    if (!mounted) return;

    if (found == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(L.of(context).msgNoSlot)));
      return;
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    setState(() {
      _timeTouched = true;
      _draft = _draft.withStart(found);
      _read = L.of(context).msgSlotFound(
        DateFormat('EEE d MMMM, HH:mm', locale).format(found),
      );
    });
  }

  /// Лента частых событий. Тап подставляет название, календарь, длительность
  /// и внешность — остаётся нажать «Готово».
  Widget _frequent() {
    final events = ref.watch(frequentEventsProvider).valueOrNull ?? const [];
    if (events.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 12, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          padding: const EdgeInsets.only(right: VehaInsets.screen),
          itemBuilder: (context, i) => _TimeChip(
            text: events[i].title,
            onTap: () => _useFrequent(events[i]),
          ),
        ),
      ),
    );
  }

  void _useFrequent(VEvent sample) {
    _title.text = sample.title;
    setState(() {
      _timeTouched = true;
      _read = null;
      _draft = _draft
          .withTitle(sample.title)
          .withCalendar(sample.calendarId, subcategoryId: sample.subcategoryId)
          .withColor(sample.color)
          .withIcon(sample.iconName)
          .withEnd(_draft.start.add(sample.duration));
    });
  }

  String _readLabel(Phrase phrase) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final when = DateFormat('EEE d MMMM, HH:mm', locale).format(phrase.start);
    // Разобранное правило показывается до применения: вслепую повтор не
    // ставится, иначе человек получит не тот ряд и заметит через месяц.
    final repeat = phrase.rrule == null
        ? ''
        : ' · ${recurrenceLabelOf(L.of(context), _draft.toEvent(newId: () => 'preview'), locale: locale) ?? ''}';
    return '${L.of(context).quickPhraseRead}: $when$repeat';
  }

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
    _timeTouched = true;
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
    _timeTouched = true;
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

  /// Цвет и иконка будущего события: свои, если человек их выбрал, иначе от
  /// календаря — ровно та же цепочка, что рисует событие в дне.
  Color _lookColor() =>
      _draft.color ??
      widget.inheritance.calendars[_draft.calendarId]?.color ??
      VehaBrand.seed;

  String _lookIcon() =>
      _draft.iconName ??
      widget.inheritance.calendars[_draft.calendarId]?.iconName ??
      'calendar';

  Future<void> _pickLook() async {
    final look = await askEventLook(
      context,
      current: EventLook(iconName: _draft.iconName, color: _draft.color),
      inheritedColor: _lookColor(),
      inheritedIcon: _lookIcon(),
    );
    if (look == null) return;
    setState(() => _draft = _draft.withIcon(look.iconName).withColor(look.color));
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
            child: Row(
              children: [
                // Кружок слева от названия — тот же, что в полной форме: по
                // нему видно, в какой календарь событие ляжет, ещё до того,
                // как человек дочитает пилюли ниже.
                _Look(
                  color: _lookColor(),
                  icon: _lookIcon(),
                  onTap: _pickLook,
                ),
                const SizedBox(width: 12),
                Expanded(
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
                hintText: L.of(context).quickPhraseHint,
                hintStyle: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: scheme.outline,
                ),
              ),
              onChanged: _readPhrase,
              onSubmitted: (_) => _save(),
            ),
                ),
              ],
            ),
          ),
          // Половина событий повторяет прошлые: подсказываем то, что человек
          // уже заводил, вместо шаблонов, которые надо готовить руками.
          if (_draft.title.trim().isEmpty) _frequent(),
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
                // «Поставь, где влезет» — вопрос, на который календари обычно
                // не отвечают, хотя спрашивают его чаще, чем «когда я занят».
                if (widget.onFindSlot != null)
                  _TimeChip(
                    text: L.of(context).findSlot,
                    onTap: _findSlot,
                  ),
                // Плашка «понял из строки»: человек видит, что именно
                // календарь вычитал, и может поправить чипами рядом.
                if (_read != null)
                  Text(
                    _read!,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
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
                        setState(() {
                          _timeTouched = true;
                          _draft = _draft.withDuration(value);
                        }),
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
                    L.of(context).moreDetails,
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
                  label: Text(L.of(context).actionDone),
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

/// Кружок с иконкой события. Нажимается: отсюда же меняются иконка и цвет.
class _Look extends StatelessWidget {
  const _Look({required this.color, required this.icon, required this.onTap});

  final Color color;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = EventColors.of(color, Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: ink.background,
          shape: const CircleBorder(),
        ),
        child: Icon(VehaIcons.byName(icon), size: 23, color: ink.foreground),
      ),
    );
  }
}

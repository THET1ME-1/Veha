import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';
import '../event/event_flow.dart';

/// Поиск по всему календарю: название, место и значения своих полей.
///
/// Отдельный экран, а не строка в шапке: к найденному нужны дата, календарь и
/// место, а это уже карточка, которой в шапку не поместиться.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  /// Пустое множество — все календари. Отдельного «показать все» не нужно:
  /// снятая последняя пилюля означает то же самое.
  final Set<String> _only = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;
    final found = ref.watch(searchProvider(_query)).valueOrNull ?? const [];

    final calendars = inheritance == null
        ? const <VCalendar>[]
        : (inheritance.calendars.values.toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));

    final results = _only.isEmpty
        ? found
        : found.where((e) => _only.contains(e.calendarId)).toList();

    return Scaffold(
      appBar: AppBar(toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 0, VehaInsets.screen, 12),
            child: _Field(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() {
                _controller.clear();
                _query = '';
              }),
            ),
          ),
          if (calendars.isNotEmpty)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: VehaInsets.screen),
                children: [
                  for (final c in calendars) ...[
                    _CalendarChip(
                      calendar: c,
                      selected: _only.contains(c.id),
                      onTap: () => setState(() {
                        if (!_only.remove(c.id)) _only.add(c.id);
                      }),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          Expanded(
            child: _query.trim().isEmpty
                ? _Hint(
                    text: 'Ищите по названию, месту или своему полю — '
                        'например по номеру кабинета.',
                    scheme: scheme,
                  )
                : results.isEmpty
                    ? _Hint(text: 'Ничего не нашлось.', scheme: scheme)
                    : _Results(
                        results: results,
                        inheritance: inheritance,
                        onTap: (e) => EventFlow(context, ref).edit(e),
                      ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          Icon(VehaIcons.byName('search'), size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: 'Найти событие',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.outline,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(VehaIcons.byName('close'),
                  size: 20, color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _CalendarChip extends StatelessWidget {
  const _CalendarChip({
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
    final ink = EventColors.of(calendar.color, theme.brightness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: ShapeDecoration(
          color: selected
              ? ink.background
              : theme.colorScheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Text(
          calendar.name,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? ink.foreground
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.results,
    required this.inheritance,
    required this.onTap,
  });

  final List<VEvent> results;
  final Inheritance? inheritance;
  final ValueChanged<VEvent> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 12, VehaInsets.screen, 40),
      children: [
        VBlock(children: [
          for (var i = 0; i < results.length; i++) ...[
            if (i > 0) const VSep(),
            _ResultRow(
              event: results[i],
              inheritance: inheritance,
              onTap: () => onTap(results[i]),
            ),
          ],
        ]),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.event,
    required this.inheritance,
    required this.onTap,
  });

  final VEvent event;
  final Inheritance? inheritance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = inheritance?.colorOfEvent(event) ?? VehaBrand.seed;
    final ink = EventColors.of(color, theme.brightness);
    final icon = inheritance?.iconOfEvent(event) ?? 'calendar';

    final where = event.location;
    final when = _when(event);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const CircleBorder(),
              ),
              child: Icon(VehaIcons.byName(icon),
                  size: 19, color: ink.foreground),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    where == null ? when : '$when · $where',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Когда это. У полосы на месяц часов нет вовсе, и «00:00 – 00:00» в выдаче
  /// выглядит поломкой: у неё показываем промежуток дат.
  static String _when(VEvent e) {
    if (e.isMultiDay || e.isAllDay) {
      final from = DateFormat('d MMMM', 'ru').format(e.start);
      final to = DateFormat('d MMMM', 'ru').format(
        e.end.subtract(const Duration(minutes: 1)),
      );
      return from == to ? '$from · весь день' : '$from – $to';
    }
    final day = DateFormat('E d MMMM', 'ru').format(e.start);
    return '$day · ${_hhmm(e.start)} – ${_hhmm(e.end)}';
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.scheme});

  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 40, VehaInsets.screen, 0),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13.5,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

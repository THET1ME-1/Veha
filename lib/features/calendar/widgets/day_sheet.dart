import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../domain/time_label.dart';
import '../../../l10n/app_localizations.dart';
import 'month_header.dart' show AppFonts;

/// День, раскрытый листом поверх месяца.
///
/// Тап по числу не должен уводить из месяца: человек смотрит на месяц, чтобы
/// понять, какой день выбрать, и после первого же тапа терял картину целиком.
/// Лист тянется по высоте — от полоски с парой событий до почти полного
/// экрана, — и закрывается вниз, оставляя месяц на месте.
Future<DaySheetChoice?> showDaySheet(
  BuildContext context, {
  required DateTime day,
  required List<VEvent> events,
  required List<VEvent> spans,
  required Inheritance inheritance,
}) {
  return showModalBottomSheet<DaySheetChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      // Начальная высота под содержимое: пустой день не должен разворачиваться
      // во весь экран, а плотный — открываться щёлочкой.
      initialChildSize: events.length <= 3 ? 0.45 : 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) => _DaySheet(
        day: day,
        events: events,
        spans: spans,
        inheritance: inheritance,
        controller: controller,
      ),
    ),
  );
}

/// Что человек выбрал в листе дня.
class DaySheetChoice {
  const DaySheetChoice.openDay() : event = null;
  const DaySheetChoice.event(this.event);

  /// Событие, по которому ткнули. `null` — «открыть день целиком».
  final VEvent? event;
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({
    required this.day,
    required this.events,
    required this.spans,
    required this.inheritance,
    required this.controller,
  });

  final DateTime day;
  final List<VEvent> events;
  final List<VEvent> spans;
  final Inheritance inheritance;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat('EEEE, d MMMM', locale).format(day);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 0, VehaInsets.screen, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title[0].toUpperCase() + title.substring(1),
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 21,
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(context, const DaySheetChoice.openDay()),
              icon: Icon(VehaIcons.byName('calendar_today'), size: 17),
              label: Text(l.dayOpenFull),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty && spans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Text(
              l.dayEmpty,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        // Полосы идут первыми: «идёт сейчас» важнее, чем «в 10:00».
        for (final e in spans) _Row(event: e, inheritance: inheritance),
        for (final e in events) _Row(event: e, inheritance: inheritance),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.event, required this.inheritance});

  final VEvent event;
  final Inheritance inheritance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink =
        EventColors.of(inheritance.colorOfEvent(event), theme.brightness);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: InkWell(
        onTap: () => Navigator.pop(context, DaySheetChoice.event(event)),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: ShapeDecoration(
            color: ink.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          child: Row(
            children: [
              Icon(VehaIcons.byName(inheritance.iconOfEvent(event)),
                  size: 18, color: ink.foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ink.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                event.isSpan ? '' : eventTimeLabel(context, event),
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ink.foreground.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

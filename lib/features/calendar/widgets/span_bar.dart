import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import 'month_header.dart';

/// Полоса события длиннее суток: абонемент, курс, отпуск.
///
/// Позиция внутри суток у такого события бессмысленна, важно только «идёт
/// сейчас», поэтому в сетку часов оно не попадает — живёт полосой сверху.
/// Прогресс показан заливкой поверх, а не отдельной шкалой.
class SpanBar extends StatelessWidget {
  const SpanBar({super.key, required this.event, required this.today, required this.color});

  final VEvent event;
  final DateTime today;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ink = EventColors.of(color, Theme.of(context).brightness);
    // Обе границы входят в срок: с 16 июля по 14 августа — это 30 дней,
    // а не 29, как выйдет из голой разницы дат.
    final total = event.end.difference(event.start).inDays + 1;
    final passed = today.difference(event.start).inDays + 1;
    final progress = total <= 0 ? 0.0 : (passed / total).clamp(0.0, 1.0);

    // Всё, что длиннее месяца, считать «днём из N» бессмысленно — там важнее
    // дата окончания.
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final trailing = total <= 45
        ? l.spanDayOf(passed, total)
        : l.spanUntil(DateFormat.MMMd(locale).format(event.end));

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: StadiumBorder()),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: ink.background)),
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: ColoredBox(
                  color: ink.foreground.withValues(alpha: 0.16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Icon(VehaIcons.byName(event.iconName),
                      size: 15, color: ink.foreground),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      event.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: ink.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trailing,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: ink.foreground.withValues(alpha: 0.8),
                      fontFeatures: const [FontFeature.tabularFigures()],
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

}

/// Список полос над таймлайном.
class SpanBars extends StatelessWidget {
  const SpanBars({
    super.key,
    required this.events,
    required this.today,
    required this.inheritance,
  });

  final List<VEvent> events;
  final DateTime today;
  final Inheritance inheritance;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 2),
      child: Column(
        children: [
          for (final e in events)
            SpanBar(
              event: e,
              today: today,
              color: inheritance.colorOfEvent(e),
            ),
        ],
      ),
    );
  }
}

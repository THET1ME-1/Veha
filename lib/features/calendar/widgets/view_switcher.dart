import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/brand.dart';
import '../../../l10n/app_localizations.dart';
import 'month_header.dart';

enum CalendarView { day, bands, week, month }

extension CalendarViewLabel on CalendarView {
  String label(L l) => switch (this) {
        CalendarView.day => l.viewDay,
        CalendarView.bands => l.viewDays,
        CalendarView.week => l.viewWeek,
        CalendarView.month => l.viewMonth,
      };

  IconData get icon => switch (this) {
        CalendarView.day => Symbols.calendar_view_day_rounded,
        CalendarView.bands => Symbols.view_agenda_rounded,
        CalendarView.week => Symbols.view_week_rounded,
        CalendarView.month => Symbols.calendar_month_rounded,
      };
}

/// Сегментированный контрол на всю ширину: контейнер-заливка, активный сегмент
/// тоже заливка. Ни рамки контейнера, ни обводки сегмента — глубина строится
/// уровнями surfaceContainer.
class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({super.key, required this.value, required this.onChanged});

  final CalendarView value;
  final ValueChanged<CalendarView> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 14, VehaInsets.screen, 4),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            for (final v in CalendarView.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(v),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: v == value
                          ? scheme.secondaryContainer
                          : Colors.transparent,
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (v == value) ...[
                          Icon(v.icon,
                              size: 16, color: scheme.onSecondaryContainer),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                          v.label(l),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: v == value
                                ? scheme.onSecondaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

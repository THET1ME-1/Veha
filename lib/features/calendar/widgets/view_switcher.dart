import 'package:flutter/material.dart';

import '../../../core/icon_registry.dart';
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
    CalendarView.day => VehaIcons.byName('viewDay'),
    CalendarView.bands => VehaIcons.byName('viewAgenda'),
    CalendarView.week => VehaIcons.byName('viewWeek'),
    CalendarView.month => VehaIcons.byName('calendar'),
  };
}

/// Сегментированный контрол на всю ширину: контейнер-заливка, активный сегмент
/// тоже заливка. Ни рамки контейнера, ни обводки сегмента — глубина строится
/// уровнями surfaceContainer.
class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSetup,
  });

  final CalendarView value;
  final ValueChanged<CalendarView> onChanged;

  /// Настройка текущего вида. Кнопка появляется только там, где настраивать
  /// действительно есть что, — иначе она мозолит глаза на всех видах сразу.
  final VoidCallback? onSetup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VehaInsets.screen,
        14,
        VehaInsets.screen,
        4,
      ),
      child: Row(
        children: [
          Expanded(
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
                          height: 44,
                          decoration: ShapeDecoration(
                            color: v == value
                                ? scheme.secondaryContainer
                                : Colors.transparent,
                            shape: const StadiumBorder(),
                          ),
                          // Иконка стоит у всех четырёх сегментов, а не у одного
                          // активного: иначе подпись активного съезжает вправо, и
                          // при переключении вида дёргаются все четыре слова.
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                v.icon,
                                size: 15,
                                color: v == value
                                    ? scheme.onSecondaryContainer
                                    : scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  v.label(l),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppFonts.body,
                                    fontSize: 12.5,
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
          ),
          if (onSetup != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onSetup,
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: const CircleBorder(),
                ),
                child: Icon(
                  VehaIcons.byName('tune'),
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

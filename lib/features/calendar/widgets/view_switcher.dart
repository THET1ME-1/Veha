import 'package:flutter/material.dart';

import '../../../core/icon_registry.dart';
import '../../../core/veha_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Три вида календаря. Лента «Дни» убрана: она отличалась от «Дня» одной
/// настройкой длины и делила экран пополам ни за чем.
enum CalendarView { day, week, month }

extension CalendarViewLabel on CalendarView {
  String label(L l) => switch (this) {
        CalendarView.day => l.viewDay,
        CalendarView.week => l.viewWeek,
        CalendarView.month => l.viewMonth,
      };

  IconData get icon => switch (this) {
        CalendarView.day => VehaIcons.byName('viewDay'),
        CalendarView.week => VehaIcons.byName('viewWeek'),
        CalendarView.month => VehaIcons.byName('calendar'),
      };
}

/// Нижняя панель: переключатель видов и круглая кнопка настроек.
///
/// Стоит внизу, а не в шапке: до верха экрана большой палец не достаёт, а
/// переключают вид чаще, чем делают что-либо ещё. Вкладок «Задачи» и «Список»
/// здесь нет — у задачи нет длительности, ей нечего делать в календаре, а
/// список календарей открывается из настроек.
class ViewDock extends StatelessWidget {
  const ViewDock({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onSettings,
    this.onSetup,
  });

  final CalendarView value;
  final ValueChanged<CalendarView> onChanged;
  final VoidCallback onSettings;

  /// Настройка текущего вида: раскладка недели, вид месяца. Открывается
  /// долгим нажатием на активную пилюлю — отдельной кнопке в доке места нет,
  /// а настраивают вид раз в полгода.
  final VoidCallback? onSetup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: ShapeDecoration(
                  color: scheme.surfaceContainerLow,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  children: [
                    for (final v in CalendarView.values)
                      Expanded(
                        child: _Tab(
                          text: v.label(l),
                          selected: v == value,
                          onTap: () => onChanged(v),
                          onLongPress: v == value ? onSetup : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _Round(
              icon: VehaIcons.byName('tune'),
              tooltip: l.navSettings,
              onTap: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.text,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: selected ? scheme.onSurface : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? scheme.surface : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: scheme.surfaceContainerHigh,
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 22, color: scheme.onSurface),
        ),
      ),
    );
  }
}

/// Кнопка настройки текущего вида: раскладка недели, вид месяца.
///
/// Живёт в шапке рядом с периодом, а не в доке: настраивают вид редко, а
/// место внизу занято переключателем.
class ViewSetupButton extends StatelessWidget {
  const ViewSetupButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      icon: Icon(VehaIcons.byName('tune'), size: 20),
      style: IconButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: VehaShape.of(context).all,
        ),
      ),
    );
  }
}

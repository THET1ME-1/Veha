import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/calendar_screen.dart';
import '../calendars/calendars_screen.dart';
import '../event/event_flow.dart';
import '../settings/settings_screen.dart';
import '../tasks/tasks_screen.dart';

/// Оболочка приложения: четыре раздела.
///
/// На телефоне навигация внизу, бокового меню нет и не будет: переключение
/// видов живёт в сегментированном контроле, список календарей — в нижнем
/// листе. На широком экране те же четыре раздела переезжают в рельсу — в
/// браузере и на планшете вкладки внизу читаются как ошибка вёрстки: палец
/// до них не идёт, мышь тем более.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  /// Порог, за которым телефонная раскладка перестаёт годиться. Взят из
  /// адаптивных размеров Material 3: до 600 — компактный экран.
  static const double wideAt = 600;

  /// Шире этого содержимое не растягивается. Строка календаря во весь
  /// двухтысячный монитор нечитаема: глаз теряет строку на обратном ходе.
  static const double contentMax = 1100;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  /// `null` — ещё не открывали: берём стартовый раздел из настроек.
  int? _tab;

  static final _icons = [
    VehaIcons.byName('calendar'),
    VehaIcons.byName('task_alt'),
    VehaIcons.byName('list'),
    VehaIcons.byName('tune'),
  ];

  List<String> _labels(BuildContext context) {
    final l = L.of(context);
    return [l.navCalendar, l.navTasks, l.navList, l.navSettings];
  }

  @override
  Widget build(BuildContext context) {
    // Раздел на старте берётся из настроек, дальше живёт своим состоянием:
    // человек ушёл в список — приложение не должно возвращать его в календарь.
    _tab ??= ref.watch(startTabProvider);
    final tab = _tab!;
    final scheme = Theme.of(context).colorScheme;
    final labels = _labels(context);
    final wide = MediaQuery.sizeOf(context).width >= HomeShell.wideAt;

    final content = KeyedSubtree(
      key: const ValueKey('shell-content'),
      child: _page(tab),
    );

    if (!wide) {
      return Scaffold(
        body: SafeArea(bottom: false, child: content),
        floatingActionButton: _fab(tab),
        bottomNavigationBar: NavigationBar(
          // ДНК прячет подписи неактивных разделов, но в макете подписаны все
          // четыре: без них «Доступ» и «Настройки» по иконке не различить.
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            for (var i = 0; i < _icons.length; i++)
              NavigationDestination(
                icon: Icon(_icons[i], size: 22, color: scheme.onSurfaceVariant),
                selectedIcon:
                    Icon(_icons[i], size: 22, color: scheme.onPrimaryContainer),
                label: labels[i],
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              // Подписи видны всегда по той же причине, что и внизу: четыре
              // иконки без слов не различаются.
              labelType: NavigationRailLabelType.all,
              backgroundColor: scheme.surfaceContainerLow,
              indicatorColor: scheme.secondaryContainer,
              // Кнопка «завести» живёт в шапке рельсы: на широком экране
              // плавающая кнопка в углу оказывается за пределами взгляда.
              leading: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: _fab(tab) ?? const SizedBox(width: 56, height: 56),
              ),
              destinations: [
                for (var i = 0; i < _icons.length; i++)
                  NavigationRailDestination(
                    icon:
                        Icon(_icons[i], size: 22, color: scheme.onSurfaceVariant),
                    selectedIcon: Icon(_icons[i],
                        size: 22, color: scheme.onSecondaryContainer),
                    label: Text(labels[i]),
                  ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: HomeShell.contentMax),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Кнопка «завести»: событие в календаре, задачу в задачах. В списке
  /// календарей и настройках заводить нечего — там её нет.
  Widget? _fab(int tab) {
    if (tab > 1) return null;
    return FloatingActionButton(
      onPressed: () => tab == 0
          ? EventFlow(context, ref).create()
          : createTask(
              context,
              ref,
              ref.read(inheritanceProvider).valueOrNull ??
                  const Inheritance(calendars: {}, subcategories: {}),
            ),
      tooltip: tab == 0 ? L.of(context).newEvent : L.of(context).taskNew,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      child: Icon(VehaIcons.byName('add'), size: 28),
    );
  }

  // Доступ для ИИ живёт не вкладкой, а строкой в настройках рядом с
  // синхронизацией: ключи и работают только при ней, а открывают этот экран
  // раз в полгода.
  Widget _page(int tab) => switch (tab) {
        0 => const CalendarScreen(),
        1 => const TasksScreen(),
        2 => const CalendarsScreen(),
        _ => const SettingsScreen(),
      };
}

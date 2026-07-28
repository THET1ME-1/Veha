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

/// Оболочка приложения: нижняя навигация на четыре раздела.
/// Боковой панели нет и не будет — переключение видов живёт в сегментированном
/// контроле, список календарей в нижнем листе.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

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

    return Scaffold(
      body: SafeArea(bottom: false, child: _page(tab)),
      floatingActionButton: tab > 1
          ? null
          : FloatingActionButton(
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
            ),
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

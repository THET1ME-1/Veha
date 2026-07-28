import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icon_registry.dart';
import '../../l10n/app_localizations.dart';
import '../access/access_screen.dart';
import '../calendar/calendar_screen.dart';
import '../calendars/calendars_screen.dart';
import '../event/event_flow.dart';
import '../settings/settings_screen.dart';

/// Оболочка приложения: нижняя навигация на четыре раздела.
/// Боковой панели нет и не будет — переключение видов живёт в сегментированном
/// контроле, список календарей в нижнем листе.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  static final _icons = [
    VehaIcons.byName('calendar'),
    VehaIcons.byName('list'),
    VehaIcons.byName('key'),
    VehaIcons.byName('tune'),
  ];

  List<String> _labels(BuildContext context) {
    final l = L.of(context);
    return [l.navCalendar, l.navList, l.navAccess, l.navSettings];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labels = _labels(context);

    return Scaffold(
      body: SafeArea(bottom: false, child: _page()),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: () => EventFlow(context, ref).create(),
              tooltip: L.of(context).newEvent,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              child: Icon(VehaIcons.byName('add'), size: 28),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        // ДНК прячет подписи неактивных разделов, но в макете подписаны все
        // четыре: без них «Доступ» и «Настройки» по иконке не различить.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _tab,
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

  Widget _page() => switch (_tab) {
        0 => const CalendarScreen(),
        1 => const CalendarsScreen(),
        2 => AccessScreen(keys: demoKeys),
        _ => const SettingsScreen(),
      };

  /// Демонстрационные ключи: серверного слоя ещё нет, но экран должен быть
  /// собран и сверен с макетом до него.
  static const demoKeys = [
    AccessKey(
      name: 'Claude · планировщик',
      prefix: 'cal_a8f3k2 · · · · · ·',
      scopes: [('Личное', false), ('Учёба', true), ('Спорт', false)],
      lastUsed: 'Работал 12 минут назад',
      expires: 'до 30 сентября',
    ),
    AccessKey(
      name: 'Домашний ассистент',
      prefix: 'cal_7z1qm4 · · · · · ·',
      scopes: [('Дом', false), ('Бессрочно', false)],
      lastUsed: 'Работал вчера в 21:03',
    ),
    AccessKey(
      name: 'Пробный ключ',
      prefix: 'отозван 24 июля',
      scopes: [],
      lastUsed: '',
      revoked: true,
    ),
  ];
}

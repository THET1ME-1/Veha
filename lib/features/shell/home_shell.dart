import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../calendar/calendar_screen.dart';
import '../calendar/widgets/month_header.dart';

/// Оболочка приложения: нижняя навигация на четыре раздела.
/// Боковой панели нет и не будет — переключение видов живёт в сегментированном
/// контроле, список календарей в нижнем листе.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _icons = [
    Symbols.calendar_month_rounded,
    Symbols.format_list_bulleted_rounded,
    Symbols.key_rounded,
    Symbols.tune_rounded,
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
              onPressed: () {},
              tooltip: L.of(context).newEvent,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              child: const Icon(Symbols.add_rounded, size: 28),
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
        _ => _Stub(label: _labels(context)[_tab]),
      };
}

class _Stub extends StatelessWidget {
  const _Stub({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

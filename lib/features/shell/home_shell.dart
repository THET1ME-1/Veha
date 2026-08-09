import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../calendar/calendar_screen.dart';

/// Оболочка приложения: один экран — календарь.
///
/// Четыре раздела внизу убраны. Виды переключает док в самом календаре, а
/// задачи, список календарей и доступ для ИИ живут строками в настройках:
/// открывают их редко, а место внизу нужно тому, чем пользуются каждый день.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  /// Шире этого содержимое не растягивается. Строка календаря во весь
  /// двухтысячный монитор нечитаема: глаз теряет строку на обратном ходе.
  static const double contentMax = 1100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: contentMax),
            child: const CalendarScreen(),
          ),
        ),
      ),
    );
  }
}

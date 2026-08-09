import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/widgets/span_bar.dart';

import 'golden_harness.dart';

/// Подпись длинной полосы: какой это день из скольких.
///
/// Счёт идёт от выбранного дня, и когда полоса ещё не началась, разница дат
/// уходит в минус: над неделей висело «-34-й из 2». Число дней события не
/// может быть отрицательным и не может превышать длину события.
void main() {
  setUpAll(loadAppFonts);

  Widget bar(DateTime today) => SpanBars(
        events: [
          VEvent(
            id: 'birthday',
            calendarId: 'c1',
            title: 'День программиста',
            start: DateTime(2026, 9, 13),
            end: DateTime(2026, 9, 14),
            isAllDay: true,
            timezone: 'Europe/Chisinau',
          ),
        ],
        today: today,
        inheritance: const Inheritance(calendars: {}, subcategories: {}),
      );

  testWidgets('Внутри полосы считается день из скольких', (tester) async {
    await pumpScreen(tester, bar(DateTime(2026, 9, 14)));

    expect(find.textContaining('2-й из 2'), findsOneWidget);
  });

  testWidgets('До начала полосы номер не уходит в минус', (tester) async {
    await pumpScreen(tester, bar(DateTime(2026, 8, 9)));

    // Дефис в «1-й» законен, а вот минус перед числом — нет.
    expect(find.textContaining('-1-й'), findsNothing);
    expect(find.textContaining('1-й из 2'), findsOneWidget);
  });

  testWidgets('После конца номер не перескакивает длину', (tester) async {
    await pumpScreen(tester, bar(DateTime(2026, 10, 20)));

    expect(find.textContaining('2-й из 2'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/tape_view.dart';

import 'golden_harness.dart';

/// Риска «сейчас» в ленте одна.
///
/// Окно свободного времени считалось мимо событий с пометкой «свободен», и
/// момент попадал сразу в две строки: в блок отдыха и в окно, лёгшее поверх
/// него. Красных рисок на экране становилось две.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Красная риска рисуется один раз', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: TapeView(
          day: DateTime(2026, 8, 9),
          now: DateTime(2026, 8, 9, 23, 13),
          events: [
            VEvent(
              id: 'walk',
              calendarId: 'life',
              title: 'Прогулка',
              start: DateTime(2026, 8, 9, 18),
              end: DateTime(2026, 8, 9, 21, 45),
            ),
            VEvent(
              id: 'rest',
              calendarId: 'life',
              title: 'Отдых',
              start: DateTime(2026, 8, 9, 22),
              end: DateTime(2026, 8, 9, 23, 30),
              availability: Availability.free,
            ),
          ],
          inheritance: const Inheritance(calendars: {}, subcategories: {}),
        ),
      ),
    );

    expect(find.byKey(const Key('now-line')), findsOneWidget);
  });
}

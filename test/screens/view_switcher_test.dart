import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/widgets/view_switcher.dart';

import 'golden_harness.dart';

/// Подписи переключателя обязаны стоять на одной сетке во всех положениях:
/// иначе при смене вида все четыре слова дёргаются.
void main() {
  setUpAll(loadAppFonts);

  Future<Map<String, double>> centersOf(
    WidgetTester tester,
    CalendarView active,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: ViewSwitcher(value: active, onChanged: (_) {}),
        ),
      ),
    );

    return {
      for (final label in const ['День', 'Дни', 'Неделя', 'Месяц'])
        label: tester.getCenter(find.text(label)).dx,
    };
  }

  testWidgets('Подписи стоят на месте при любом активном виде', (tester) async {
    final onDay = await centersOf(tester, CalendarView.day);
    final onMonth = await centersOf(tester, CalendarView.month);

    for (final label in onDay.keys) {
      expect(onDay[label], closeTo(onMonth[label]!, 0.5),
          reason: 'Подпись «$label» не должна съезжать при смене вида');
    }
  });

  testWidgets('Подписи видны целиком, без многоточия', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: ViewSwitcher(value: CalendarView.week, onChanged: (_) {}),
        ),
      ),
    );

    for (final label in const ['День', 'Дни', 'Неделя', 'Месяц']) {
      final text = tester.widget<Text>(find.text(label));
      final painter = TextPainter(
        text: TextSpan(text: label, style: text.style),
        textDirection: TextDirection.ltr,
      )..layout();

      // Обрезка съедает десятки пикселей, поэтому округления в пределах
      // пикселя допустимы.
      expect(tester.getSize(find.text(label)).width,
          closeTo(painter.width, 1.5),
          reason: 'Подпись «$label» обрезана многоточием');
    }
  });

  testWidgets('Снимок переключателя', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ViewSwitcher(value: CalendarView.day, onChanged: _ignore),
              SizedBox(height: 10),
              ViewSwitcher(value: CalendarView.bands, onChanged: _ignore),
              SizedBox(height: 10),
              ViewSwitcher(value: CalendarView.week, onChanged: _ignore),
              SizedBox(height: 10),
              ViewSwitcher(value: CalendarView.month, onChanged: _ignore),
            ],
          ),
        ),
      ),
    );

    await shoot(tester, 'view_switcher');
  });
}

void _ignore(CalendarView _) {}

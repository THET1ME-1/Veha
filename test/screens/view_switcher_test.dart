import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/widgets/view_switcher.dart';

import 'golden_harness.dart';

/// Подписи дока обязаны стоять на одной сетке во всех положениях: иначе при
/// смене вида все три слова дёргаются.
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
          child: ViewDock(
            value: active,
            onChanged: _ignore,
            onSettings: _nothing,
          ),
        ),
      ),
    );

    return {
      for (final label in const ['День', 'Неделя', 'Месяц'])
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
          child: ViewDock(
            value: CalendarView.week,
            onChanged: _ignore,
            onSettings: _nothing,
          ),
        ),
      ),
    );

    for (final label in const ['День', 'Неделя', 'Месяц']) {
      final text = tester.widget<Text>(find.text(label));
      final painter = TextPainter(
        text: TextSpan(text: label, style: text.style),
        textDirection: TextDirection.ltr,
      )..layout();

      // Обрезка съедает десятки пикселей, поэтому округления в пределах
      // пикселя допустимы.
      expect(tester.getSize(find.text(label)).width, closeTo(painter.width, 1.5),
          reason: 'Подпись «$label» обрезана многоточием');
    }
  });

  testWidgets('Кнопка настроек стоит рядом с переключателем', (tester) async {
    var opened = false;
    await pumpScreen(
      tester,
      Scaffold(
        body: Center(
          child: ViewDock(
            value: CalendarView.day,
            onChanged: _ignore,
            onSettings: () => opened = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Настройки'));
    expect(opened, isTrue, reason: 'Круглая кнопка должна открывать настройки');
  });

  testWidgets('Снимок дока', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ViewDock(
                value: CalendarView.day,
                onChanged: _ignore,
                onSettings: _nothing,
              ),
              SizedBox(height: 10),
              ViewDock(
                value: CalendarView.week,
                onChanged: _ignore,
                onSettings: _nothing,
              ),
              SizedBox(height: 10),
              ViewDock(
                value: CalendarView.month,
                onChanged: _ignore,
                onSettings: _nothing,
              ),
            ],
          ),
        ),
      ),
    );

    await shoot(tester, 'view_dock');
  });
}

void _ignore(CalendarView _) {}

void _nothing() {}

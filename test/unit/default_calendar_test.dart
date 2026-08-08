import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';

/// Куда ложится новое событие, когда человек ни о чём не спрашивал.
///
/// Виды календаря показывают только видимые календари. Пока новое событие
/// уходило в первый по порядку, достаточно было спрятать его — и заведённое
/// событие исчезало без следа: создалось, сохранилось, нигде не показано.
void main() {
  VCalendar cal(String id, {bool visible = true, int order = 0}) => VCalendar(
        id: id,
        name: id,
        iconName: 'calendar',
        color: const Color(0xFF41CCB5),
        isVisible: visible,
        sortOrder: order,
      );

  Inheritance of(List<VCalendar> calendars) => Inheritance(
        calendars: {for (final c in calendars) c.id: c},
        subcategories: const {},
      );

  test('Новое событие идёт в первый видимый календарь', () {
    final tree = of([
      cal('спрятанный', visible: false),
      cal('рабочий', order: 1),
    ]);

    expect(tree.defaultCalendarId, 'рабочий');
  });

  test('Все календари спрятаны — берём первый, событие не теряем', () {
    final tree = of([
      cal('первый', visible: false),
      cal('второй', visible: false, order: 1),
    ]);

    expect(tree.defaultCalendarId, 'первый');
  });

  test('Календарей нет вовсе — заводить некуда', () {
    expect(of(const []).defaultCalendarId, isNull);
  });
}

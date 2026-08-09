import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/providers.dart';
import 'package:veha/domain/span_progress.dart';

/// Полоса длиной в один день не должна пропадать.
///
/// Отбор полос спрашивал `end.isAfter(начало дня)`, то есть считал конец
/// исключающим. У праздника конец равен началу, и он не попадал ни в полосы,
/// ни в дневной список: в календаре событие есть, а в листе дня «ничего не
/// запланировано».
void main() {
  VEvent holiday() => VEvent(
        id: 'parade',
        calendarId: 'hol',
        title: 'Парад планет',
        start: DateTime(2026, 8, 12),
        end: DateTime(2026, 8, 12),
        isAllDay: true,
      );

  /// Так Google выгружает сутки: с полуночи 26-го до полуночи 27-го.
  VEvent birthday() => VEvent(
        id: 'birthday',
        calendarId: 'family',
        title: 'Богдан Цавц — день рождения',
        start: DateTime(2024, 8, 26),
        end: DateTime(2024, 8, 27),
      );

  RangeData range(List<VEvent> spans) => RangeData(byDay: const {}, spans: spans);

  test('Праздник виден в свой день', () {
    expect(range([holiday()]).spansOn(DateTime(2026, 8, 12)), hasLength(1));
  });

  test('Праздник не виден в соседние дни', () {
    final data = range([holiday()]);
    expect(data.spansOn(DateTime(2026, 8, 11)), isEmpty);
    expect(data.spansOn(DateTime(2026, 8, 13)), isEmpty);
  });

  test('Сутки от полуночи до полуночи видны только в свой день', () {
    final data = range([birthday()]);
    expect(data.spansOn(DateTime(2024, 8, 26)), hasLength(1));
    expect(data.spansOn(DateTime(2024, 8, 27)), isEmpty);
  });

  test('Курс виден и в первый день, и в последний', () {
    final course = VEvent(
      id: 'course',
      calendarId: 'study',
      title: 'Летний курс',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 8, 14),
      isAllDay: true,
    );
    final data = range([course]);
    expect(data.spansOn(DateTime(2026, 6, 20)), hasLength(1));
    expect(data.spansOn(DateTime(2026, 7, 15)), hasLength(1));
    expect(data.spansOn(DateTime(2026, 8, 14)), hasLength(1));
    expect(data.spansOn(DateTime(2026, 8, 15)), isEmpty);
  });

  group('Счётчик дня полосы', () {
    test('Однодневная полоса считаться не просит', () {
      expect(spanProgress(holiday(), DateTime(2026, 8, 12)).counted, isFalse);
    });

    test('Будущая полоса не уходит в минус', () {
      final course = VEvent(
        id: 'course',
        calendarId: 'study',
        title: 'Летний курс',
        start: DateTime(2026, 8, 19),
        end: DateTime(2026, 8, 21),
        isAllDay: true,
      );
      final p = spanProgress(course, DateTime(2026, 8, 9));
      expect(p.total, 3);
      expect(p.passed, 1);
    });

    test('Прошедшая полоса не перескакивает свой срок', () {
      final course = VEvent(
        id: 'course',
        calendarId: 'study',
        title: 'Летний курс',
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 3),
        isAllDay: true,
      );
      expect(spanProgress(course, DateTime(2026, 9, 1)).passed, 3);
    });
  });
}

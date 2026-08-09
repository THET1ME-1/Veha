import 'package:flutter_test/flutter_test.dart';
import 'package:rrule/rrule.dart' show Frequency;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:veha/domain/recurrence.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  String d(DateTime x) =>
      '${x.day}.${x.month} ${x.hour.toString().padLeft(2, '0')}:${x.minute.toString().padLeft(2, '0')}';

  group('Разворачивание правила', () {
    test('Каждые 2 недели по понедельникам и четвергам', () {
      final dates = Recurrence.expand(
        rrule: Recurrence.weekly(interval: 2, weekdays: {1, 4}),
        start: DateTime(2026, 7, 27, 16),
        windowStart: DateTime(2026, 7, 27),
        windowEnd: DateTime(2026, 8, 31),
        timezone: 'Europe/Chisinau',
      );
      expect(dates.map(d).toList(), [
        '27.7 16:00',
        '30.7 16:00',
        '10.8 16:00',
        '13.8 16:00',
        '24.8 16:00',
        '27.8 16:00',
      ]);
    });

    test('Чужое начало недели не роняет разворачивание', () {
      // Календари Google и Apple пишут WKST любым днём, а библиотека умеет
      // только понедельник и бросает исключение. Одно такое правило в
      // расписании валило весь экран: развёртка падала, вид не пересчитывался,
      // и удаление события выглядело как «нажал, а оно на месте».
      final dates = Recurrence.expand(
        rrule: 'FREQ=WEEKLY;WKST=TU;UNTIL=20260830T215959Z;BYDAY=MO',
        start: DateTime(2026, 8, 3, 9),
        windowStart: DateTime(2026, 8, 1),
        windowEnd: DateTime(2026, 8, 31),
        timezone: 'Europe/Chisinau',
      );

      expect(dates.map(d).toList(), ['3.8 09:00', '10.8 09:00', '17.8 09:00', '24.8 09:00']);
    });

    test('Ежегодное правило с чужим WKST разворачивается', () {
      final dates = Recurrence.expand(
        rrule: 'FREQ=YEARLY;WKST=SU',
        start: DateTime(2024, 5, 9, 12),
        windowStart: DateTime(2026, 1, 1),
        windowEnd: DateTime(2026, 12, 31),
        timezone: 'Europe/Chisinau',
      );

      expect(dates.map(d).toList(), ['9.5 12:00']);
    });

    test('Последняя пятница месяца', () {
      final dates = Recurrence.expand(
        rrule: Recurrence.monthlyByPosition(weekday: 5, position: -1),
        start: DateTime(2026, 7, 31, 18),
        windowStart: DateTime(2026, 7, 1),
        windowEnd: DateTime(2026, 10, 31),
        timezone: 'Europe/Chisinau',
      );
      expect(dates.map(d).toList(), [
        '31.7 18:00',
        '28.8 18:00',
        '25.9 18:00',
        '30.10 18:00',
      ]);
    });

    test('Пропущенные даты исключаются из ряда', () {
      final dates = Recurrence.expand(
        rrule: Recurrence.weekly(interval: 1, weekdays: {2}),
        start: DateTime(2026, 8, 4, 11),
        windowStart: DateTime(2026, 8, 1),
        windowEnd: DateTime(2026, 8, 31),
        timezone: 'Europe/Chisinau',
        excluded: {DateTime(2026, 8, 11), DateTime(2026, 8, 25)},
      );
      expect(dates.map(d).toList(), ['4.8 11:00', '18.8 11:00']);
    });

    test('Окончание после N повторов', () {
      final dates = Recurrence.expand(
        rrule: Recurrence.weekly(interval: 1, weekdays: {1}, count: 3),
        start: DateTime(2026, 7, 27, 9),
        windowStart: DateTime(2026, 7, 1),
        windowEnd: DateTime(2027, 1, 1),
        timezone: 'Europe/Chisinau',
      );
      expect(dates, hasLength(3));
      expect(d(dates.last), '10.8 09:00');
    });
  });

  group('Перевод часов', () {
    // В Молдове часы переводят в последнее воскресенье марта и октября.
    test('Время события переживает переход на летнее время', () {
      final dates = Recurrence.expand(
        rrule: Recurrence.weekly(interval: 1, weekdays: {1}),
        start: DateTime(2027, 3, 22, 16),
        windowStart: DateTime(2027, 3, 22),
        windowEnd: DateTime(2027, 4, 6),
        timezone: 'Europe/Chisinau',
      );
      // 29 марта 2027 — понедельник после перевода стрелок вперёд.
      expect(dates.map(d).toList(), ['22.3 16:00', '29.3 16:00', '5.4 16:00']);
    });

    test('Время события переживает переход на зимнее время', () {
      final dates = Recurrence.expand(
        rrule: Recurrence.weekly(interval: 1, weekdays: {1}),
        start: DateTime(2026, 10, 19, 16),
        windowStart: DateTime(2026, 10, 19),
        windowEnd: DateTime(2026, 11, 3),
        timezone: 'Europe/Chisinau',
      );
      expect(dates.map(d).toList(), ['19.10 16:00', '26.10 16:00', '2.11 16:00']);
    });
  });

  group('Разрез ряда', () {
    test('Старой половине ставится окончание накануне разреза', () {
      final head = Recurrence.endBefore(
        'FREQ=WEEKLY;BYDAY=MO',
        DateTime(2026, 8, 10, 16),
        start: DateTime(2026, 7, 27, 16),
      );

      final dates = Recurrence.expand(
        rrule: head,
        start: DateTime(2026, 7, 27, 16),
        windowStart: DateTime(2026, 7, 1),
        windowEnd: DateTime(2026, 9, 1),
      );
      expect(dates.map(d).toList(), ['27.7 16:00', '3.8 16:00']);
    });

    test('Счётчик повторов делится между половинами', () {
      // Ряд из шести занятий, разрез перед четвёртым: три и три.
      const rule = 'FREQ=WEEKLY;BYDAY=MO;COUNT=6';
      final start = DateTime(2026, 7, 6, 16);
      final cut = DateTime(2026, 7, 27, 16);

      final head = Recurrence.expand(
        rrule: Recurrence.endBefore(rule, cut, start: start),
        start: start,
        windowStart: DateTime(2026, 7, 1),
        windowEnd: DateTime(2026, 10, 1),
      );
      final tail = Recurrence.expand(
        rrule: Recurrence.cutBefore(rule, cut, start: start),
        start: cut,
        windowStart: DateTime(2026, 7, 1),
        windowEnd: DateTime(2026, 10, 1),
      );

      expect(head, hasLength(3));
      expect(tail, hasLength(3));
    });
  });

  group('Абсолютный момент', () {
    test('Одно и то же настенное время даёт разный UTC летом и зимой', () {
      final summer = Recurrence.absoluteMoment(
          DateTime(2026, 7, 27, 16), 'Europe/Chisinau');
      final winter = Recurrence.absoluteMoment(
          DateTime(2026, 12, 21, 16), 'Europe/Chisinau');

      // Летом Кишинёв UTC+3, зимой UTC+2 — напоминание должно сработать
      // в 16:00 по месту, а не в фиксированный час UTC.
      expect(summer.hour, 13);
      expect(winter.hour, 14);
    });
  });

  group('Разбор правила', () {
    test('Частота, шаг и дни недели', () {
      final shape = Recurrence.shape(
        Recurrence.weekly(interval: 2, weekdays: {1, 4}),
      );

      expect(shape.frequency, Frequency.weekly);
      expect(shape.interval, 2);
      expect(shape.weekdays, [1, 4]);
    });

    test('Позиция дня в месяце', () {
      final last = Recurrence.shape(
        Recurrence.monthlyByPosition(weekday: 5, position: -1),
      );
      expect(last.monthWeekday, 5);
      expect(last.monthPosition, -1);

      final second = Recurrence.shape(
        Recurrence.monthlyByPosition(weekday: 2, position: 2),
      );
      expect(second.monthWeekday, 2);
      expect(second.monthPosition, 2);
    });
  });
}

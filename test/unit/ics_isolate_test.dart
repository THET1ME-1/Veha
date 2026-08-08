import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/ics.dart';

/// Разбор `.ics` в отдельном потоке.
///
/// ТЗ отправляет импорт в изолят, и повод у него простой: годовой календарь
/// из Google — тысячи событий, а разбор в потоке интерфейса держит экран
/// замороженным. Проверяется, что фоновый разбор даёт ровно то же, что
/// обычный: расхождение здесь означало бы два разных импорта в одном
/// приложении.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String bigCalendar(int count) => toIcs(
        [
          for (var i = 0; i < count; i++)
            VEvent(
              id: 'e$i',
              calendarId: 'c1',
              title: 'Занятие $i',
              description: 'Строка описания $i',
              start: DateTime(2026, 1, 1).add(Duration(hours: i)),
              end: DateTime(2026, 1, 1).add(Duration(hours: i + 1)),
            ),
        ],
        stamp: DateTime.utc(2026, 7, 27, 9),
      );

  test('Фоновый разбор совпадает с обычным', () async {
    final text = bigCalendar(50);

    final here = parseIcs(text);
    final there = await parseIcsInBackground(text);

    expect(there.events, hasLength(here.events.length));
    expect(there.events.first.title, here.events.first.title);
    expect(there.events.last.description, here.events.last.description);
  });

  test('Тысяча событий переживает дорогу через изолят', () async {
    final data = await parseIcsInBackground(bigCalendar(1000));

    expect(data.events, hasLength(1000));
    expect(data.events.last.title, 'Занятие 999');
  });
}

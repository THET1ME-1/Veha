import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;

import '../data/models.dart';

/// Обмен с чужими календарями по RFC 5545.
///
/// Свой формат для бэкапа был бы проще, но бесполезен: человек уносит события
/// в Google, Proton или Thunderbird, а они понимают только `.ics`.
///
/// Чего здесь намеренно нет: VALARM (напоминания — дело устройства, а не
/// файла), VTIMEZONE (полное описание правил перевода часов; пояс уходит
/// именем в `TZID`, и все известные разборщики его понимают), участников и
/// вложений — их в модели нет.
const _productId = '-//THET1ME-1//Veha//RU';

/// Разобранный файл: события и определения полей, которых им не хватает.
class IcsData {
  const IcsData({
    required this.events,
    required this.fields,
    this.calendarName,
    this.excluded = const {},
  });

  final List<VEvent> events;

  /// Как календарь подписан в файле (`X-WR-CALNAME`). Свойство нестандартное,
  /// но его пишут все: Google, Proton, Thunderbird и наша же выгрузка. Оно
  /// снимает вопрос «куда класть» с человека.
  final String? calendarName;

  /// Определения своих полей, восстановленные из файла. Без них значение
  /// показать негде: строка «312» без подписи «Кабинет» ничего не значит.
  final List<VFieldDef> fields;

  /// Отменённые занятия ряда (`EXDATE`), по ключу события. Google так
  /// помечает пару, которой не было: неделя аттестаций, каникулы, перенос.
  /// Без них приложение рисует занятие там, где его отменили.
  final Map<String, Set<DateTime>> excluded;

  static const empty = IcsData(events: [], fields: [], excluded: {});
}

/// События в текст `.ics`.
///
/// [defs] нужны, чтобы своё поле пережило круг: в файл уходит не только
/// значение, но имя с типом — иначе на другом устройстве его негде показать.
String toIcs(
  List<VEvent> events, {
  DateTime? stamp,
  Map<String, VFieldDef> defs = const {},
  String? calendarName,
  Map<String, Set<DateTime>> excluded = const {},
}) {
  final out = StringBuffer()
    ..write(_line('BEGIN:VCALENDAR'))
    ..write(_line('VERSION:2.0'))
    ..write(_line('PRODID:$_productId'))
    ..write(_line('CALSCALE:GREGORIAN'));

  // Подпись календаря: на том конце её ждут и Google, и наш же разбор, иначе
  // человека спрашивают, куда класть файл, который сам об этом говорит.
  if (calendarName != null && calendarName.isNotEmpty) {
    out.write(_line('X-WR-CALNAME:${_escape(calendarName)}'));
  }

  final now = _utcStamp(stamp ?? DateTime.now().toUtc());

  for (final e in events) {
    out
      ..write(_line('BEGIN:VEVENT'))
      ..write(_line('UID:${e.id}@veha'))
      ..write(_line('DTSTAMP:$now'))
      ..write(_line('SUMMARY:${_escape(e.title)}'));

    if (e.isAllDay) {
      // Внутри приложения конец — последний день события, в формате он
      // исключающий: занятый один день 13 августа уезжает как 13 → 14.
      out
        ..write(_line('DTSTART;VALUE=DATE:${_date(e.start)}'))
        ..write(_line(
            'DTEND;VALUE=DATE:${_date(e.end.add(const Duration(days: 1)))}'));
    } else {
      out.write(_line('DTSTART;TZID=${e.timezone}:${_dateTime(e.start)}'));
      // У события без окончания DTEND не пишется вовсе — так это и
      // задумано в RFC 5545: одно начало и никакой длительности.
      if (!e.isOpenEnded) {
        out.write(_line('DTEND;TZID=${e.timezone}:${_dateTime(e.end)}'));
      }
    }

    if (e.rrule != null) out.write(_line('RRULE:${e.rrule}'));
    // Отменённые занятия ряда. Без них круг «выгрузил — загрузил» возвращает
    // пары, которых не было: неделя аттестаций снова полна занятий.
    final skips = excluded[e.id];
    if (skips != null && skips.isNotEmpty) {
      final dates = skips.toList()..sort();
      out.write(_line(
        'EXDATE;TZID=${e.timezone}:${dates.map(_dateTime).join(',')}',
      ));
    }
    // Занятость — стандартное свойство: чужой календарь тоже поймёт, что
    // день рождения не держит время.
    out.write(_line(
      'TRANSP:${e.availability == Availability.free ? 'TRANSPARENT' : 'OPAQUE'}',
    ));
    // Описание — обычное свойство календарного формата, а не расширение:
    // чужие календари прочитают его как своё.
    if (e.description != null && e.description!.isNotEmpty) {
      out.write(_line('DESCRIPTION:${_escape(e.description!)}'));
    }
    if (e.location != null) {
      out.write(_line('LOCATION:${_escape(e.location!)}'));
    }

    // Свои поля — расширение с префиксом `X-`: чужой календарь их пропустит
    // мимо, а Veha прочитает обратно вместе с определением.
    for (final f in e.fields) {
      final def = defs[f.fieldId];
      final name = def == null ? '' : ';X-VEHA-NAME="${_param(def.name)}"';
      final type = def == null ? '' : ';X-VEHA-TYPE=${def.type.name}';
      final icon = def == null ? '' : ';X-VEHA-ICON=${def.iconName}';
      out.write(_line(
        'X-VEHA-FIELD;X-VEHA-ID=${f.fieldId}$name$type$icon:${_escape(f.value)}',
      ));
    }

    out.write(_line('END:VEVENT'));
  }

  out.write(_line('END:VCALENDAR'));
  return out.toString();
}

/// Текст `.ics` в события.
///
/// Битый файл даёт пустой список, а не исключение: человек выбрал не тот файл,
/// и сообщать об этом надо интерфейсом, а не крэшем.
/// Тот же разбор, но в отдельном потоке.
///
/// Годовой календарь из Google — это тысячи событий и мегабайты текста.
/// Разбор такого файла в потоке интерфейса держит экран замороженным
/// несколько секунд, и человек в это время думает, что приложение зависло.
///
/// `newId` сюда не передаётся намеренно: функция уезжает в другой поток, а
/// замыкание туда не отправить. Ключи выдаёт разбор по умолчанию.
Future<IcsData> parseIcsInBackground(String text, {String untitled = 'Untitled'}) =>
    compute(_parseIcsTask, (text: text, untitled: untitled));

IcsData _parseIcsTask(({String text, String untitled}) input) =>
    parseIcs(input.text, untitled: input.untitled);

IcsData parseIcs(String text, {String Function()? newId, String untitled = 'Untitled'}) {
  final lines = _unfold(text);
  final out = <VEvent>[];
  final defs = <String, VFieldDef>{};
  final excluded = <String, Set<DateTime>>{};
  var skips = <DateTime>[];

  Map<String, _Prop>? current;
  var fields = <VFieldValue>[];
  var counter = 0;
  String? calendarName;

  for (final line in lines) {
    if (current == null && line.startsWith('X-WR-CALNAME')) {
      final prop = _Prop.parse(line);
      final value = _unescape(prop?.value ?? '').trim();
      if (value.isNotEmpty) calendarName = value;
      continue;
    }
    if (line == 'BEGIN:VEVENT') {
      current = {};
      fields = [];
      skips = [];
      continue;
    }
    if (line == 'END:VEVENT') {
      if (current == null) continue;
      final event = _toEvent(
        current,
        fields,
        id: newId?.call() ?? 'ics-${counter++}',
        untitled: untitled,
      );
      if (event != null) {
        out.add(event);
        if (skips.isNotEmpty) excluded[event.id] = skips.toSet();
      }
      current = null;
      continue;
    }
    if (current == null) continue;

    final prop = _Prop.parse(line);
    if (prop == null) continue;
    // Свойство повторяемое, и значений в нём бывает несколько через запятую:
    // в общую карту `current` оно не ложится — там каждое имя одно.
    if (prop.name == 'EXDATE') {
      for (final part in prop.value.split(',')) {
        final at = _parseMoment(_Prop(prop.name, prop.params, part.trim()));
        if (at != null) skips.add(at);
      }
      continue;
    }
    if (prop.name == 'X-VEHA-FIELD') {
      final id = prop.params['X-VEHA-ID'];
      if (id != null) {
        fields.add(VFieldValue(fieldId: id, value: _unescape(prop.value)));
        final name = prop.params['X-VEHA-NAME'];
        if (name != null) {
          defs[id] = VFieldDef(
            id: id,
            name: name,
            type: VFieldType.values.firstWhere(
              (t) => t.name == prop.params['X-VEHA-TYPE'],
              orElse: () => VFieldType.text,
            ),
            iconName: prop.params['X-VEHA-ICON'] ?? 'text',
          );
        }
      }
      continue;
    }
    current[prop.name] = prop;
  }

  return IcsData(
    events: out,
    fields: defs.values.toList(),
    calendarName: calendarName,
    excluded: excluded,
  );
}

/// Значение параметра в кавычках: запятая и точка с запятой там разделители,
/// а в имени поля они законны («Кабинет, корпус»).
String _param(String value) => value.replaceAll('"', "'");

VEvent? _toEvent(
  Map<String, _Prop> props,
  List<VFieldValue> fields, {
  required String id,
  required String untitled,
}) {
  final start = props['DTSTART'];
  if (start == null) return null;

  final startAt = _parseMoment(start);
  if (startAt == null) return null;

  final allDay = start.params['VALUE'] == 'DATE';
  final endProp = props['DTEND'];
  final endAt = endProp == null ? null : _parseMoment(endProp);

  return VEvent(
    id: id,
    // Календарь назначает тот, кто импортирует: в чужом файле его нет.
    calendarId: '',
    title: _unescape(props['SUMMARY']?.value ?? untitled),
    description: props['DESCRIPTION'] == null
        ? null
        : _unescape(props['DESCRIPTION']!.value),
    start: startAt,
    // Файл без DTEND по RFC 5545 означает событие без длительности —
    // у нас это и есть «без окончания». У события на весь день конец в
    // формате исключающий: 13 → 14 августа означает один занятый день, и
    // без вычета праздник растягивался на две клетки календаря.
    end: allDay
        ? (endAt == null
            ? startAt
            : _atLeast(startAt, endAt.subtract(const Duration(days: 1))))
        : (endAt ?? startAt),
    isAllDay: allDay,
    availability: props['TRANSP']?.value.toUpperCase() == 'TRANSPARENT'
        ? Availability.free
        : Availability.busy,
    rrule: props['RRULE']?.value,
    location: props['LOCATION'] == null
        ? null
        : _unescape(props['LOCATION']!.value),
    timezone: start.params['TZID'] ?? 'UTC',
    fields: fields,
  );
}

DateTime? _parseMoment(_Prop prop) {
  final v = prop.value;
  if (prop.params['VALUE'] == 'DATE' || v.length == 8) {
    final y = int.tryParse(v.substring(0, 4));
    final m = int.tryParse(v.substring(4, 6));
    final d = int.tryParse(v.substring(6, 8));
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
  if (v.length < 15) return null;

  final y = int.tryParse(v.substring(0, 4));
  final mo = int.tryParse(v.substring(4, 6));
  final d = int.tryParse(v.substring(6, 8));
  final h = int.tryParse(v.substring(9, 11));
  final mi = int.tryParse(v.substring(11, 13));
  final s = int.tryParse(v.substring(13, 15));
  if ([y, mo, d, h, mi, s].contains(null)) return null;

  // Хвостовая Z означает UTC. Без неё время «настенное»: пояс приезжает
  // отдельным параметром, а сам момент трогать нельзя.
  return v.endsWith('Z')
      ? DateTime.utc(y!, mo!, d!, h!, mi!, s!).toLocal()
      : DateTime(y!, mo!, d!, h!, mi!, s!);
}

/// Свойство строки: имя, параметры и значение.
class _Prop {
  const _Prop(this.name, this.params, this.value);

  final String name;
  final Map<String, String> params;
  final String value;

  static _Prop? parse(String line) {
    // Двоеточие внутри значения встречается сплошь и рядом («LOCATION:г. Х:5»),
    // поэтому режем по первому, и только за пределами кавычек.
    var colon = -1;
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') quoted = !quoted;
      if (c == ':' && !quoted) {
        colon = i;
        break;
      }
    }
    if (colon <= 0) return null;

    final head = line.substring(0, colon);
    final value = line.substring(colon + 1);
    final parts = head.split(';');
    final params = <String, String>{};

    for (final p in parts.skip(1)) {
      final eq = p.indexOf('=');
      if (eq <= 0) continue;
      params[p.substring(0, eq).toUpperCase()] =
          p.substring(eq + 1).replaceAll('"', '');
    }
    return _Prop(parts.first.toUpperCase(), params, value);
  }
}

/// Складывание длинных строк. Считать надо октеты, а не символы: кириллица в
/// UTF-8 занимает по два байта, и по символам строка вылезет за предел вдвое.
String _line(String value) {
  final bytes = utf8.encode(value);
  if (bytes.length <= 75) return '$value\r\n';

  final out = StringBuffer();
  var start = 0;
  var limit = 75;

  while (start < bytes.length) {
    var end = start + limit;
    if (end >= bytes.length) {
      end = bytes.length;
    } else {
      // Резать посреди многобайтового символа нельзя: продолжения начинаются
      // с битов 10xxxxxx, отступаем до начала символа.
      while (end > start && (bytes[end] & 0xC0) == 0x80) {
        end--;
      }
    }
    final chunk = utf8.decode(bytes.sublist(start, end));
    out.write(start == 0 ? chunk : ' $chunk');
    out.write('\r\n');
    start = end;
    // У продолжения первый октет занят пробелом.
    limit = 74;
  }
  return out.toString();
}

/// Склейка сложенных строк обратно.
List<String> _unfold(String text) {
  final out = <String>[];
  for (final raw in text.split('\n')) {
    final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
    if (line.isEmpty) continue;
    if ((line.startsWith(' ') || line.startsWith('\t')) && out.isNotEmpty) {
      out[out.length - 1] = out.last + line.substring(1);
    } else {
      out.add(line);
    }
  }
  return out;
}

/// Конец не раньше начала: чужой файл может прислать DTEND тем же днём, что и
/// DTSTART, и вычет суток увёл бы событие в прошлое.
DateTime _atLeast(DateTime start, DateTime end) =>
    end.isBefore(start) ? start : end;

String _escape(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('\n', '\\n')
    .replaceAll(',', '\\,')
    .replaceAll(';', '\\;');

String _unescape(String value) {
  final out = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    if (value[i] != '\\' || i + 1 >= value.length) {
      out.write(value[i]);
      continue;
    }
    final next = value[++i];
    out.write(switch (next) {
      'n' || 'N' => '\n',
      '\\' => '\\',
      ',' => ',',
      ';' => ';',
      _ => next,
    });
  }
  return out.toString();
}

String _two(int v) => v.toString().padLeft(2, '0');

String _date(DateTime d) => '${d.year}${_two(d.month)}${_two(d.day)}';

String _dateTime(DateTime d) =>
    '${_date(d)}T${_two(d.hour)}${_two(d.minute)}${_two(d.second)}';

String _utcStamp(DateTime d) => '${_dateTime(d.toUtc())}Z';

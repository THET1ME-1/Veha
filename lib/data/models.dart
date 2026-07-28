import 'package:flutter/material.dart';

/// Календарь — верхний уровень группировки и цвета.
@immutable
class VCalendar {
  const VCalendar({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.isVisible = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String iconName;
  final Color color;
  final bool isVisible;
  final int sortOrder;
}

/// Ветка внутри календаря: «Учёба» дробится на английский, курсы, экзамены.
/// Цвет и иконка необязательны — `null` означает «взять у календаря».
@immutable
class VSubcategory {
  const VSubcategory({
    required this.id,
    required this.calendarId,
    required this.name,
    this.iconName,
    this.color,
    this.sortOrder = 0,
  });

  final String id;
  final String calendarId;
  final String name;
  final String? iconName;
  final Color? color;
  final int sortOrder;
}

/// Значение своего поля в конкретном событии.
@immutable
class VFieldValue {
  const VFieldValue({required this.fieldId, required this.value});

  final String fieldId;
  final String value;

  /// Сравнение по содержимому: одно и то же значение приезжает из базы
  /// несколько раз, когда запрос собирает поля вместе с исключениями ряда.
  @override
  bool operator ==(Object other) =>
      other is VFieldValue && other.fieldId == fieldId && other.value == value;

  @override
  int get hashCode => Object.hash(fieldId, value);
}

/// Метка «поле не передавали». Без неё `copyWith(color: null)` не отличить от
/// «оставь как было», а стереть свой цвет события нужно уметь.
const Object _keep = Object();

@immutable
class VEvent {
  const VEvent({
    required this.id,
    required this.calendarId,
    required this.title,
    required this.start,
    required this.end,
    this.subcategoryId,
    this.color,
    this.iconName,
    this.isAllDay = false,
    this.rrule,
    this.recurrenceId,
    this.originalStart,
    this.isVirtual = false,
    this.timezone = 'Europe/Chisinau',
    this.location,
    this.fields = const [],
    this.reminders = const [],
  });

  final String id;
  final String calendarId;
  final String? subcategoryId;
  final String title;
  final DateTime start;
  final DateTime end;
  final Color? color;
  final String? iconName;
  final bool isAllDay;

  /// Правило повторения по RFC 5545. Подпись для карточки строится из него
  /// на лету: хранить её отдельной строкой нельзя — правило поменяется,
  /// а подпись останется старой и будет врать.
  final String? rrule;

  /// Ряд, из которого выломан этот экземпляр. Занятие перенесли с 16:00 на
  /// 18:00 — в базе появляется отдельная строка с `recurrenceId` ряда и
  /// [originalStart] на месте старого времени: по ней развёртка понимает,
  /// какой виртуальный экземпляр заменить.
  ///
  /// У виртуальных экземпляров поле тоже заполнено — им нужен обратный путь
  /// к записи ряда, у которой они забрали `id`.
  final String? recurrenceId;

  /// Время, на котором экземпляр стоял в ряду до правки.
  final DateTime? originalStart;

  /// Экземпляр ряда, а не самостоятельное событие.
  bool get isOccurrence => recurrenceId != null;

  /// За сколько минут до начала предупредить. Список, а не одно число:
  /// «за день» и «за десять минут» отвечают на разные вопросы — успеть
  /// подготовиться и успеть дойти.
  final List<int> reminders;

  /// Экземпляр, рождённый развёрткой: своей строки в базе у него нет.
  /// Правка такого экземпляра выламывает его из ряда отдельной записью,
  /// а не переписывает ряд целиком.
  final bool isVirtual;

  VEvent copyWith({
    String? title,
    DateTime? start,
    DateTime? end,
    Object? color = _keep,
    Object? iconName = _keep,
    bool? isAllDay,
    Object? rrule = _keep,
    Object? location = _keep,
    List<VFieldValue>? fields,
    List<int>? reminders,
  }) =>
      VEvent(
        id: id,
        calendarId: calendarId,
        subcategoryId: subcategoryId,
        title: title ?? this.title,
        start: start ?? this.start,
        end: end ?? this.end,
        color: color == _keep ? this.color : color as Color?,
        iconName: iconName == _keep ? this.iconName : iconName as String?,
        isAllDay: isAllDay ?? this.isAllDay,
        rrule: rrule == _keep ? this.rrule : rrule as String?,
        recurrenceId: recurrenceId,
        originalStart: originalStart,
        isVirtual: isVirtual,
        timezone: timezone,
        location: location == _keep ? this.location : location as String?,
        fields: fields ?? this.fields,
        reminders: reminders ?? this.reminders,
      );

  /// Пояс события, IANA. Нужен для абсолютного момента напоминания:
  /// 16:00 в Кишинёве — разный UTC летом и зимой.
  final String timezone;
  final String? location;
  final List<VFieldValue> fields;

  Duration get duration => end.difference(start);

  /// Событие длиннее суток не рисуется в сетке часов: у него своё место —
  /// полоса над таймлайном, лента в неделе и месяце.
  bool get isMultiDay =>
      duration.inHours >= 24 ||
      (isAllDay && !_sameDay(start, end));

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Заметка внутри события — четвёртый уровень цвета.
@immutable
class VNote {
  const VNote({
    required this.id,
    required this.eventId,
    required this.text,
    this.color,
    this.sortOrder = 0,
  });

  final String id;
  final String eventId;
  final String text;
  final Color? color;
  final int sortOrder;
}

enum VFieldType { text, number, date, time, duration, select, checkbox, url, phone, person, money }

extension VFieldTypeLabel on VFieldType {
  String get label => switch (this) {
        VFieldType.text => 'Текст',
        VFieldType.number => 'Число',
        VFieldType.date => 'Дата',
        VFieldType.time => 'Время',
        VFieldType.duration => 'Длительность',
        VFieldType.select => 'Список',
        VFieldType.checkbox => 'Флажок',
        VFieldType.url => 'Ссылка',
        VFieldType.phone => 'Телефон',
        VFieldType.person => 'Человек',
        VFieldType.money => 'Деньги',
      };
}

/// Определение своего поля. Принадлежит группе, а не всем событиям сразу:
/// номер карты нужен абонементу и не нужен уроку английского.
@immutable
class VFieldDef {
  const VFieldDef({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    this.calendarId,
    this.showInCard = false,
    this.isBuiltIn = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final VFieldType type;
  final String iconName;

  /// `null` — общее поле, достаётся всем событиям.
  final String? calendarId;
  final bool showInCard;
  final bool isBuiltIn;
  final int sortOrder;
}

/// Разрешение цвета и иконки по цепочке наследования.
///
/// Заметка → событие → ветка → календарь. На каждом уровне `null` означает
/// «взять уровнем выше», а не скопированное вниз значение: перекрасил
/// календарь — перекрасилось всё, что не переопределяли руками.
class Inheritance {
  const Inheritance({
    required this.calendars,
    required this.subcategories,
  });

  final Map<String, VCalendar> calendars;
  final Map<String, VSubcategory> subcategories;

  Color colorOfEvent(VEvent e) {
    if (e.color != null) return e.color!;
    final sub = e.subcategoryId == null ? null : subcategories[e.subcategoryId];
    if (sub?.color != null) return sub!.color!;
    return calendars[e.calendarId]?.color ?? const Color(0xFF41CCB5);
  }

  Color colorOfNote(VNote n, VEvent e) => n.color ?? colorOfEvent(e);

  String iconOfEvent(VEvent e) {
    if (e.iconName != null) return e.iconName!;
    final sub = e.subcategoryId == null ? null : subcategories[e.subcategoryId];
    if (sub?.iconName != null) return sub!.iconName!;
    return calendars[e.calendarId]?.iconName ?? 'calendar';
  }

  Color colorOfSubcategory(VSubcategory s) =>
      s.color ?? calendars[s.calendarId]?.color ?? const Color(0xFF41CCB5);

  /// Откуда взят цвет ветки — для плашки «наследует / свой».
  bool subcategoryHasOwnColor(VSubcategory s) => s.color != null;
}

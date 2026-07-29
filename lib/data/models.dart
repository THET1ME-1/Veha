import 'package:flutter/material.dart';

import '../core/app_timezone.dart';

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
    this.defaultReminders,
    this.defaultDuration,
  });

  final String id;
  final String name;
  final String iconName;
  final Color color;
  final bool isVisible;
  final int sortOrder;

  /// Напоминания по умолчанию, минуты до начала.
  ///
  /// `null` — не настраивали, событие возьмёт обычные полчаса. Пустой список —
  /// календарь молчит намеренно: у «Распорядка» будильник на каждый подъём
  /// не нужен. Различать эти два случая обязательно, иначе «выключил
  /// напоминания» на следующем событии превращается в «включил заново».
  final List<int>? defaultReminders;

  /// Длительность нового события в этом календаре. Пусто — час.
  final Duration? defaultDuration;
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
  // Не `const`: пояс по умолчанию берётся у устройства, а системный вызов
  // константой быть не может.
  VEvent({
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
    String? timezone,
    this.location,
    this.travelMinutes = 0,
    this.fields = const [],
    this.reminders = const [],
  }) : timezone = timezone ?? AppTimezone.current;

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

  /// Сколько добираться до места, в минутах. Ноль — дорога не в счёт.
  ///
  /// Полчаса пути — это занятые полчаса: календарь, который считает
  /// свободным время прямо перед встречей на другом конце города, врёт.
  /// Само событие при этом остаётся на своём часе — дорога не сдвигает его,
  /// а только занимает время перед ним.
  final int travelMinutes;

  /// С какого момента человек занят: с выхода из дома, а не с начала встречи.
  DateTime get busyFrom =>
      travelMinutes <= 0 ? start : start.subtract(Duration(minutes: travelMinutes));

  VEvent copyWith({
    String? title,
    DateTime? start,
    DateTime? end,
    Object? color = _keep,
    Object? iconName = _keep,
    bool? isAllDay,
    Object? rrule = _keep,
    Object? location = _keep,
    int? travelMinutes,
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
        travelMinutes: travelMinutes ?? this.travelMinutes,
        fields: fields ?? this.fields,
        reminders: reminders ?? this.reminders,
      );

  /// Пояс события, IANA. Нужен для абсолютного момента напоминания:
  /// 16:00 в Кишинёве — разный UTC летом и зимой. По умолчанию пояс
  /// устройства: зашитый чужой — тихая ошибка у всех, кроме автора.
  final String timezone;
  final String? location;
  final List<VFieldValue> fields;

  Duration get duration => end.difference(start);

  /// Событие без времени окончания: «зашёл в мастерскую», «сел писать».
  ///
  /// Отдельного поля в схеме нет намеренно: конец, равный началу, и означает
  /// «неизвестно», а флаг ради двух дат стоил бы миграции на клиенте и на
  /// сервере. В сетке такое событие занимает минимальную высоту и никого не
  /// загораживает — времени за ним не числится.
  bool get isOpenEnded => !end.isAfter(start);

  /// Событие длиннее суток не рисуется в сетке часов: у него своё место —
  /// полоса над таймлайном, лента в неделе и месяце.
  bool get isMultiDay =>
      duration.inHours >= 24 ||
      (isAllDay && !_sameDay(start, end));

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Что у события меняли.
enum RevisionKind {
  created,
  title,
  time,
  calendar,
  place,
  look,
  repeat,
  reminders,
}

/// Одна правка события: что поменялось, когда и на что.
///
/// Журнал местный, на сервер не уезжает: там хранятся записи, а история
/// правок — память устройства.
@immutable
class VRevision {
  const VRevision({
    required this.id,
    required this.eventId,
    required this.at,
    required this.kind,
    this.before,
    this.after,
  });

  final String id;
  final String eventId;
  final DateTime at;
  final RevisionKind kind;

  /// Как было и как стало. У «событие завели» обе стороны пустые.
  final String? before;
  final String? after;
}

/// Файл, приложенный к событию.
@immutable
class VFile {
  const VFile({
    required this.id,
    required this.eventId,
    required this.path,
    required this.name,
    required this.size,
    required this.addedAt,
  });

  final String id;
  final String eventId;

  /// Путь относительный от папки приложения: абсолютный протухает после
  /// переустановки.
  final String path;
  final String name;
  final int size;
  final DateTime addedAt;
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

/// Снимок события. [path] относительный: абсолютный путь протухает после
/// переустановки, а папка приложения переезжает вместе с данными.
@immutable
class VPhoto {
  const VPhoto({
    required this.id,
    required this.eventId,
    required this.path,
    this.sortOrder = 0,
  });

  final String id;
  final String eventId;
  final String path;
  final int sortOrder;
}

/// Задача. Событие либо состоялось, либо нет, а задачу закрывают — поэтому
/// отметка выполнения есть здесь и её нет у события.
@immutable
class VTask {
  const VTask({
    required this.id,
    required this.calendarId,
    required this.title,
    this.subcategoryId,
    this.notes,
    this.due,
    this.hasTime = false,
    this.completedAt,
    this.color,
    this.iconName,
    this.sortOrder = 0,
  });

  final String id;
  final String calendarId;
  final String? subcategoryId;
  final String title;
  final String? notes;

  /// Срок. Пустой — задача живёт в списке и в календаре не показывается.
  final DateTime? due;

  /// У срока названо время, а не только день.
  final bool hasTime;
  final DateTime? completedAt;
  final Color? color;
  final String? iconName;
  final int sortOrder;

  bool get isDone => completedAt != null;

  /// Просрочена: срок в прошлом, а отметки нет.
  bool isOverdue(DateTime now) =>
      due != null && completedAt == null && due!.isBefore(now);

  VTask copyWith({
    String? calendarId,
    Object? subcategoryId = _keep,
    String? title,
    Object? notes = _keep,
    Object? due = _keep,
    bool? hasTime,
    Object? completedAt = _keep,
    Object? color = _keep,
    Object? iconName = _keep,
    int? sortOrder,
  }) =>
      VTask(
        id: id,
        calendarId: calendarId ?? this.calendarId,
        subcategoryId: identical(subcategoryId, _keep)
            ? this.subcategoryId
            : subcategoryId as String?,
        title: title ?? this.title,
        notes: identical(notes, _keep) ? this.notes : notes as String?,
        due: identical(due, _keep) ? this.due : due as DateTime?,
        hasTime: hasTime ?? this.hasTime,
        completedAt: identical(completedAt, _keep)
            ? this.completedAt
            : completedAt as DateTime?,
        color: identical(color, _keep) ? this.color : color as Color?,
        iconName:
            identical(iconName, _keep) ? this.iconName : iconName as String?,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}

enum VFieldType { text, number, date, time, duration, select, checkbox, url, phone, person, money }


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

  Color colorOfTask(VTask t) {
    if (t.color != null) return t.color!;
    final sub = t.subcategoryId == null ? null : subcategories[t.subcategoryId];
    if (sub?.color != null) return sub!.color!;
    return calendars[t.calendarId]?.color ?? const Color(0xFF41CCB5);
  }

  String iconOfTask(VTask t) {
    if (t.iconName != null) return t.iconName!;
    final sub = t.subcategoryId == null ? null : subcategories[t.subcategoryId];
    if (sub?.iconName != null) return sub!.iconName!;
    return calendars[t.calendarId]?.iconName ?? 'check';
  }

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

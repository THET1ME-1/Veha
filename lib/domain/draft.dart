import 'package:flutter/material.dart' show Color, immutable;

import '../data/models.dart';

/// Черновик события: то, что человек набрал, но ещё не сохранил.
///
/// Отдельная сущность нужна затем, что быстрый лист и полная форма правят один
/// и тот же черновик. Переход «быстро → подробно» ничего не теряет, потому что
/// терять нечего: обе формы держат этот объект.
@immutable
class EventDraft {
  const EventDraft({
    required this.calendarId,
    required this.start,
    required this.end,
    this.title = '',
    this.subcategoryId,
    this.color,
    this.iconName,
    this.rrule,
    this.location,
    this.isAllDay = false,
    this.reminders = const [30],
    this.fields = const [],
    this.source,
  });

  /// Пустой черновик по кнопке: ближайший круглый час впереди.
  /// Половина событий заводится «на сейчас», и 9:41 в поле времени человеку
  /// приходится править всегда, а 10:00 — почти никогда.
  factory EventDraft.blank({required DateTime now, required String calendarId}) {
    final hour = DateTime(now.year, now.month, now.day, now.hour)
        .add(const Duration(hours: 1));
    return EventDraft.at(hour, calendarId: calendarId);
  }

  /// Черновик от тапа по свободному часу.
  factory EventDraft.at(DateTime start, {required String calendarId}) =>
      EventDraft(
        calendarId: calendarId,
        start: start,
        end: start.add(const Duration(hours: 1)),
      );

  /// Черновик правки: помнит событие, из которого вырос, включая связь с рядом.
  factory EventDraft.of(VEvent e) => EventDraft(
        calendarId: e.calendarId,
        start: e.start,
        end: e.end,
        title: e.title,
        subcategoryId: e.subcategoryId,
        color: e.color,
        iconName: e.iconName,
        rrule: e.rrule,
        location: e.location,
        isAllDay: e.isAllDay,
        reminders: e.reminders,
        fields: e.fields,
        source: e,
      );

  final String calendarId;
  final DateTime start;
  final DateTime end;
  final String title;
  final String? subcategoryId;
  final Color? color;
  final String? iconName;
  final String? rrule;
  final String? location;
  final bool isAllDay;

  /// За сколько минут предупредить. У нового события одно напоминание за
  /// полчаса: событие, о котором не напомнили, человек пропускает, а лишний
  /// сигнал он снимет сам.
  final List<int> reminders;

  /// Заполненные свои поля. Пустое значение сюда не кладём: поле без текста
  /// и отсутствующее поле — одно и то же.
  final List<VFieldValue> fields;

  /// Событие, которое правят. `null` — черновик нового события.
  final VEvent? source;

  bool get isEditing => source != null;
  bool get isReady => title.trim().isNotEmpty;
  Duration get duration => end.difference(start);

  /// Правка ряда: у экземпляра спрашиваем, что менять, у разового события —
  /// нет, спрашивать не о чем.
  bool get needsScopeQuestion => source?.isOccurrence ?? false;

  EventDraft withTitle(String value) => _copy(title: value);

  /// Длительность тянет конец, начало стоит на месте.
  EventDraft withDuration(Duration value) => _copy(end: start.add(value));

  /// Перенос начала тянет за собой конец: человек двигает событие целиком,
  /// а не растягивает его.
  EventDraft withStart(DateTime value) =>
      _copy(start: value, end: value.add(duration));

  EventDraft withEnd(DateTime value) => _copy(end: value);
  EventDraft withCalendar(String id, {String? subcategoryId}) =>
      _copy(calendarId: id, subcategoryId: subcategoryId, dropSubcategory: true);
  EventDraft withSubcategory(String? id) =>
      _copy(subcategoryId: id, dropSubcategory: id == null);
  EventDraft withRrule(String? value) =>
      _copy(rrule: value, dropRrule: value == null);
  EventDraft withLocation(String? value) =>
      _copy(location: value, dropLocation: value == null);
  EventDraft withIcon(String? value) =>
      _copy(iconName: value, dropIcon: value == null);
  EventDraft withColor(Color? value) => _copy(color: value, dropColor: value == null);
  EventDraft withAllDay(bool value) => _copy(isAllDay: value);
  EventDraft withReminders(List<int> value) => _copy(reminders: value);

  /// Значение своего поля. Пустая строка стирает поле целиком.
  EventDraft withField(String fieldId, String value) {
    final rest = [...fields.where((f) => f.fieldId != fieldId)];
    if (value.trim().isNotEmpty) {
      rest.add(VFieldValue(fieldId: fieldId, value: value.trim()));
    }
    return _copy(fields: rest);
  }

  String? fieldValue(String fieldId) {
    for (final f in fields) {
      if (f.fieldId == fieldId) return f.value;
    }
    return null;
  }

  /// Готовое событие. Новому выдаётся ключ, правка сохраняет свой — вместе с
  /// пометкой «экземпляр ряда», по которой репозиторий решает, писать в ряд
  /// или выламывать занятие.
  VEvent toEvent({required String Function() newId}) => VEvent(
        id: source?.id ?? newId(),
        calendarId: calendarId,
        subcategoryId: subcategoryId,
        title: title.trim(),
        start: start,
        end: end,
        color: color,
        iconName: iconName,
        isAllDay: isAllDay,
        rrule: rrule,
        recurrenceId: source?.recurrenceId,
        originalStart: source?.originalStart,
        isVirtual: source?.isVirtual ?? false,
        timezone: source?.timezone,
        location: location,
        fields: fields,
        reminders: reminders,
      );

  EventDraft _copy({
    String? calendarId,
    DateTime? start,
    DateTime? end,
    String? title,
    String? subcategoryId,
    Color? color,
    String? iconName,
    String? rrule,
    String? location,
    bool? isAllDay,
    List<int>? reminders,
    List<VFieldValue>? fields,
    bool dropSubcategory = false,
    bool dropColor = false,
    bool dropIcon = false,
    bool dropRrule = false,
    bool dropLocation = false,
  }) =>
      EventDraft(
        calendarId: calendarId ?? this.calendarId,
        start: start ?? this.start,
        end: end ?? this.end,
        title: title ?? this.title,
        subcategoryId:
            dropSubcategory ? subcategoryId : subcategoryId ?? this.subcategoryId,
        color: dropColor ? color : color ?? this.color,
        iconName: dropIcon ? iconName : iconName ?? this.iconName,
        rrule: dropRrule ? rrule : rrule ?? this.rrule,
        location: dropLocation ? location : location ?? this.location,
        isAllDay: isAllDay ?? this.isAllDay,
        reminders: reminders ?? this.reminders,
        fields: fields ?? this.fields,
        source: source,
      );
}

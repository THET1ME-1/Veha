import 'package:flutter/material.dart';

import 'models.dart';

/// Демонстрационные данные ровно из макета: понедельник 27 июля 2026.
/// Пока база не подключена, экраны читают отсюда — так вёрстку видно сразу,
/// и её можно сверять с макетом, не дожидаясь миграций.
class Seed {
  Seed._();

  static final DateTime today = DateTime(2026, 7, 27);

  static const mint = Color(0xFF41CCB5);
  static const ocean = Color(0xFF3B7DD8);
  static const moss = Color(0xFF4C9A5B);
  static const amber = Color(0xFFE0A93B);
  static const plum = Color(0xFF8E5CC4);
  static const clay = Color(0xFFB4694A);

  static const calendars = <VCalendar>[
    VCalendar(id: 'c-study', name: 'Учёба', iconName: 'school', color: plum, sortOrder: 0),
    VCalendar(id: 'c-sport', name: 'Спорт', iconName: 'fitness', color: moss, sortOrder: 1),
    VCalendar(id: 'c-work', name: 'Работа', iconName: 'groups', color: ocean, sortOrder: 2),
    VCalendar(id: 'c-home', name: 'Личное', iconName: 'restaurant', color: clay, sortOrder: 3),
    VCalendar(id: 'c-day', name: 'Распорядок', iconName: 'alarm', color: mint, sortOrder: 4),
  ];

  static const subcategories = <VSubcategory>[
    VSubcategory(id: 's-eng', calendarId: 'c-study', name: 'Английский', iconName: 'school'),
    VSubcategory(id: 's-exam', calendarId: 'c-study', name: 'Экзамены', iconName: 'exam', color: ocean),
    VSubcategory(id: 's-course', calendarId: 'c-study', name: 'Курсы', iconName: 'text'),
    VSubcategory(id: 's-pool', calendarId: 'c-sport', name: 'Бассейн', iconName: 'pool', color: mint),
    VSubcategory(id: 's-gym', calendarId: 'c-sport', name: 'Зал', iconName: 'fitness'),
  ];

  static Inheritance get inheritance => Inheritance(
        calendars: {for (final c in calendars) c.id: c},
        subcategories: {for (final s in subcategories) s.id: s},
      );

  static DateTime _at(int day, int hour, [int minute = 0]) =>
      DateTime(2026, 7, day, hour, minute);

  /// События понедельника 27 июля.
  static final List<VEvent> dayEvents = [
    VEvent(
      id: 'e-wake',
      calendarId: 'c-day',
      title: 'Подъём',
      iconName: 'alarm',
      start: _at(27, 7, 30),
      end: _at(27, 7, 45),
      recurrenceLabel: 'каждый день',
    ),
    VEvent(
      id: 'e-fit',
      calendarId: 'c-sport',
      subcategoryId: 's-gym',
      title: 'Зарядка',
      iconName: 'fitness',
      start: _at(27, 8),
      end: _at(27, 8, 45),
    ),
    VEvent(
      id: 'e-breakfast',
      calendarId: 'c-home',
      title: 'Завтрак',
      iconName: 'coffee',
      color: amber,
      start: _at(27, 9),
      end: _at(27, 9, 30),
    ),
    VEvent(
      id: 'e-standup',
      calendarId: 'c-work',
      title: 'Планёрка',
      iconName: 'groups',
      start: _at(27, 10),
      end: _at(27, 11, 30),
      fields: const [
        VFieldValue(fieldId: 'f-people', value: '4'),
        VFieldValue(fieldId: 'f-calendar', value: 'Работа'),
      ],
    ),
    VEvent(
      id: 'e-lunch',
      calendarId: 'c-home',
      title: 'Обед с Ниной',
      iconName: 'restaurant',
      start: _at(27, 13),
      end: _at(27, 14),
      location: 'Кофейня на Штефана',
    ),
    VEvent(
      id: 'e-eng',
      calendarId: 'c-study',
      subcategoryId: 's-eng',
      title: 'Английский',
      iconName: 'school',
      start: _at(27, 16),
      end: _at(27, 17),
      recurrenceLabel: 'по пн и чт',
      location: 'Языковой центр, Бэнулеску-Бодони 45',
      fields: const [
        VFieldValue(fieldId: 'f-room', value: '312'),
        VFieldValue(fieldId: 'f-teacher', value: 'Мария Л.'),
      ],
    ),
    VEvent(
      id: 'e-pool',
      calendarId: 'c-sport',
      subcategoryId: 's-pool',
      title: 'Бассейн',
      iconName: 'pool',
      start: _at(27, 19),
      end: _at(27, 20, 30),
    ),
  ];

  /// События длиннее суток: у них своё место над таймлайном.
  static final List<VEvent> spans = [
    VEvent(
      id: 'e-pass',
      calendarId: 'c-sport',
      subcategoryId: 's-pool',
      title: 'Абонемент в бассейн',
      iconName: 'ticket',
      isAllDay: true,
      start: DateTime(2026, 7, 16),
      end: DateTime(2026, 8, 14),
    ),
    VEvent(
      id: 'e-course',
      calendarId: 'c-study',
      subcategoryId: 's-course',
      title: 'Летний курс',
      iconName: 'school',
      isAllDay: true,
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 8, 14),
    ),
  ];

  static const fields = <VFieldDef>[
    VFieldDef(id: 'f-repeat', name: 'Повтор', type: VFieldType.text, iconName: 'repeat', isBuiltIn: true, showInCard: true, sortOrder: 0),
    VFieldDef(id: 'f-room', name: 'Кабинет', type: VFieldType.text, iconName: 'door', calendarId: 'c-study', showInCard: true, sortOrder: 1),
    VFieldDef(id: 'f-teacher', name: 'Преподаватель', type: VFieldType.person, iconName: 'person', calendarId: 'c-study', showInCard: true, sortOrder: 2),
    VFieldDef(id: 'f-pass', name: 'Абонемент', type: VFieldType.number, iconName: 'ticket', calendarId: 'c-study', sortOrder: 3),
    VFieldDef(id: 'f-paid', name: 'Оплачено', type: VFieldType.checkbox, iconName: 'toggle', calendarId: 'c-study', sortOrder: 4),
    VFieldDef(id: 'f-place', name: 'Место', type: VFieldType.text, iconName: 'place', isBuiltIn: true, sortOrder: 5),
  ];
}

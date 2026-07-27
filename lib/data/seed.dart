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
    // Накладка на планёрку: пересечения — самое хрупкое место раскладки,
    // и в данных для сверки оно должно быть.
    VEvent(
      id: 'e-lesson',
      calendarId: 'c-study',
      subcategoryId: 's-eng',
      title: 'Урок',
      iconName: 'school',
      start: _at(27, 10, 30),
      end: _at(27, 11, 30),
      fields: const [VFieldValue(fieldId: 'f-room', value: '312')],
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

  /// События соседних дней — для ленты дней и недели.
  /// Ключ: день июля, для августа отрицательное смещение не нужно, там свои.
  static final Map<DateTime, List<VEvent>> byDay = {
    DateTime(2026, 7, 27): dayEvents,
    DateTime(2026, 7, 28): [
      VEvent(id: 'e28-1', calendarId: 'c-day', title: 'Подъём', iconName: 'alarm',
          start: _at(28, 7, 30), end: _at(28, 7, 45)),
      VEvent(id: 'e28-2', calendarId: 'c-study', subcategoryId: 's-exam',
          title: 'Экзамен', iconName: 'exam', start: _at(28, 11), end: _at(28, 13)),
      VEvent(id: 'e28-3', calendarId: 'c-home', title: 'Кофе', iconName: 'coffee',
          color: amber, start: _at(28, 15), end: _at(28, 16)),
    ],
    DateTime(2026, 7, 29): [
      VEvent(id: 'e29-1', calendarId: 'c-sport', subcategoryId: 's-gym',
          title: 'Зал', iconName: 'fitness', start: _at(29, 8), end: _at(29, 9, 30)),
      VEvent(id: 'e29-2', calendarId: 'c-work', title: 'Планёрка', iconName: 'groups',
          start: _at(29, 12), end: _at(29, 13)),
      VEvent(id: 'e29-3', calendarId: 'c-sport', subcategoryId: 's-pool',
          title: 'Бассейн', iconName: 'pool', start: _at(29, 19), end: _at(29, 20, 30)),
    ],
    DateTime(2026, 7, 30): [
      VEvent(id: 'e30-1', calendarId: 'c-work', title: 'Планёрка', iconName: 'groups',
          start: _at(30, 10), end: _at(30, 11, 30)),
      VEvent(id: 'e30-2', calendarId: 'c-study', subcategoryId: 's-eng',
          title: 'Английский', iconName: 'school', start: _at(30, 16), end: _at(30, 17),
          recurrenceLabel: 'по пн и чт'),
    ],
    DateTime(2026, 7, 31): [
      VEvent(id: 'e31-1', calendarId: 'c-home', title: 'Обед с Ниной',
          iconName: 'restaurant', start: _at(31, 13), end: _at(31, 14)),
      VEvent(id: 'e31-2', calendarId: 'c-sport', subcategoryId: 's-pool',
          title: 'Бассейн', iconName: 'pool', start: _at(31, 19), end: _at(31, 20, 30)),
    ],
    DateTime(2026, 8, 1): [
      VEvent(id: 'e81-1', calendarId: 'c-sport', subcategoryId: 's-pool',
          title: 'Бассейн', iconName: 'pool',
          start: DateTime(2026, 8, 1, 11), end: DateTime(2026, 8, 1, 12, 30)),
    ],
    // Пустой день оставлен намеренно: лента должна честно говорить, что он
    // пустой, а не притворяться занятой.
    DateTime(2026, 8, 2): [],
  };

  static List<VEvent> eventsOn(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final exact = byDay[key];
    if (exact != null) return exact;
    return _generated(key);
  }

  /// Остальные дни месяца заполняются детерминированно, по номеру дня.
  /// Случайность здесь недопустима: снимок экрана должен совпадать между
  /// прогонами, иначе сверять его с макетом бессмысленно.
  static final Map<DateTime, List<VEvent>> _cache = {};

  static List<VEvent> _generated(DateTime day) {
    return _cache.putIfAbsent(day, () {
      const plan = <List<(String, String, String, int, int)>>[
        [('c-work', 'Планёрка', 'groups', 10, 90), ('c-home', 'Завтрак', 'coffee', 9, 30)],
        [('c-study', 'Английский', 'school', 16, 60), ('c-work', 'Планёрка', 'groups', 11, 60)],
        [('c-sport', 'Зарядка', 'fitness', 8, 45)],
        [('c-study', 'Английский', 'school', 16, 60), ('c-home', 'Обед', 'restaurant', 13, 60),
         ('c-sport', 'Бассейн', 'pool', 19, 90)],
        [('c-work', 'Планёрка', 'groups', 10, 90), ('c-home', 'Обед', 'restaurant', 13, 60)],
        [('c-sport', 'Бассейн', 'pool', 11, 90)],
        [],
      ];
      final row = plan[(day.day + day.month) % plan.length];
      return [
        for (var i = 0; i < row.length; i++)
          VEvent(
            id: 'gen-${day.month}-${day.day}-$i',
            calendarId: row[i].$1,
            title: row[i].$2,
            iconName: row[i].$3,
            start: DateTime(day.year, day.month, day.day, row[i].$4),
            end: DateTime(day.year, day.month, day.day, row[i].$4)
                .add(Duration(minutes: row[i].$5)),
          ),
      ];
    });
  }

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
      location: 'Бассейн на Дачия',
      fields: const [
        VFieldValue(fieldId: 'f-left', value: '18 дней'),
        VFieldValue(fieldId: 'f-visits', value: '7 из 12'),
        VFieldValue(fieldId: 'f-card', value: '4417-08'),
      ],
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

  /// Экзамен с заметками — для экрана события и четвёртого уровня цвета.
  static final VEvent exam = VEvent(
    id: 'e-exam',
    calendarId: 'c-study',
    subcategoryId: 's-exam',
    title: 'Экзамен по грамматике',
    iconName: 'exam',
    start: _at(28, 11),
    end: _at(28, 13),
    fields: const [VFieldValue(fieldId: 'f-room', value: '204-б')],
  );

  static const examNotes = <VNote>[
    VNote(id: 'n1', eventId: 'e-exam', text: 'Паспорт и допуск, без них не пустят', color: clay),
    VNote(id: 'n2', eventId: 'e-exam', text: 'Повторить времена и согласование', sortOrder: 1),
    VNote(id: 'n3', eventId: 'e-exam', text: 'Прийти за 20 минут, аудиторию могут поменять', sortOrder: 2),
    VNote(id: 'n4', eventId: 'e-exam', text: 'После — забрать вещи из 312-го', color: amber, sortOrder: 3),
  ];

  static const fields = <VFieldDef>[
    VFieldDef(id: 'f-repeat', name: 'Повтор', type: VFieldType.text, iconName: 'repeat', isBuiltIn: true, showInCard: true, sortOrder: 0),
    VFieldDef(id: 'f-room', name: 'Кабинет', type: VFieldType.text, iconName: 'door', calendarId: 'c-study', showInCard: true, sortOrder: 1),
    VFieldDef(id: 'f-teacher', name: 'Преподаватель', type: VFieldType.person, iconName: 'person', calendarId: 'c-study', showInCard: true, sortOrder: 2),
    VFieldDef(id: 'f-pass', name: 'Абонемент', type: VFieldType.number, iconName: 'ticket', calendarId: 'c-study', sortOrder: 3),
    VFieldDef(id: 'f-paid', name: 'Оплачено', type: VFieldType.checkbox, iconName: 'toggle', calendarId: 'c-study', sortOrder: 4),
    VFieldDef(id: 'f-place', name: 'Место', type: VFieldType.text, iconName: 'place', isBuiltIn: true, sortOrder: 5),
    // Свои поля «Спорта»: в «Учёбу» они не приходят — номер карты уроку
    // английского не нужен.
    VFieldDef(id: 'f-left', name: 'Осталось', type: VFieldType.text, iconName: 'clock', calendarId: 'c-sport', showInCard: true, sortOrder: 0),
    VFieldDef(id: 'f-visits', name: 'Посещений', type: VFieldType.text, iconName: 'ticket', calendarId: 'c-sport', showInCard: true, sortOrder: 1),
    VFieldDef(id: 'f-card', name: 'Номер карты', type: VFieldType.number, iconName: 'number', calendarId: 'c-sport', sortOrder: 2),
    VFieldDef(id: 'f-coach', name: 'Тренер', type: VFieldType.person, iconName: 'person', calendarId: 'c-sport', sortOrder: 3),
    VFieldDef(id: 'f-link', name: 'Ссылка на встречу', type: VFieldType.url, iconName: 'cloud', calendarId: 'c-work', showInCard: true, sortOrder: 0),
    VFieldDef(id: 'f-project', name: 'Проект', type: VFieldType.text, iconName: 'work', calendarId: 'c-work', sortOrder: 1),
  ];
}

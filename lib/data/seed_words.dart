/// Слова демонстрационных данных на языке человека.
///
/// Живут отдельно от словаря интерфейса и не в `.arb`: это не подписи кнопок,
/// а содержимое, которое человек тут же перепишет под себя. Заводить ради него
/// две сотни ключей в переводимом словаре — только мешать переводчику.
///
/// Перевод ищется по русскому исходнику: демо-данные написаны по-русски, и
/// сверять две таблицы по ключам было бы лишней работой. Неизвестное слово
/// возвращается как есть — демонстрация от этого не ломается.
class SeedWords {
  const SeedWords(this._table);

  final Map<String, String> _table;

  String t(String source) => _table[source] ?? source;

  /// Слова языка. Неизвестный язык получает английские: латиница читается
  /// хоть как-то везде, кириллица — нет.
  static SeedWords of(String languageCode) =>
      SeedWords(_all[languageCode] ?? _all['en']!);

  static const _ru = <String, String>{};

  static const _en = {
    'Учёба': 'Study', 'Спорт': 'Sport', 'Работа': 'Work',
    'Личное': 'Personal', 'Распорядок': 'Routine',
    'Английский': 'English', 'Экзамены': 'Exams', 'Курсы': 'Courses',
    'Бассейн': 'Pool', 'Зал': 'Gym',
    'Подъём': 'Wake up', 'Зарядка': 'Workout', 'Завтрак': 'Breakfast',
    'Планёрка': 'Stand-up', 'Урок': 'Lesson', 'Обед с Ниной': 'Lunch with Nina',
    'Обед': 'Lunch', 'Кофе': 'Coffee', 'Экзамен': 'Exam',
    'Экзамен по грамматике': 'Grammar exam',
    'Абонемент в бассейн': 'Pool pass', 'Летний курс': 'Summer course',
    'Кофейня на Штефана': 'Café on Ștefan cel Mare',
    'Языковой центр, Бэнулеску-Бодони 45': 'Language centre, Bănulescu-Bodoni 45',
    'Бассейн на Дачия': 'Pool on Dacia',
    'Повтор': 'Repeat', 'Кабинет': 'Room', 'Преподаватель': 'Teacher',
    'Абонемент': 'Pass', 'Оплачено': 'Paid', 'Место': 'Place',
    'Участники': 'People', 'Осталось': 'Left', 'Посещений': 'Visits',
    'Номер карты': 'Card number', 'Тренер': 'Coach',
    'Ссылка на встречу': 'Meeting link', 'Проект': 'Project',
    'Мария Л.': 'Maria L.',
    'Паспорт и допуск, без них не пустят':
        'Passport and permit — they will not let you in without them',
    'Повторить времена и согласование': 'Revise tenses and agreement',
    'Прийти за 20 минут, аудиторию могут поменять':
        'Arrive 20 minutes early, the room may change',
    'После — забрать вещи из 312-го': 'Afterwards pick up my things from 312',
  };

  static const _uk = {
    'Учёба': 'Навчання', 'Спорт': 'Спорт', 'Работа': 'Робота',
    'Личное': 'Особисте', 'Распорядок': 'Розпорядок',
    'Английский': 'Англійська', 'Экзамены': 'Іспити', 'Курсы': 'Курси',
    'Бассейн': 'Басейн', 'Зал': 'Зала',
    'Подъём': 'Підйом', 'Зарядка': 'Зарядка', 'Завтрак': 'Сніданок',
    'Планёрка': 'Планірка', 'Урок': 'Урок', 'Обед с Ниной': 'Обід з Ніною',
    'Обед': 'Обід', 'Кофе': 'Кава', 'Экзамен': 'Іспит',
    'Экзамен по грамматике': 'Іспит із граматики',
    'Абонемент в бассейн': 'Абонемент у басейн', 'Летний курс': 'Літній курс',
    'Кофейня на Штефана': 'Кав’ярня на Штефана',
    'Языковой центр, Бэнулеску-Бодони 45': 'Мовний центр, Бенулеску-Бодоні 45',
    'Бассейн на Дачия': 'Басейн на Дачія',
    'Повтор': 'Повтор', 'Кабинет': 'Кабінет', 'Преподаватель': 'Викладач',
    'Абонемент': 'Абонемент', 'Оплачено': 'Оплачено', 'Место': 'Місце',
    'Участники': 'Учасники', 'Осталось': 'Залишилось', 'Посещений': 'Відвідувань',
    'Номер карты': 'Номер картки', 'Тренер': 'Тренер',
    'Ссылка на встречу': 'Посилання на зустріч', 'Проект': 'Проєкт',
    'Мария Л.': 'Марія Л.',
    'Паспорт и допуск, без них не пустят':
        'Паспорт і допуск, без них не пустять',
    'Повторить времена и согласование': 'Повторити часи й узгодження',
    'Прийти за 20 минут, аудиторию могут поменять':
        'Прийти за 20 хвилин, аудиторію можуть змінити',
    'После — забрать вещи из 312-го': 'Після — забрати речі з 312-ї',
  };

  static const _ro = {
    'Учёба': 'Studii', 'Спорт': 'Sport', 'Работа': 'Muncă',
    'Личное': 'Personal', 'Распорядок': 'Rutină',
    'Английский': 'Engleză', 'Экзамены': 'Examene', 'Курсы': 'Cursuri',
    'Бассейн': 'Bazin', 'Зал': 'Sală',
    'Подъём': 'Trezire', 'Зарядка': 'Gimnastică', 'Завтрак': 'Mic dejun',
    'Планёрка': 'Ședință', 'Урок': 'Lecție', 'Обед с Ниной': 'Prânz cu Nina',
    'Обед': 'Prânz', 'Кофе': 'Cafea', 'Экзамен': 'Examen',
    'Экзамен по грамматике': 'Examen de gramatică',
    'Абонемент в бассейн': 'Abonament la bazin', 'Летний курс': 'Curs de vară',
    'Кофейня на Штефана': 'Cafenea pe Ștefan cel Mare',
    'Языковой центр, Бэнулеску-Бодони 45': 'Centru lingvistic, Bănulescu-Bodoni 45',
    'Бассейн на Дачия': 'Bazin pe Dacia',
    'Повтор': 'Repetare', 'Кабинет': 'Sala', 'Преподаватель': 'Profesor',
    'Абонемент': 'Abonament', 'Оплачено': 'Achitat', 'Место': 'Loc',
    'Участники': 'Participanți', 'Осталось': 'Rămase', 'Посещений': 'Vizite',
    'Номер карты': 'Număr card', 'Тренер': 'Antrenor',
    'Ссылка на встречу': 'Link întâlnire', 'Проект': 'Proiect',
    'Мария Л.': 'Maria L.',
    'Паспорт и допуск, без них не пустят':
        'Pașaport și permis — fără ele nu te lasă',
    'Повторить времена и согласование': 'Repetă timpurile și acordul',
    'Прийти за 20 минут, аудиторию могут поменять':
        'Vino cu 20 de minute înainte, sala se poate schimba',
    'После — забрать вещи из 312-го': 'După — ia lucrurile din 312',
  };

  static const _pl = {
    'Учёба': 'Nauka', 'Спорт': 'Sport', 'Работа': 'Praca',
    'Личное': 'Osobiste', 'Распорядок': 'Rutyna',
    'Английский': 'Angielski', 'Экзамены': 'Egzaminy', 'Курсы': 'Kursy',
    'Бассейн': 'Basen', 'Зал': 'Siłownia',
    'Подъём': 'Pobudka', 'Зарядка': 'Rozgrzewka', 'Завтрак': 'Śniadanie',
    'Планёрка': 'Odprawa', 'Урок': 'Lekcja', 'Обед с Ниной': 'Obiad z Niną',
    'Обед': 'Obiad', 'Кофе': 'Kawa', 'Экзамен': 'Egzamin',
    'Экзамен по грамматике': 'Egzamin z gramatyki',
    'Абонемент в бассейн': 'Karnet na basen', 'Летний курс': 'Kurs letni',
    'Кофейня на Штефана': 'Kawiarnia na Ștefan cel Mare',
    'Языковой центр, Бэнулеску-Бодони 45': 'Centrum językowe, Bănulescu-Bodoni 45',
    'Бассейн на Дачия': 'Basen na Dacia',
    'Повтор': 'Powtarzanie', 'Кабинет': 'Sala', 'Преподаватель': 'Wykładowca',
    'Абонемент': 'Karnet', 'Оплачено': 'Opłacone', 'Место': 'Miejsce',
    'Участники': 'Uczestnicy', 'Осталось': 'Zostało', 'Посещений': 'Wejść',
    'Номер карты': 'Numer karty', 'Тренер': 'Trener',
    'Ссылка на встречу': 'Link do spotkania', 'Проект': 'Projekt',
    'Мария Л.': 'Maria L.',
    'Паспорт и допуск, без них не пустят':
        'Paszport i przepustka — bez nich nie wpuszczą',
    'Повторить времена и согласование': 'Powtórzyć czasy i zgodność',
    'Прийти за 20 минут, аудиторию могут поменять':
        'Przyjść 20 minut wcześniej, sala może się zmienić',
    'После — забрать вещи из 312-го': 'Potem odebrać rzeczy z 312',
  };

  static const _de = {
    'Учёба': 'Studium', 'Спорт': 'Sport', 'Работа': 'Arbeit',
    'Личное': 'Privat', 'Распорядок': 'Tagesablauf',
    'Английский': 'Englisch', 'Экзамены': 'Prüfungen', 'Курсы': 'Kurse',
    'Бассейн': 'Schwimmbad', 'Зал': 'Fitnessstudio',
    'Подъём': 'Aufstehen', 'Зарядка': 'Morgensport', 'Завтрак': 'Frühstück',
    'Планёрка': 'Daily', 'Урок': 'Unterricht', 'Обед с Ниной': 'Mittagessen mit Nina',
    'Обед': 'Mittagessen', 'Кофе': 'Kaffee', 'Экзамен': 'Prüfung',
    'Экзамен по грамматике': 'Grammatikprüfung',
    'Абонемент в бассейн': 'Schwimmbad-Abo', 'Летний курс': 'Sommerkurs',
    'Кофейня на Штефана': 'Café an der Ștefan cel Mare',
    'Языковой центр, Бэнулеску-Бодони 45': 'Sprachzentrum, Bănulescu-Bodoni 45',
    'Бассейн на Дачия': 'Schwimmbad an der Dacia',
    'Повтор': 'Wiederholung', 'Кабинет': 'Raum', 'Преподаватель': 'Lehrkraft',
    'Абонемент': 'Abo', 'Оплачено': 'Bezahlt', 'Место': 'Ort',
    'Участники': 'Teilnehmer', 'Осталось': 'Übrig', 'Посещений': 'Besuche',
    'Номер карты': 'Kartennummer', 'Тренер': 'Trainer',
    'Ссылка на встречу': 'Meeting-Link', 'Проект': 'Projekt',
    'Мария Л.': 'Maria L.',
    'Паспорт и допуск, без них не пустят':
        'Ausweis und Zulassung — ohne sie kommt man nicht rein',
    'Повторить времена и согласование': 'Zeiten und Kongruenz wiederholen',
    'Прийти за 20 минут, аудиторию могут поменять':
        '20 Minuten früher kommen, der Raum kann wechseln',
    'После — забрать вещи из 312-го': 'Danach die Sachen aus Raum 312 holen',
  };

  static const _es = {
    'Учёба': 'Estudios', 'Спорт': 'Deporte', 'Работа': 'Trabajo',
    'Личное': 'Personal', 'Распорядок': 'Rutina',
    'Английский': 'Inglés', 'Экзамены': 'Exámenes', 'Курсы': 'Cursos',
    'Бассейн': 'Piscina', 'Зал': 'Gimnasio',
    'Подъём': 'Levantarse', 'Зарядка': 'Ejercicio', 'Завтрак': 'Desayuno',
    'Планёрка': 'Reunión diaria', 'Урок': 'Clase', 'Обед с Ниной': 'Comida con Nina',
    'Обед': 'Comida', 'Кофе': 'Café', 'Экзамен': 'Examen',
    'Экзамен по грамматике': 'Examen de gramática',
    'Абонемент в бассейн': 'Abono de piscina', 'Летний курс': 'Curso de verano',
    'Кофейня на Штефана': 'Cafetería en Ștefan cel Mare',
    'Языковой центр, Бэнулеску-Бодони 45': 'Centro de idiomas, Bănulescu-Bodoni 45',
    'Бассейн на Дачия': 'Piscina en Dacia',
    'Повтор': 'Repetición', 'Кабинет': 'Aula', 'Преподаватель': 'Profesor',
    'Абонемент': 'Abono', 'Оплачено': 'Pagado', 'Место': 'Lugar',
    'Участники': 'Participantes', 'Осталось': 'Quedan', 'Посещений': 'Visitas',
    'Номер карты': 'Número de tarjeta', 'Тренер': 'Entrenador',
    'Ссылка на встречу': 'Enlace de la reunión', 'Проект': 'Proyecto',
    'Мария Л.': 'María L.',
    'Паспорт и допуск, без них не пустят':
        'Pasaporte y permiso: sin ellos no te dejan entrar',
    'Повторить времена и согласование': 'Repasar los tiempos y la concordancia',
    'Прийти за 20 минут, аудиторию могут поменять':
        'Llegar 20 minutos antes, el aula puede cambiar',
    'После — забрать вещи из 312-го': 'Después, recoger las cosas del 312',
  };

  static const _all = {
    'ru': _ru,
    'en': _en,
    'uk': _uk,
    'ro': _ro,
    'pl': _pl,
    'de': _de,
    'es': _es,
  };
}

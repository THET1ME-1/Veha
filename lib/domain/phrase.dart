/// Разбор строки в событие: «созвон завтра в 15:00 на час».
///
/// Считается без базы и без экрана — это чистая функция, и проверяется она
/// так же. Понимает то, чем человек говорит о времени на самом деле: завтра,
/// в пятницу, через два дня, в 15, в 15:30, «на час», «на 90 минут».
///
/// Чего нет намеренно: угадывания места и участников по тексту. Веха не
/// притворяется, будто поняла больше, чем поняла: всё, что не разобралось,
/// остаётся названием.
library;

class Phrase {
  const Phrase({
    required this.title,
    required this.start,
    required this.duration,
    this.hasTime = false,
    this.rrule,
  });

  final String title;
  final DateTime start;
  final Duration duration;

  /// Время названо явно. Иначе событие ставится на ближайший круглый час, но
  /// экран может предложить поправить.
  final bool hasTime;

  /// Правило повторения, если человек его назвал: «каждый вторник», «по
  /// будням», «каждую последнюю пятницу месяца». `null` — событие разовое.
  final String? rrule;

  DateTime get end => start.add(duration);
}

/// Слова о днях. Семь языков, поэтому таблицей, а не разбором морфологии:
/// «послезавтра» встречается чаще, чем что-либо, что стоило бы склонять.
const _dayWords = <String, int>{
  // Русский
  'сегодня': 0, 'завтра': 1, 'послезавтра': 2, 'вчера': -1,
  // Английский
  'today': 0, 'tomorrow': 1, 'yesterday': -1,
  // Украинский
  'сьогодні': 0, 'післязавтра': 2, 'учора': -1,
  // Румынский
  'azi': 0, 'astăzi': 0, 'mâine': 1, 'poimâine': 2, 'ieri': -1,
  // Польский
  'dziś': 0, 'dzisiaj': 0, 'jutro': 1, 'pojutrze': 2, 'wczoraj': -1,
  // Немецкий
  'heute': 0, 'morgen': 1, 'übermorgen': 2, 'gestern': -1,
  // Испанский
  'hoy': 0, 'mañana': 1, 'ayer': -1,
};

/// Дни недели: номер по ISO, понедельник первый.
const _weekdayWords = <String, int>{
  'понедельник': 1, 'вторник': 2, 'среду': 3, 'среда': 3, 'четверг': 4,
  'пятницу': 5, 'пятница': 5, 'субботу': 6, 'суббота': 6,
  'воскресенье': 7, 'воскресение': 7,
  'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4, 'friday': 5,
  'saturday': 6, 'sunday': 7,
  'понеділок': 1, 'вівторок': 2, 'середу': 3, 'четвер': 4, 'пʼятницю': 5,
  'суботу': 6, 'неділю': 7,
  'luni': 1, 'marți': 2, 'miercuri': 3, 'joi': 4, 'vineri': 5, 'sâmbătă': 6,
  'duminică': 7,
  'poniedziałek': 1, 'wtorek': 2, 'środę': 3, 'czwartek': 4, 'piątek': 5,
  'sobotę': 6, 'niedzielę': 7,
  'montag': 1, 'dienstag': 2, 'mittwoch': 3, 'donnerstag': 4, 'freitag': 5,
  'samstag': 6, 'sonntag': 7,
  'lunes': 1, 'martes': 2, 'miércoles': 3, 'jueves': 4, 'viernes': 5,
  'sábado': 6, 'domingo': 7,
};

/// Слова часа и минут для длительности: «на час», «на полтора часа».
const _hourWords = {'час', 'часа', 'часов', 'hour', 'hours', 'година', 'години',
  'oră', 'ore', 'godzina', 'godziny', 'stunde', 'stunden', 'hora', 'horas'};
const _minuteWords = {'минут', 'минуты', 'мин', 'min', 'minutes', 'minute',
  'хвилин', 'minuty', 'minuten', 'minutos'};
const _halfWords = {'полчаса', 'полтора', 'half'};

/// Предлоги времени. Служебные они, только когда за ними идёт время или день:
/// «в пятницу» — служебный, «встреча в театре» — часть названия.
const _prepositions = {'в', 'во', 'at', 'о', 'la', 'o', 'um', 'a', 'на'};

/// «Через», «in», «peste» — начало отсчёта вперёд.
const _afterWords = {'через', 'in', 'за', 'peste', 'za', 'dentro'};

/// Слова «каждый» во всех формах и языках: с них начинается правило повтора.
const _everyWords = {
  'каждый', 'каждую', 'каждое', 'каждые', 'ежедневно', 'еженедельно',
  'ежемесячно', 'ежегодно',
  'every', 'daily', 'weekly', 'monthly', 'yearly',
  'кожен', 'кожну', 'кожні', 'щодня', 'щотижня', 'щомісяця',
  'fiecare', 'zilnic', 'săptămânal', 'lunar',
  'każdy', 'każdą', 'co', 'codziennie', 'cotygodniowo',
  'jeden', 'jede', 'täglich', 'wöchentlich', 'monatlich',
  'cada', 'diariamente', 'semanalmente', 'mensualmente',
};

/// «По будням» и «по выходным» — готовые наборы дней.
const _weekdaysPhrases = {
  'будням': [1, 2, 3, 4, 5],
  'буднях': [1, 2, 3, 4, 5],
  'weekdays': [1, 2, 3, 4, 5],
  'будні': [1, 2, 3, 4, 5],
  'выходным': [6, 7],
  'выходных': [6, 7],
  'weekends': [6, 7],
};

/// Единицы повтора: день, неделя, месяц, год — в тех формах, что встречаются
/// после «каждые N».
const _unitDay = {'день', 'дня', 'дней', 'day', 'days', 'дні', 'zi', 'zile',
  'dzień', 'dni', 'tag', 'tage', 'día', 'días'};
const _unitWeek = {'неделю', 'недели', 'недель', 'week', 'weeks', 'тиждень',
  'тижні', 'săptămână', 'săptămâni', 'tydzień', 'tygodnie', 'woche', 'wochen',
  'semana', 'semanas'};
const _unitMonth = {'месяц', 'месяца', 'месяцев', 'month', 'months', 'місяць',
  'місяці', 'lună', 'luni', 'miesiąc', 'miesiące', 'monat', 'monate', 'mes',
  'meses'};
const _unitYear = {'год', 'года', 'лет', 'year', 'years', 'рік', 'роки', 'an',
  'ani', 'rok', 'lata', 'jahr', 'jahre', 'año', 'años'};

/// Позиция дня недели в месяце: «последнюю пятницу», «второй вторник».
const _positionWords = <String, int>{
  'первый': 1, 'первую': 1, 'первое': 1, 'first': 1,
  'второй': 2, 'вторую': 2, 'второе': 2, 'second': 2,
  'третий': 3, 'третью': 3, 'третье': 3, 'third': 3,
  'четвёртый': 4, 'четвертый': 4, 'четвёртую': 4, 'четвертую': 4, 'fourth': 4,
  'последний': -1, 'последнюю': -1, 'последнее': -1, 'last': -1,
};

/// Слово «месяц» в родительном — хвост правила «последняя пятница месяца».
const _monthTail = {'месяца', 'month', 'місяця', 'lunii', 'miesiąca', 'monats',
  'mes'};

/// Разбирает строку. [now] — «сейчас», от которого считаются «завтра» и
/// «через два дня».
Phrase parsePhrase(
  String input, {
  required DateTime now,
  Duration fallback = const Duration(hours: 1),
}) {
  final words = input.trim().split(RegExp(r'\s+'));
  final kept = <String>[];

  DateTime? day;
  int? hour;
  int? minute;
  Duration? duration;
  var takingDuration = false;

  // Правило повтора собирается по ходу: частота, шаг, дни недели и позиция
  // дня в месяце приходят разными словами и в любом порядке.
  String? freq;
  var interval = 1;
  final repeatDays = <int>{};
  int? position;
  var sawEvery = false;

  for (var i = 0; i < words.length; i++) {
    final raw = words[i];
    final word = raw.toLowerCase().replaceAll(RegExp(r'[.,!?]+$'), '');

    // «на час», «на 40 минут» — длительность идёт после предлога.
    if (const {'на', 'for', 'на протязі', 'pe', 'przez', 'für', 'por'}
        .contains(word)) {
      takingDuration = true;
      continue;
    }

    // «каждый», «по будням», «ежедневно» — начало правила повтора.
    if (_everyWords.contains(word)) {
      sawEvery = true;
      freq ??= switch (word) {
        'ежедневно' || 'daily' || 'щодня' || 'zilnic' || 'codziennie' ||
        'täglich' || 'diariamente' => 'DAILY',
        'еженедельно' || 'weekly' || 'щотижня' || 'săptămânal' ||
        'cotygodniowo' || 'wöchentlich' || 'semanalmente' => 'WEEKLY',
        'ежемесячно' || 'monthly' || 'щомісяця' || 'lunar' ||
        'mensualmente' || 'monatlich' => 'MONTHLY',
        'ежегодно' || 'yearly' || 'jährlich' => 'YEARLY',
        _ => null,
      };
      continue;
    }

    // «по» перед набором дней служебное: «по будням» — правило, «по дороге» —
    // часть названия. Решает следующее слово.
    if (const {'по', 'on', 'w', 'am', 'en', 'pe'}.contains(word) &&
        i + 1 < words.length) {
      final next =
          words[i + 1].toLowerCase().replaceAll(RegExp(r'[.,!?]+$'), '');
      if (_weekdaysPhrases.containsKey(next) ||
          _weekdayWords.containsKey(next)) {
        sawEvery = true;
        continue;
      }
    }

    // «по будням», «по выходным».
    final preset = _weekdaysPhrases[word];
    if (preset != null) {
      freq = 'WEEKLY';
      repeatDays.addAll(preset);
      sawEvery = true;
      continue;
    }

    // «последнюю пятницу», «второй вторник» — позиция запоминается и ждёт
    // самого дня недели следующим словом.
    final pos = _positionWords[word];
    if (pos != null && sawEvery) {
      position = pos;
      continue;
    }

    // Хвост «месяца» в правиле «последняя пятница месяца» уже ничего не
    // добавляет: частоту задала позиция.
    if (sawEvery && position != null && _monthTail.contains(word)) continue;

    // Единица после «каждые N»: день, неделя, месяц, год.
    if (sawEvery) {
      if (_unitDay.contains(word)) {
        freq = 'DAILY';
        continue;
      }
      if (_unitWeek.contains(word)) {
        freq = 'WEEKLY';
        continue;
      }
      if (_unitMonth.contains(word)) {
        freq = 'MONTHLY';
        continue;
      }
      if (_unitYear.contains(word)) {
        freq = 'YEARLY';
        continue;
      }
      // «каждые 2 недели»: число идёт шагом, а не количеством событий.
      final step = _number(word);
      if (step != null) {
        interval = step;
        continue;
      }
      // Союз в перечислении дней: «вторник и четверг».
      if (const {'и', 'and', 'та', 'și', 'i', 'und', 'y'}.contains(word) &&
          repeatDays.isNotEmpty) {
        continue;
      }
    }

    final dayShift = _dayWords[word];
    if (dayShift != null) {
      day = DateTime(now.year, now.month, now.day)
          .add(Duration(days: dayShift));
      continue;
    }

    final weekday = _weekdayWords[word];
    if (weekday != null) {
      if (sawEvery) {
        // «каждый вторник» задаёт день правила, а не дату: сама дата станет
        // ближайшим таким днём, когда правило соберётся.
        repeatDays.add(weekday);
        freq ??= position == null ? 'WEEKLY' : 'MONTHLY';
        if (position != null) freq = 'MONTHLY';
        continue;
      }
      day = _nextWeekday(now, weekday);
      continue;
    }

    // «через два дня», «через неделю»
    if (_afterWords.contains(word) && i + 1 < words.length) {
      // Числа может не быть вовсе: «через неделю» — это через одну.
      final hasCount = _number(words[i + 1]) != null;
      final count = hasCount ? _number(words[i + 1])! : 1;
      final unit = (hasCount && i + 2 < words.length
              ? words[i + 2]
              : words[i + 1])
          .toLowerCase();
      final step = hasCount ? 2 : 1;
      {
        if (unit.startsWith('дн') || unit.startsWith('day') ||
            unit.startsWith('zi') || unit.startsWith('dni') ||
            unit.startsWith('tag') || unit.startsWith('día')) {
          day = DateTime(now.year, now.month, now.day)
              .add(Duration(days: count));
          i += step;
          continue;
        }
        if (unit.startsWith('недел') || unit.startsWith('week') ||
            unit.startsWith('тижн') || unit.startsWith('săptăm') ||
            unit.startsWith('tyg') || unit.startsWith('woche') ||
            unit.startsWith('semana')) {
          day = DateTime(now.year, now.month, now.day)
              .add(Duration(days: 7 * count));
          i += step;
          continue;
        }
      }
    }

    // «в 15:30», «15:30», «в 9»
    final time = RegExp(r'^(\d{1,2})[:.](\d{2})$').firstMatch(word);
    if (time != null) {
      hour = int.parse(time.group(1)!);
      minute = int.parse(time.group(2)!);
      continue;
    }

    // Предлог перед временем или днём — служебный: «в пятницу», «at 10:15».
    // Проверяем, что за ним идёт: иначе «встреча в театре» потеряет «в».
    if (_prepositions.contains(word) && i + 1 < words.length) {
      final next = words[i + 1].toLowerCase().replaceAll(RegExp(r'[.,!?]+$'), '');
      final onlyHour = RegExp(r'^(\d{1,2})$').firstMatch(next);

      if (onlyHour != null) {
        hour = int.parse(onlyHour.group(1)!);
        minute = 0;
        i += 1;
        continue;
      }
      if (RegExp(r'^\d{1,2}[:.]\d{2}$').hasMatch(next) ||
          _dayWords.containsKey(next) ||
          _weekdayWords.containsKey(next)) {
        continue;
      }
    }

    if (takingDuration) {
      if (_halfWords.contains(word)) {
        duration = word == 'полчаса'
            ? const Duration(minutes: 30)
            : const Duration(minutes: 90);
        takingDuration = false;
        continue;
      }
      if (_hourWords.contains(word)) {
        duration = const Duration(hours: 1);
        takingDuration = false;
        continue;
      }
      final count = _number(word);
      if (count != null && i + 1 < words.length) {
        final unit = words[i + 1].toLowerCase();
        if (_hourWords.contains(unit)) {
          duration = Duration(hours: count);
          i += 1;
          takingDuration = false;
          continue;
        }
        if (_minuteWords.any(unit.startsWith)) {
          duration = Duration(minutes: count);
          i += 1;
          takingDuration = false;
          continue;
        }
      }
      // Предлог оказался частью названия: «встреча на кафедре».
      takingDuration = false;
      kept.add('на');
      kept.add(raw);
      continue;
    }

    kept.add(raw);
  }

  // Правило с днями недели тянет за собой дату: «каждый вторник», сказанное в
  // понедельник, начинается завтра, а не сегодня.
  if (day == null && repeatDays.isNotEmpty) {
    final today = DateTime(now.year, now.month, now.day);
    var best = 8;
    for (final d in repeatDays) {
      var shift = (d - today.weekday) % 7;
      if (shift < 0) shift += 7;
      if (shift < best) best = shift;
    }
    day = today.add(Duration(days: best));
  }

  final base = day ?? DateTime(now.year, now.month, now.day);
  final start = hour == null
      // Времени не назвали: ставим на ближайший круглый час впереди, а не на
      // полночь — «созвон завтра» имеется в виду днём.
      ? _nextRoundHour(base, now)
      : DateTime(base.year, base.month, base.day, hour, minute ?? 0);

  return Phrase(
    title: kept.join(' ').trim(),
    start: start,
    duration: duration ?? fallback,
    hasTime: hour != null,
    rrule: _rrule(
      freq: freq,
      interval: interval,
      days: repeatDays,
      position: position,
      start: start,
    ),
  );
}

/// Собранное правило в строку RFC 5545. `null` — о повторе речи не было.
///
/// Правило собирается здесь, а не по ходу разбора: слова приходят в любом
/// порядке — «каждый вторник в 16:00» и «в 16:00 каждый вторник» одно и то же.
String? _rrule({
  required String? freq,
  required int interval,
  required Set<int> days,
  required int? position,
  required DateTime start,
}) {
  if (freq == null) return null;

  const names = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  final parts = <String>['FREQ=$freq'];
  if (interval > 1) parts.add('INTERVAL=$interval');

  if (freq == 'MONTHLY' && position != null && days.isNotEmpty) {
    // «Последняя пятница месяца»: позиция с днём недели, а не число.
    parts.add('BYDAY=$position${names[days.first - 1]}');
    return parts.join(';');
  }

  if (freq == 'WEEKLY') {
    final list = days.isEmpty ? {start.weekday} : days;
    parts.add(
        'BYDAY=${(list.toList()..sort()).map((d) => names[d - 1]).join(',')}');
  }

  return parts.join(';');
}

DateTime _nextWeekday(DateTime now, int weekday) {
  final today = DateTime(now.year, now.month, now.day);
  var shift = (weekday - today.weekday) % 7;
  // «В пятницу», сказанное в пятницу, означает следующую.
  if (shift == 0) shift = 7;
  return today.add(Duration(days: shift));
}

DateTime _nextRoundHour(DateTime day, DateTime now) {
  final sameDay = day.year == now.year &&
      day.month == now.month &&
      day.day == now.day;
  if (!sameDay) return DateTime(day.year, day.month, day.day, 9);

  final next = now.minute == 0 ? now.hour : now.hour + 1;
  return DateTime(day.year, day.month, day.day, next.clamp(0, 23));
}

int? _number(String word) {
  final digits = int.tryParse(word);
  if (digits != null) return digits;

  const words = <String, int>{
    'один': 1, 'одну': 1, 'два': 2, 'две': 2, 'три': 3, 'четыре': 4,
    'пять': 5, 'шесть': 6, 'семь': 7, 'восемь': 8, 'девять': 9, 'десять': 10,
    'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
  };
  return words[word.toLowerCase()];
}

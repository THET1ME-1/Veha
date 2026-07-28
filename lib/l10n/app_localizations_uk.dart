// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class LUk extends L {
  LUk([String locale = 'uk']) : super(locale);

  @override
  String get navCalendar => 'Календар';

  @override
  String get navList => 'Список';

  @override
  String get navAccess => 'Доступ';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get viewDay => 'День';

  @override
  String get viewDays => 'Дні';

  @override
  String get viewWeek => 'Тиждень';

  @override
  String get viewMonth => 'Місяць';

  @override
  String get readingClock => 'Годинник';

  @override
  String get readingChain => 'Ланцюжок';

  @override
  String get viewNotBuilt => 'Вигляд ще не зібрано';

  @override
  String get newEvent => 'Нова подія';

  @override
  String get today => 'сьогодні';

  @override
  String get nothingPlanned => 'Нічого не заплановано';

  @override
  String durationMinutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String durationHours(int hours) {
    return '$hours год';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours год $minutes хв';
  }

  @override
  String spanDayOf(int current, int total) {
    return '$current-й із $total';
  }

  @override
  String spanUntil(String date) {
    return 'до $date';
  }

  @override
  String get actionDone => 'Готово';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get actionAdd => 'Додати';

  @override
  String get actionEdit => 'Змінити';

  @override
  String get actionUndo => 'Повернути';

  @override
  String get fieldName => 'Назва';

  @override
  String get calendarsTitle => 'Календарі';

  @override
  String get calendarOne => 'Календар';

  @override
  String get calendarNewShort => 'Новий';

  @override
  String get calendarNew => 'Новий календар';

  @override
  String get calendarCreate => 'Створити календар';

  @override
  String get calendarsEmptyTitle => 'Жодного календаря';

  @override
  String get calendarsEmptyBody =>
      'Календар задає колір та іконку всім подіям усередині. Зазвичай їх три-чотири: дім, робота, навчання, спорт.';

  @override
  String get branchOne => 'Гілка';

  @override
  String get branchNone => 'Без гілок';

  @override
  String get branchAdd => 'Додати гілку';

  @override
  String branchOf(String name) {
    return 'Гілка «$name»';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гілок',
      few: '$count гілки',
      one: '$count гілка',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'Успадковує';

  @override
  String get colorOwn => 'Свій колір';

  @override
  String get fieldsTitle => 'Власні поля';

  @override
  String get fieldsShared => 'Спільні для всіх';

  @override
  String get fieldsSharedRow => 'Спільні поля';

  @override
  String get fieldsGroups => 'Групи';

  @override
  String get fieldsNoneYet => 'Поки жодного';

  @override
  String get fieldsGroupEmpty => 'Без власних полів';

  @override
  String get fieldsGroupCreate => 'Створити групу полів';

  @override
  String get fieldsGroupNew => 'Нова група';

  @override
  String fieldAddTo(String name) {
    return 'Додати поле до «$name»';
  }

  @override
  String fieldNewIn(String name) {
    return 'Нове поле в «$name»';
  }

  @override
  String get fieldOne => 'Поле';

  @override
  String get fieldShared => 'Спільне';

  @override
  String get fieldNamePlaceholder => 'Назва поля';

  @override
  String get fieldKind => 'Чим заповнювати';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count власних полів',
      few: '$count власних поля',
      one: '$count власне поле',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'у картці $count';
  }

  @override
  String get fieldEraseValue => 'Стерти';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  @override
  String get typeText => 'Текст';

  @override
  String get typeNumber => 'Число';

  @override
  String get typeDate => 'Дата';

  @override
  String get typeTime => 'Час';

  @override
  String get typeDuration => 'Тривалість';

  @override
  String get typeSelect => 'Список';

  @override
  String get typeCheckbox => 'Прапорець';

  @override
  String get typeUrl => 'Посилання';

  @override
  String get typePhone => 'Телефон';

  @override
  String get typePerson => 'Людина';

  @override
  String get typeMoney => 'Гроші';

  @override
  String get searchHint => 'Знайти подію';

  @override
  String get searchEmpty =>
      'Шукайте за назвою, місцем або власним полем — наприклад, за номером кабінету.';

  @override
  String get searchNothing => 'Нічого не знайшлося.';

  @override
  String get allDay => 'весь день';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsAppearance => 'Оформлення';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsSystem => 'Як у системі';

  @override
  String get settingsLight => 'Світла';

  @override
  String get settingsDark => 'Темна';

  @override
  String get settingsChroma => 'Насиченість';

  @override
  String get settingsChromaHint =>
      'На фірмовій м’яті «Соковито» викручує пігулки до кислотного';

  @override
  String get settingsExact => 'Точнісінько';

  @override
  String get settingsVivid => 'Соковито';

  @override
  String get settingsSeed => 'Фірмовий колір';

  @override
  String get settingsCalendarGroup => 'Календар';

  @override
  String get settingsWeekDays => 'Дні у вигляді «Тиждень»';

  @override
  String get settingsWeekFull => 'Весь тиждень';

  @override
  String get settingsWeekdaysOnly => 'Лише будні';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count днів на тиждень',
      few: '$count дні на тиждень',
      one: '$count день на тиждень',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Кабінет, тренер, номер абонемента';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsDataGroup => 'Дані';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String get settingsVersion => 'Версія';

  @override
  String get settingsStorage => 'Усе зберігається на пристрої';

  @override
  String get settingsSource => 'Вихідний код';

  @override
  String get monthViewTitle => 'Вигляд місяця';

  @override
  String get monthChips => 'Чіпи з назвами';

  @override
  String get monthChipsHint => 'Видно, що саме цього дня';

  @override
  String get monthTint => 'Тоновані комірки';

  @override
  String get monthTintHint => 'Видно, чим зайнятий день';

  @override
  String get monthDensity => 'Щільність чіпа';

  @override
  String get monthDensityBoth => 'Іконка й текст';

  @override
  String get monthDensityIcon => 'Лише іконка';

  @override
  String get monthPerCell => 'Подій у комірці';

  @override
  String get monthPerCellHint => 'Далі згортати в «+N»';

  @override
  String get eventOne => 'Подія';

  @override
  String get eventWhen => 'Коли';

  @override
  String get eventTime => 'Час';

  @override
  String get eventRepeat => 'Повтор';

  @override
  String get eventCalendarAndBranch => 'Календар і гілка';

  @override
  String get eventReminder => 'Нагадування';

  @override
  String get eventPlace => 'Місце';

  @override
  String get eventPlaceHint => 'Де це буде';

  @override
  String get eventDelete => 'Видалити подію';

  @override
  String get moreDetails => 'Докладніше';

  @override
  String get lookTitle => 'Іконка й колір';

  @override
  String get lookInherit => 'Як у календаря';

  @override
  String get lookOwnColor => 'Свій колір';

  @override
  String get inCard => 'У картці';

  @override
  String get notesTitle => 'Нотатки';

  @override
  String get noteOne => 'Нотатка';

  @override
  String get noteAdd => 'Додати нотатку';

  @override
  String get noteHint => 'Що не забути';

  @override
  String get repeatNone => 'Не повторюється';

  @override
  String get repeatByRule => 'За правилом';

  @override
  String get repeatTitle => 'Повторення';

  @override
  String get repeatDaily => 'Щодня';

  @override
  String get repeatWeekly => 'Щотижня';

  @override
  String get repeatEvery => 'Кожні';

  @override
  String get repeatEndsWhen => 'Коли закінчується';

  @override
  String get repeatNextDates => 'Найближчі дати';

  @override
  String get repeatNever => 'Ніколи';

  @override
  String get repeatUntilDate => 'До дати';

  @override
  String repeatAfterCount(int count) {
    return 'Після $count повторів';
  }

  @override
  String get unitDay => 'День';

  @override
  String get unitWeek => 'Тиждень';

  @override
  String get unitMonth => 'Місяць';

  @override
  String get unitYear => 'Рік';

  @override
  String get scopeTitle => 'Що змінити';

  @override
  String scopeRepeats(String label) {
    return 'Заняття повторюється: $label';
  }

  @override
  String get scopeOnly => 'Лише це заняття';

  @override
  String get scopeFollowing => 'Це й наступні';

  @override
  String get scopeFollowingHint =>
      'Ряд поділиться: минулі заняття залишаться як були';

  @override
  String get scopeWhole => 'Весь ряд';

  @override
  String get scopeWholeHint => 'Усі заняття, включно з минулими';

  @override
  String get msgEventDeleted => 'Подію видалено';

  @override
  String get msgSeriesDeleted => 'Ряд видалено';

  @override
  String get msgOccurrenceSkipped => 'Заняття скасовано';

  @override
  String get reminderNone => 'Без нагадування';

  @override
  String get reminderAtStart => 'У момент початку';

  @override
  String get reminderNever => 'Не нагадувати';

  @override
  String get reminderHint =>
      'Можна кілька: за день зібратися, за десять хвилин вийти';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count хвилин',
      few: 'За $count хвилини',
      one: 'За $count хвилину',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count годин',
      few: 'За $count години',
      one: 'За годину',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count днів',
      few: 'За $count дні',
      one: 'За день',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'За тиждень';

  @override
  String get reminderStarts => 'Починається';

  @override
  String reminderStartsAt(String time) {
    return 'Початок о $time';
  }

  @override
  String get icsExport => 'Вивантажити в .ics';

  @override
  String get icsExportHint => 'Файл для іншого календаря';

  @override
  String get icsImport => 'Завантажити з .ics';

  @override
  String get icsImportHint => 'Події з чужого календаря';

  @override
  String get icsSaveTitle => 'Куди зберегти календар';

  @override
  String get icsPickTitle => 'Виберіть файл календаря';

  @override
  String get icsNothingToExport => 'Вивантажувати нічого: подій немає.';

  @override
  String icsExported(int count) {
    return 'Вивантажено подій: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Завантажено подій: $count.';
  }

  @override
  String get icsUnreadable => 'Файл не прочитався.';

  @override
  String get icsNoEvents => 'У файлі не знайшлося жодної події.';

  @override
  String get colorPickerOwn => 'Свій колір';

  @override
  String get colorHue => 'Відтінок';

  @override
  String get colorChroma => 'Насиченість';

  @override
  String get colorTone => 'Світлота';

  @override
  String get colorMine => 'Мої кольори';

  @override
  String get colorRecent => 'Останні';

  @override
  String get colorSaveMine => 'До моїх';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Відтінок $hue° · насиченість $chroma · світлота $tone';
  }

  @override
  String get colorPickerHint =>
      'Піпетка бере колір із зображення: відкрийте знімок екрана або фотографію та натисніть на потрібне місце. Збережені живуть у «Моїх кольорах» і доступні з будь-якого пікера.';

  @override
  String get branchColorTitle => 'Колір гілки';

  @override
  String get branchColorOwnHint => 'Задано в цій гілці';

  @override
  String branchColorOfCalendar(String name) {
    return 'Колір «$name»';
  }

  @override
  String get branchColorPickerRow => 'Свій колір із пікера';

  @override
  String get branchColorPickerHint => 'Відтінок, насиченість, hex, піпетка';

  @override
  String branchColorChain(String name) {
    return 'Перефарбуєте «$name» — змінять колір усі гілки й події, де стоїть успадкування. Гілки зі своїм кольором залишаться як є.';
  }

  @override
  String get branchColorEventRow => 'Подія гілки';

  @override
  String get levelCalendar => 'Календар';

  @override
  String get levelOwn => 'Свій';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'кожні $count днів',
      few: 'кожні $count дні',
      one: 'щодня',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'кожні $count тижнів',
      few: 'кожні $count тижні',
      one: 'щотижня',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'кожні $count місяців',
      few: 'кожні $count місяці',
      one: 'щомісяця',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'щороку';

  @override
  String ruleWeekDays(String every, String days) {
    return '$every: $days';
  }

  @override
  String ruleMonthPosition(String every, String ordinal, String weekday) {
    return '$every: $ordinal $weekday';
  }

  @override
  String get ordinalLast =>
      'останній,останній,остання,останній,остання,остання,остання';

  @override
  String get ordinal1 => 'перший,перший,перша,перший,перша,перша,перша';

  @override
  String get ordinal2 => 'другий,другий,друга,другий,друга,друга,друга';

  @override
  String get ordinal3 => 'третій,третій,третя,третій,третя,третя,третя';

  @override
  String get ordinal4 =>
      'четвертий,четвертий,четверта,четвертий,четверта,четверта,четверта';

  @override
  String get weekSetupTitle => 'Які дні показувати';

  @override
  String get weekSetupHint => 'Колонок буде стільки, скільки днів позначено';

  @override
  String get weekSetupAll => 'Весь тиждень';

  @override
  String get weekSetupWorkdays => 'Будні';

  @override
  String get weekSetupWeekend => 'Вихідні';

  @override
  String get weekSetupStartsWith => 'Тиждень починається з';

  @override
  String get accessTitle => 'Доступ';

  @override
  String get accessCreateKey => 'Створити ключ';

  @override
  String get accessRevoke => 'Відкликати';

  @override
  String get accessHint =>
      'Ключі працюють, поки ввімкнено синхронізацію. Календар, який живе лише на телефоні, ззовні недоступний — стукати нікуди.';

  @override
  String get repeatNever2 => 'Не повторювати';

  @override
  String get repeatWeekdays => 'По буднях';

  @override
  String get repeatCountLabel => 'Повторів';

  @override
  String get repeatTimes => 'разів';

  @override
  String get repeatAfterSome => 'Після кількох повторів';

  @override
  String get repeatNoDates => 'За таким правилом занять не буде';

  @override
  String get unitDays => 'днів';

  @override
  String get unitWeeks => 'тижнів';

  @override
  String get unitMonths => 'місяців';

  @override
  String get unitYears => 'років';

  @override
  String get repeatAdvEnd => 'Закінчення';

  @override
  String get repeatAdvNotSet => 'Не вибрана';

  @override
  String get repeatAdvMonthRule => 'Правило місяця';

  @override
  String get repeatAdvByDate => 'За числом';

  @override
  String get repeatAdvByPosition => 'За позицією';

  @override
  String get repeatAdvSkipped => 'Пропущені дати';

  @override
  String get repeatAdvExceptions => 'Винятки';

  @override
  String get repeatAdvShiftFirst => 'Зсувати разом із першим';

  @override
  String get repeatAdvShiftHint => 'Перенесення першої дати рухає весь ряд';

  @override
  String get repeatAdvHolidays => 'Не повторювати у свята';

  @override
  String get repeatAdvHolidaysHint => 'З урахуванням свят країни';

  @override
  String get repeatAdvParsed =>
      'Розібрано в правило · натисніть, щоб застосувати';

  @override
  String get weekSetupCancel => 'Скасувати';

  @override
  String get searchInCalendar => 'Пошук';

  @override
  String monthMore(int count) {
    return 'ще $count';
  }

  @override
  String eventCancelOn(String date) {
    return 'Скасувати $date';
  }

  @override
  String get eventDeleteSeries => 'Видалити весь ряд';

  @override
  String get untitled => 'Без назви';

  @override
  String msgCancelledNamed(String title) {
    return '«$title» скасовано';
  }

  @override
  String get iconPickerTitle => 'Іконка';

  @override
  String get iconSearchHint => 'Знайти іконку (англійською)';

  @override
  String get iconPickerCommon => 'Ходові';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Знайшлося $count',
      few: 'Знайшлося $count',
      one: 'Знайшлася $count',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'За часом доби';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Чистий чорний фон у темній темі';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint => 'Колір із шпалер системи (Android 12+)';

  @override
  String get settingsStartScreen => 'Стартовий екран';

  @override
  String get settingsStartScreenHint => 'З нього відкривається застосунок';

  @override
  String get settingsStartView => 'Вигляд на старті';

  @override
  String get placeHere => 'Я тут';

  @override
  String get placeSearchHint => 'Вулиця, заклад, місто';

  @override
  String get placeSearching => 'Шукаю…';

  @override
  String get placeNoFix =>
      'Не вдалося визначити місце: немає дозволу або сигналу.';

  @override
  String get msgSaveFailed => 'Не вдалося зберегти';

  @override
  String get msgNotSaved => 'Зміни не збережено';

  @override
  String get syncTitle => 'Синхронізація';

  @override
  String get syncOff => 'Вимкнена, календар лише тут';

  @override
  String get syncClean => 'Усе надіслано';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count правок чекають',
      few: '$count правки чекають',
      one: '$count правка чекає',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Підключити сервер';

  @override
  String get syncServerAddress => 'Адреса сервера';

  @override
  String get syncCode => 'Код із першого пристрою';

  @override
  String get syncCodeHint => 'Порожньо — це перший пристрій';

  @override
  String get syncDeviceName => 'Телефон';

  @override
  String get syncConnected => 'Сервер підключено';

  @override
  String get syncFailed => 'Не вийшло';

  @override
  String syncDone(int sent, int received) {
    return 'Надіслано $sent, отримано $received';
  }

  @override
  String get syncPairTitle => 'Код для другого пристрою';

  @override
  String get syncPairHint => 'Показати й ввести на іншому';

  @override
  String get syncDisconnect => 'Відключити сервер';

  @override
  String get syncDisconnectHint => 'Дані залишаться на пристрої';

  @override
  String get accessNeedsSync =>
      'Ключі з’являться, коли ввімкнете синхронізацію';

  @override
  String get accessNoKeys => 'Жодного ключа';

  @override
  String get accessLoading => 'Завантажую…';

  @override
  String get accessKeyName => 'Ім’я агента';

  @override
  String get accessScopesHint =>
      'Які календарі бачить ключ і де йому можна писати';

  @override
  String get accessReadOnly => 'Лише читання';

  @override
  String get accessWrite => 'Читання й запис';

  @override
  String get accessKeyOnce => 'Ключ показується один раз';

  @override
  String get accessKeyOnceHint =>
      'Скопіюйте його в агента зараз: на сервері лишився тільки хеш, і відновити рядок нізвідки.';

  @override
  String accessLastUsed(String when) {
    return 'Працював $when';
  }

  @override
  String get accessNeverUsed => 'Ще не працював';

  @override
  String get accessRevoked => 'Відкликано';

  @override
  String get accessLog => 'Журнал';

  @override
  String get accessLogEmpty => 'Ключ поки нічого не чіпав';

  @override
  String get photosTitle => 'Знімки';

  @override
  String get photoAdd => 'Додати знімок';

  @override
  String get photoCamera => 'Зняти';

  @override
  String get photoGallery => 'З галереї';

  @override
  String get photoRemove => 'Прибрати знімок';

  @override
  String get photoRemoveAsk => 'Прибрати цей знімок?';

  @override
  String get photoNeedsSave => 'Знімки з’являться, коли подію збережено';

  @override
  String get navTasks => 'Завдання';

  @override
  String get tasksEmpty => 'Завдань поки немає';

  @override
  String get tasksEmptyHint => 'Кнопка внизу створює першу';

  @override
  String get taskNew => 'Нове завдання';

  @override
  String get taskOne => 'Завдання';

  @override
  String get taskTitleHint => 'Що зробити';

  @override
  String get taskDue => 'Термін';

  @override
  String get taskNoDue => 'Без терміну';

  @override
  String get taskAtTime => 'На час';

  @override
  String get taskNotes => 'Нотатка';

  @override
  String get taskNotesHint => 'Подробиці';

  @override
  String get taskDelete => 'Видалити завдання';

  @override
  String get taskOverdue => 'Прострочено';

  @override
  String get tasksDoneSection => 'Зроблені';

  @override
  String tasksOpenCount(int count) {
    return '$count у роботі';
  }

  @override
  String get msgTaskDeleted => 'Завдання видалено';

  @override
  String get dueToday => 'Сьогодні';

  @override
  String get dueTomorrow => 'Завтра';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsWeek => 'Тиждень';

  @override
  String get statsMonth => 'Місяць';

  @override
  String get statsYear => 'Рік';

  @override
  String get statsBusyTime => 'Зайнято часу';

  @override
  String get statsEventCount => 'Подій';

  @override
  String get statsTasksClosed => 'Завдань закрито';

  @override
  String get statsPerDay => 'У середньому за день';

  @override
  String get statsByCalendar => 'За календарями';

  @override
  String get statsByWeekday => 'За днями тижня';

  @override
  String get statsBusiestDay => 'Найщільніший день';

  @override
  String get statsEmpty => 'За цей період записів немає';

  @override
  String statsHoursShort(String hours) {
    return '$hours год';
  }

  @override
  String statsShare(int percent) {
    return '$percent%';
  }

  @override
  String get colorSaved => 'Колір у «Моїх»';

  @override
  String get colorAlreadySaved => 'Такий колір уже збережено';

  @override
  String get colorRemovedFromMine => 'Прибрано з «Моїх»';

  @override
  String get colorCopied => 'Код скопійовано';

  @override
  String get colorCopy => 'Скопіювати код';

  @override
  String get colorPickFromImage => 'Узяти колір із зображення';

  @override
  String get colorTapImage =>
      'Натисніть на зображення — колір візьметься звідти';

  @override
  String get colorHexHint => 'Свій код';

  @override
  String scopeOnlyHint(String day) {
    return '$day стане по-новому, решта не зміниться';
  }

  @override
  String get scopeDeleteTitle => 'Що видалити';

  @override
  String scopeDeleteOnlyHint(String day) {
    return '$day зникне, ряд залишиться';
  }

  @override
  String get scopeDeleteFollowingHint =>
      'Ряд обірветься на цій даті, минулі заняття залишаться';

  @override
  String get scopeDeleteWholeHint => 'Зникнуть усі заняття, зокрема минулі';

  @override
  String get msgSeriesTrimmed => 'Ряд обірвано на цій даті';

  @override
  String get eventDuplicate => 'Зробити копію';

  @override
  String eventCopySuffix(String title) {
    return '$title — копія';
  }

  @override
  String get moveTitle => 'Перенести';

  @override
  String get moveTomorrow => 'На завтра';

  @override
  String get moveNextWeek => 'Через тиждень';

  @override
  String get movePickDate => 'Вибрати дату';

  @override
  String msgEventMoved(String day) {
    return 'Подію перенесено на $day';
  }

  @override
  String get actionShare => 'Поділитися';

  @override
  String get msgEventCopiedText => 'Подію скопійовано текстом';

  @override
  String get eventOpenMap => 'Відкрити на карті';

  @override
  String get previewActions => 'Дії';

  @override
  String get seriesPause => 'Пауза ряду';

  @override
  String seriesPauseWeeks(int weeks) {
    return 'Не буде $weeks тижн.';
  }

  @override
  String msgSeriesPaused(int count) {
    return 'Пропущено занять: $count';
  }

  @override
  String get lookReset => 'Як у гілки';

  @override
  String get msgLookReset => 'Колір та іконка знову успадковуються';

  @override
  String get toTask => 'Зробити завданням';

  @override
  String get msgBecameTask => 'Подія стала завданням';

  @override
  String get shiftRest => 'Зсунути решту дня';

  @override
  String msgDayShifted(int count) {
    return 'Зсунуто слідом: $count';
  }

  @override
  String get repeatDay => 'Повторити день';

  @override
  String msgDayCopied(String day, int count) {
    return 'День перенесено на $day: подій $count';
  }

  @override
  String get stretchToNext => 'Розтягнути до наступного';

  @override
  String msgStretched(String time) {
    return 'Подія триває до $time';
  }

  @override
  String get nothingToShift => 'Далі цього дня нічого немає';

  @override
  String msgEventShifted(String time) {
    return 'Подія о $time';
  }

  @override
  String msgEventResized(String time) {
    return 'Тепер до $time';
  }

  @override
  String msgOverlaps(String title) {
    return 'Перетинається: $title';
  }

  @override
  String get quickPhraseHint => 'Дзвінок завтра о 15:00 на годину';

  @override
  String get quickPhraseRead => 'Зрозумів із рядка';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navList => 'Список';

  @override
  String get navAccess => 'Доступ';

  @override
  String get navSettings => 'Настройки';

  @override
  String get viewDay => 'День';

  @override
  String get viewDays => 'Дни';

  @override
  String get viewWeek => 'Неделя';

  @override
  String get viewMonth => 'Месяц';

  @override
  String get readingClock => 'Часы';

  @override
  String get readingChain => 'Цепочка';

  @override
  String get viewNotBuilt => 'Вид ещё не собран';

  @override
  String get newEvent => 'Новое событие';

  @override
  String get today => 'сегодня';

  @override
  String get nothingPlanned => 'Ничего не запланировано';

  @override
  String durationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String durationHours(int hours) {
    return '$hours ч';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String spanDayOf(int current, int total) {
    return '$current-й из $total';
  }

  @override
  String spanUntil(String date) {
    return 'до $date';
  }

  @override
  String get actionDone => 'Готово';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionUndo => 'Вернуть';

  @override
  String get fieldName => 'Название';

  @override
  String get calendarsTitle => 'Календари';

  @override
  String get calendarOne => 'Календарь';

  @override
  String get calendarNewShort => 'Новый';

  @override
  String get calendarNew => 'Новый календарь';

  @override
  String get calendarCreate => 'Завести календарь';

  @override
  String get calendarsEmptyTitle => 'Ни одного календаря';

  @override
  String get calendarsEmptyBody =>
      'Календарь задаёт цвет и иконку всем событиям внутри. Обычно их три-четыре: дом, работа, учёба, спорт.';

  @override
  String get branchOne => 'Ветка';

  @override
  String get branchNone => 'Без веток';

  @override
  String get branchAdd => 'Добавить ветку';

  @override
  String branchOf(String name) {
    return 'Ветка «$name»';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count веток',
      few: '$count ветки',
      one: '$count ветка',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'Наследует';

  @override
  String get colorOwn => 'Свой цвет';

  @override
  String get fieldsTitle => 'Свои поля';

  @override
  String get fieldsShared => 'Общие для всех';

  @override
  String get fieldsSharedRow => 'Общие поля';

  @override
  String get fieldsGroups => 'Группы';

  @override
  String get fieldsNoneYet => 'Пока ни одного';

  @override
  String get fieldsGroupEmpty => 'Без своих полей';

  @override
  String get fieldsGroupCreate => 'Создать группу полей';

  @override
  String get fieldsGroupNew => 'Новая группа';

  @override
  String fieldAddTo(String name) {
    return 'Добавить поле в «$name»';
  }

  @override
  String fieldNewIn(String name) {
    return 'Новое поле в «$name»';
  }

  @override
  String get fieldOne => 'Поле';

  @override
  String get fieldShared => 'Общее';

  @override
  String get fieldNamePlaceholder => 'Название поля';

  @override
  String get fieldKind => 'Чем заполнять';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count своих полей',
      few: '$count своих поля',
      one: '$count своё поле',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'в карточке $count';
  }

  @override
  String get fieldEraseValue => 'Стереть';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get typeText => 'Текст';

  @override
  String get typeNumber => 'Число';

  @override
  String get typeDate => 'Дата';

  @override
  String get typeTime => 'Время';

  @override
  String get typeDuration => 'Длительность';

  @override
  String get typeSelect => 'Список';

  @override
  String get typeCheckbox => 'Флажок';

  @override
  String get typeUrl => 'Ссылка';

  @override
  String get typePhone => 'Телефон';

  @override
  String get typePerson => 'Человек';

  @override
  String get typeMoney => 'Деньги';

  @override
  String get searchHint => 'Найти событие';

  @override
  String get searchEmpty =>
      'Ищите по названию, месту или своему полю — например по номеру кабинета.';

  @override
  String get searchNothing => 'Ничего не нашлось.';

  @override
  String get allDay => 'весь день';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsSystem => 'Как в системе';

  @override
  String get settingsLight => 'Светлая';

  @override
  String get settingsDark => 'Тёмная';

  @override
  String get settingsChroma => 'Насыщенность';

  @override
  String get settingsChromaHint =>
      'На фирменной мяте «Сочно» выкручивает пилюли до кислотного';

  @override
  String get settingsExact => 'Точь-в-точь';

  @override
  String get settingsVivid => 'Сочно';

  @override
  String get settingsSeed => 'Фирменный цвет';

  @override
  String get settingsCalendarGroup => 'Календарь';

  @override
  String get settingsWeekDays => 'Дни в виде «Неделя»';

  @override
  String get settingsWeekFull => 'Вся неделя';

  @override
  String get settingsWeekdaysOnly => 'Только будни';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней в неделе',
      few: '$count дня в неделе',
      one: '$count день в неделе',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Кабинет, тренер, номер абонемента';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsDataGroup => 'Данные';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get settingsStorage => 'Всё хранится на устройстве';

  @override
  String get settingsSource => 'Исходный код';

  @override
  String get monthViewTitle => 'Вид месяца';

  @override
  String get monthChips => 'Чипы с названиями';

  @override
  String get monthChipsHint => 'Видно, что именно в этот день';

  @override
  String get monthTint => 'Тонированные ячейки';

  @override
  String get monthTintHint => 'Видно, чем занят день';

  @override
  String get monthDensity => 'Плотность чипа';

  @override
  String get monthDensityBoth => 'Иконка и текст';

  @override
  String get monthDensityIcon => 'Только иконка';

  @override
  String get monthPerCell => 'Событий в ячейке';

  @override
  String get monthPerCellHint => 'Дальше сворачивать в «+N»';

  @override
  String get eventOne => 'Событие';

  @override
  String get eventWhen => 'Когда';

  @override
  String get eventTime => 'Время';

  @override
  String get eventRepeat => 'Повтор';

  @override
  String get eventCalendarAndBranch => 'Календарь и ветка';

  @override
  String get eventReminder => 'Напоминание';

  @override
  String get eventPlace => 'Место';

  @override
  String get eventPlaceHint => 'Где это будет';

  @override
  String get eventDelete => 'Удалить событие';

  @override
  String get moreDetails => 'Подробнее';

  @override
  String get lookTitle => 'Иконка и цвет';

  @override
  String get lookInherit => 'Как у календаря';

  @override
  String get lookOwnColor => 'Свой цвет';

  @override
  String get inCard => 'В карточке';

  @override
  String get notesTitle => 'Заметки';

  @override
  String get noteOne => 'Заметка';

  @override
  String get noteAdd => 'Добавить заметку';

  @override
  String get noteHint => 'Что не забыть';

  @override
  String get repeatNone => 'Не повторяется';

  @override
  String get repeatByRule => 'По правилу';

  @override
  String get repeatTitle => 'Повторение';

  @override
  String get repeatDaily => 'Каждый день';

  @override
  String get repeatWeekly => 'Каждую неделю';

  @override
  String get repeatEvery => 'Каждые';

  @override
  String get repeatEndsWhen => 'Когда заканчивается';

  @override
  String get repeatNextDates => 'Ближайшие даты';

  @override
  String get repeatNever => 'Никогда';

  @override
  String get repeatUntilDate => 'До даты';

  @override
  String repeatAfterCount(int count) {
    return 'После $count повторов';
  }

  @override
  String get unitDay => 'День';

  @override
  String get unitWeek => 'Неделя';

  @override
  String get unitMonth => 'Месяц';

  @override
  String get unitYear => 'Год';

  @override
  String get scopeTitle => 'Что изменить';

  @override
  String scopeRepeats(String label) {
    return 'Занятие повторяется: $label';
  }

  @override
  String get scopeOnly => 'Только это занятие';

  @override
  String get scopeFollowing => 'Это и следующие';

  @override
  String get scopeFollowingHint =>
      'Ряд разделится: прошедшие занятия останутся как были';

  @override
  String get scopeWhole => 'Весь ряд';

  @override
  String get scopeWholeHint => 'Все занятия, включая прошедшие';

  @override
  String get msgEventDeleted => 'Событие удалено';

  @override
  String get msgSeriesDeleted => 'Ряд удалён';

  @override
  String get msgOccurrenceSkipped => 'Занятие отменено';

  @override
  String get reminderNone => 'Без напоминания';

  @override
  String get reminderAtStart => 'В момент начала';

  @override
  String get reminderNever => 'Не напоминать';

  @override
  String get reminderHint =>
      'Можно несколько: за день собраться, за десять минут выйти';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count минут',
      few: 'За $count минуты',
      one: 'За $count минуту',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count часов',
      few: 'За $count часа',
      one: 'За час',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count дней',
      few: 'За $count дня',
      one: 'За день',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'За неделю';

  @override
  String get reminderStarts => 'Начинается';

  @override
  String reminderStartsAt(String time) {
    return 'Начало в $time';
  }

  @override
  String get icsExport => 'Выгрузить в .ics';

  @override
  String get icsExportHint => 'Файл для другого календаря';

  @override
  String get icsImport => 'Загрузить из .ics';

  @override
  String get icsImportHint => 'События из чужого календаря';

  @override
  String get icsSaveTitle => 'Куда сохранить календарь';

  @override
  String get icsPickTitle => 'Выберите файл календаря';

  @override
  String get icsNothingToExport => 'Выгружать нечего: событий нет.';

  @override
  String icsExported(int count) {
    return 'Выгружено событий: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Загружено событий: $count.';
  }

  @override
  String get icsUnreadable => 'Файл не прочитался.';

  @override
  String get icsNoEvents => 'В файле не нашлось ни одного события.';

  @override
  String get colorPickerOwn => 'Свой цвет';

  @override
  String get colorHue => 'Оттенок';

  @override
  String get colorChroma => 'Насыщенность';

  @override
  String get colorTone => 'Светлота';

  @override
  String get colorMine => 'Мои цвета';

  @override
  String get colorRecent => 'Последние';

  @override
  String get colorSaveMine => 'В мои';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Оттенок $hue° · насыщенность $chroma · светлота $tone';
  }

  @override
  String get colorPickerHint =>
      'Пипетка берёт цвет с картинки: откройте снимок экрана или фотографию и нажмите на нужное место. Сохранённые живут в «Моих цветах» и доступны из любого пикера приложения.';

  @override
  String get branchColorTitle => 'Цвет ветки';

  @override
  String get branchColorOwnHint => 'Задан у этой ветки';

  @override
  String branchColorOfCalendar(String name) {
    return 'Цвет «$name»';
  }

  @override
  String get branchColorPickerRow => 'Свой цвет из пикера';

  @override
  String get branchColorPickerHint => 'Оттенок, насыщенность, hex, пипетка';

  @override
  String branchColorChain(String name) {
    return 'Перекрасите «$name» — сменят цвет все ветки и события, где стоит наследование. Ветки со своим цветом останутся как есть.';
  }

  @override
  String get branchColorEventRow => 'Событие ветки';

  @override
  String get levelCalendar => 'Календарь';

  @override
  String get levelOwn => 'Свой';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'каждые $count дней',
      few: 'каждые $count дня',
      one: 'каждый день',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'каждые $count недель',
      few: 'каждые $count недели',
      one: 'каждую неделю',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'каждые $count месяцев',
      few: 'каждые $count месяца',
      one: 'каждый месяц',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'каждый год';

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
      'последний,последний,последняя,последний,последняя,последняя,последнее';

  @override
  String get ordinal1 => 'первый,первый,первая,первый,первая,первая,первое';

  @override
  String get ordinal2 => 'второй,второй,вторая,второй,вторая,вторая,второе';

  @override
  String get ordinal3 => 'третий,третий,третья,третий,третья,третья,третье';

  @override
  String get ordinal4 =>
      'четвёртый,четвёртый,четвёртая,четвёртый,четвёртая,четвёртая,четвёртое';

  @override
  String get weekSetupTitle => 'Какие дни показывать';

  @override
  String get weekSetupHint => 'Колонок будет столько, сколько дней отмечено';

  @override
  String get weekSetupAll => 'Вся неделя';

  @override
  String get weekSetupWorkdays => 'Будни';

  @override
  String get weekSetupWeekend => 'Выходные';

  @override
  String get weekSetupStartsWith => 'Неделя начинается с';

  @override
  String get accessTitle => 'Доступ';

  @override
  String get accessCreateKey => 'Создать ключ';

  @override
  String get accessRevoke => 'Отозвать';

  @override
  String get accessHint =>
      'Ключи работают, пока включена синхронизация. Календарь, который живёт только на телефоне, снаружи недоступен — стучаться некуда.';

  @override
  String get repeatNever2 => 'Не повторять';

  @override
  String get repeatWeekdays => 'По будням';

  @override
  String get repeatCountLabel => 'Повторов';

  @override
  String get repeatTimes => 'раз';

  @override
  String get repeatAfterSome => 'После нескольких повторов';

  @override
  String get repeatNoDates => 'По такому правилу занятий не будет';

  @override
  String get unitDays => 'дня';

  @override
  String get unitWeeks => 'недели';

  @override
  String get unitMonths => 'месяца';

  @override
  String get unitYears => 'года';

  @override
  String get repeatAdvEnd => 'Окончание';

  @override
  String get repeatAdvNotSet => 'Не выбрана';

  @override
  String get repeatAdvMonthRule => 'Правило месяца';

  @override
  String get repeatAdvByDate => 'По числу';

  @override
  String get repeatAdvByPosition => 'По позиции';

  @override
  String get repeatAdvSkipped => 'Пропущенные даты';

  @override
  String get repeatAdvExceptions => 'Исключения';

  @override
  String get repeatAdvShiftFirst => 'Сдвигать вместе с первым';

  @override
  String get repeatAdvShiftHint => 'Перенос первой даты двигает весь ряд';

  @override
  String get repeatAdvHolidays => 'Не повторять в праздники';

  @override
  String get repeatAdvHolidaysHint => 'С учётом праздников страны';

  @override
  String get repeatAdvParsed =>
      'Разобрано в правило · нажмите, чтобы применить';

  @override
  String get weekSetupCancel => 'Отмена';

  @override
  String get searchInCalendar => 'Поиск';

  @override
  String monthMore(int count) {
    return 'ещё $count';
  }

  @override
  String eventCancelOn(String date) {
    return 'Отменить $date';
  }

  @override
  String get eventDeleteSeries => 'Удалить весь ряд';

  @override
  String get untitled => 'Без названия';

  @override
  String msgCancelledNamed(String title) {
    return '«$title» отменено';
  }

  @override
  String get iconPickerTitle => 'Иконка';

  @override
  String get iconSearchHint => 'Найти иконку (по-английски)';

  @override
  String get iconPickerCommon => 'Ходовые';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Нашлось $count',
      few: 'Нашлось $count',
      one: 'Нашлась $count',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'По времени суток';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Чистый чёрный фон в тёмной теме';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint => 'Цвет из обоев системы (Android 12+)';

  @override
  String get settingsStartScreen => 'Стартовый экран';

  @override
  String get settingsStartScreenHint => 'С него открывается приложение';

  @override
  String get settingsStartView => 'Вид на старте';

  @override
  String get placeHere => 'Я здесь';

  @override
  String get placeSearchHint => 'Улица, заведение, город';

  @override
  String get placeSearching => 'Ищу…';

  @override
  String get placeNoFix =>
      'Не вышло определить место: нет разрешения или сигнала.';

  @override
  String get msgSaveFailed => 'Не удалось сохранить';

  @override
  String get msgNotSaved => 'Изменения не сохранены';

  @override
  String get syncTitle => 'Синхронизация';

  @override
  String get syncOff => 'Выключена, календарь только здесь';

  @override
  String get syncClean => 'Всё отправлено';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count правок ждут',
      few: '$count правки ждут',
      one: '$count правка ждёт',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Подключить сервер';

  @override
  String get syncServerAddress => 'Адрес сервера';

  @override
  String get syncCode => 'Код с первого устройства';

  @override
  String get syncCodeHint => 'Пусто — это первое устройство';

  @override
  String get syncDeviceName => 'Телефон';

  @override
  String get syncConnected => 'Сервер подключён';

  @override
  String get syncFailed => 'Не вышло';

  @override
  String syncDone(int sent, int received) {
    return 'Отправлено $sent, получено $received';
  }

  @override
  String get syncPairTitle => 'Код для второго устройства';

  @override
  String get syncPairHint => 'Показать и ввести на другом';

  @override
  String get syncDisconnect => 'Отключить сервер';

  @override
  String get syncDisconnectHint => 'Данные останутся на устройстве';

  @override
  String get accessNeedsSync => 'Ключи появятся, когда включите синхронизацию';

  @override
  String get accessNoKeys => 'Ни одного ключа';

  @override
  String get accessLoading => 'Загружаю…';

  @override
  String get accessKeyName => 'Имя агента';

  @override
  String get accessScopesHint =>
      'Какие календари видит ключ и где ему можно писать';

  @override
  String get accessReadOnly => 'Только чтение';

  @override
  String get accessWrite => 'Чтение и запись';

  @override
  String get accessKeyOnce => 'Ключ показывается один раз';

  @override
  String get accessKeyOnceHint =>
      'Скопируйте его в агента сейчас: на сервере остался только хеш, и восстановить строку неоткуда.';

  @override
  String accessLastUsed(String when) {
    return 'Работал $when';
  }

  @override
  String get accessNeverUsed => 'Ещё не работал';

  @override
  String get accessRevoked => 'Отозван';

  @override
  String get accessLog => 'Журнал';

  @override
  String get accessLogEmpty => 'Ключ пока ничего не трогал';

  @override
  String get photosTitle => 'Снимки';

  @override
  String get photoAdd => 'Добавить снимок';

  @override
  String get photoCamera => 'Снять';

  @override
  String get photoGallery => 'Из галереи';

  @override
  String get photoRemove => 'Убрать снимок';

  @override
  String get photoRemoveAsk => 'Убрать этот снимок?';

  @override
  String get photoNeedsSave => 'Снимки появятся, когда событие сохранено';

  @override
  String get navTasks => 'Задачи';

  @override
  String get tasksEmpty => 'Задач пока нет';

  @override
  String get tasksEmptyHint => 'Кнопка внизу заводит первую';

  @override
  String get taskNew => 'Новая задача';

  @override
  String get taskOne => 'Задача';

  @override
  String get taskTitleHint => 'Что сделать';

  @override
  String get taskDue => 'Срок';

  @override
  String get taskNoDue => 'Без срока';

  @override
  String get taskAtTime => 'Ко времени';

  @override
  String get taskNotes => 'Заметка';

  @override
  String get taskNotesHint => 'Подробности';

  @override
  String get taskDelete => 'Удалить задачу';

  @override
  String get taskOverdue => 'Просрочена';

  @override
  String get tasksDoneSection => 'Сделанные';

  @override
  String tasksOpenCount(int count) {
    return '$count в работе';
  }

  @override
  String get msgTaskDeleted => 'Задача удалена';

  @override
  String get dueToday => 'Сегодня';

  @override
  String get dueTomorrow => 'Завтра';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsWeek => 'Неделя';

  @override
  String get statsMonth => 'Месяц';

  @override
  String get statsYear => 'Год';

  @override
  String get statsBusyTime => 'Занято времени';

  @override
  String get statsEventCount => 'Событий';

  @override
  String get statsTasksClosed => 'Задач закрыто';

  @override
  String get statsPerDay => 'В среднем за день';

  @override
  String get statsByCalendar => 'По календарям';

  @override
  String get statsByWeekday => 'По дням недели';

  @override
  String get statsBusiestDay => 'Самый плотный день';

  @override
  String get statsEmpty => 'За этот период записей нет';

  @override
  String statsHoursShort(String hours) {
    return '$hours ч';
  }

  @override
  String statsShare(int percent) {
    return '$percent%';
  }

  @override
  String get colorSaved => 'Цвет в «Моих»';

  @override
  String get colorAlreadySaved => 'Такой цвет уже сохранён';

  @override
  String get colorRemovedFromMine => 'Убрано из «Моих»';

  @override
  String get colorCopied => 'Код скопирован';

  @override
  String get colorCopy => 'Скопировать код';

  @override
  String get colorPickFromImage => 'Взять цвет с картинки';

  @override
  String get colorTapImage => 'Нажмите на картинку — цвет возьмётся оттуда';

  @override
  String get colorHexHint => 'Свой код';

  @override
  String scopeOnlyHint(String day) {
    return '$day встанет по-новому, остальные не тронутся';
  }

  @override
  String get scopeDeleteTitle => 'Что удалить';

  @override
  String scopeDeleteOnlyHint(String day) {
    return '$day исчезнет, ряд останется';
  }

  @override
  String get scopeDeleteFollowingHint =>
      'Ряд оборвётся на этой дате, прошедшие занятия останутся';

  @override
  String get scopeDeleteWholeHint => 'Исчезнут все занятия, включая прошедшие';

  @override
  String get msgSeriesTrimmed => 'Ряд оборван на этой дате';

  @override
  String get eventDuplicate => 'Сделать копию';

  @override
  String eventCopySuffix(String title) {
    return '$title — копия';
  }

  @override
  String get moveTitle => 'Перенести';

  @override
  String get moveTomorrow => 'На завтра';

  @override
  String get moveNextWeek => 'Через неделю';

  @override
  String get movePickDate => 'Выбрать дату';

  @override
  String msgEventMoved(String day) {
    return 'Событие перенесено на $day';
  }

  @override
  String get actionShare => 'Поделиться';

  @override
  String get msgEventCopiedText => 'Событие скопировано текстом';

  @override
  String get eventOpenMap => 'Открыть на карте';

  @override
  String get previewActions => 'Действия';

  @override
  String get seriesPause => 'Пауза ряда';

  @override
  String seriesPauseWeeks(int weeks) {
    return 'Не будет $weeks нед.';
  }

  @override
  String msgSeriesPaused(int count) {
    return 'Пропущено занятий: $count';
  }

  @override
  String get lookReset => 'Как у ветки';

  @override
  String get msgLookReset => 'Цвет и иконка снова наследуются';

  @override
  String get toTask => 'Сделать задачей';

  @override
  String get msgBecameTask => 'Событие стало задачей';

  @override
  String get shiftRest => 'Сдвинуть остаток дня';

  @override
  String msgDayShifted(int count) {
    return 'Сдвинуто следом: $count';
  }

  @override
  String get repeatDay => 'Повторить день';

  @override
  String msgDayCopied(String day, int count) {
    return 'День перенесён на $day: событий $count';
  }

  @override
  String get stretchToNext => 'Растянуть до следующего';

  @override
  String msgStretched(String time) {
    return 'Событие идёт до $time';
  }

  @override
  String get nothingToShift => 'Дальше в этом дне ничего нет';

  @override
  String msgEventShifted(String time) {
    return 'Событие в $time';
  }

  @override
  String msgEventResized(String time) {
    return 'Теперь до $time';
  }

  @override
  String msgOverlaps(String title) {
    return 'Пересекается: $title';
  }

  @override
  String get quickPhraseHint => 'Созвон завтра в 15:00 на час';

  @override
  String get quickPhraseRead => 'Понял из строки';

  @override
  String get findSlot => 'Ближайшее окно';

  @override
  String msgSlotFound(String when) {
    return 'Свободно: $when';
  }

  @override
  String get msgNoSlot => 'В ближайшие две недели окна нет';

  @override
  String get trashTitle => 'Корзина';

  @override
  String get trashHint => 'Удалённое хранится 90 дней';

  @override
  String get trashEmpty => 'Корзина пуста';

  @override
  String get trashRestore => 'Вернуть';

  @override
  String get trashClear => 'Очистить корзину';

  @override
  String msgTrashCleared(int count) {
    return 'Убрано записей: $count';
  }

  @override
  String msgRestored(String title) {
    return 'Возвращено: $title';
  }

  @override
  String get calendarDefaults => 'По умолчанию';

  @override
  String get calendarDefaultReminder => 'Напоминание у новых событий';

  @override
  String get calendarDefaultDuration => 'Длительность у новых событий';

  @override
  String get actionSelect => 'Выбрать несколько';

  @override
  String selectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get bulkMove => 'Перенести';

  @override
  String get bulkCalendar => 'В календарь';

  @override
  String msgBulkMoved(int count) {
    return 'Перенесено событий: $count';
  }

  @override
  String msgBulkDeleted(int count) {
    return 'Удалено событий: $count';
  }

  @override
  String msgBulkCalendar(int count) {
    return 'Событий в другом календаре: $count';
  }

  @override
  String get eventOpenEnd => 'Без окончания';

  @override
  String timeFrom(String time) {
    return 'с $time';
  }

  @override
  String get noteMarkupHint => '«- » — пункт списка, «[ ] » — галочка';

  @override
  String get dayReviewTitle => 'Разбор дня';

  @override
  String get dayReviewBusy => 'Занято';

  @override
  String get dayReviewFree => 'Свободно';

  @override
  String get dayReviewLongest => 'Самое долгое';

  @override
  String dayReviewClashes(int count) {
    return 'Накладок: $count';
  }

  @override
  String get dayReviewGaps => 'Куда можно двигать';

  @override
  String get dayReviewNoBreaks => 'День без единого перерыва';

  @override
  String get dayReviewEmpty => 'В этот день ничего не назначено';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('pl'),
    Locale('ro'),
    Locale('ru'),
    Locale('uk'),
  ];

  /// navCalendar
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get navCalendar;

  /// navList
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get navList;

  /// navAccess
  ///
  /// In ru, this message translates to:
  /// **'Доступ'**
  String get navAccess;

  /// navSettings
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// viewDay
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get viewDay;

  /// viewDays
  ///
  /// In ru, this message translates to:
  /// **'Дни'**
  String get viewDays;

  /// viewWeek
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get viewWeek;

  /// viewMonth
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get viewMonth;

  /// readingClock
  ///
  /// In ru, this message translates to:
  /// **'Часы'**
  String get readingClock;

  /// readingChain
  ///
  /// In ru, this message translates to:
  /// **'Цепочка'**
  String get readingChain;

  /// viewNotBuilt
  ///
  /// In ru, this message translates to:
  /// **'Вид ещё не собран'**
  String get viewNotBuilt;

  /// newEvent
  ///
  /// In ru, this message translates to:
  /// **'Новое событие'**
  String get newEvent;

  /// today
  ///
  /// In ru, this message translates to:
  /// **'сегодня'**
  String get today;

  /// nothingPlanned
  ///
  /// In ru, this message translates to:
  /// **'Ничего не запланировано'**
  String get nothingPlanned;

  /// durationMinutes
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String durationMinutes(int minutes);

  /// durationHours
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч'**
  String durationHours(int hours);

  /// durationHoursMinutes
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч {minutes} мин'**
  String durationHoursMinutes(int hours, int minutes);

  /// spanDayOf
  ///
  /// In ru, this message translates to:
  /// **'{current}-й из {total}'**
  String spanDayOf(int current, int total);

  /// spanUntil
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String spanUntil(String date);

  /// actionDone
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get actionDone;

  /// actionCancel
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get actionCancel;

  /// actionDelete
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get actionDelete;

  /// actionSave
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get actionSave;

  /// actionAdd
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get actionAdd;

  /// actionEdit
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get actionEdit;

  /// actionUndo
  ///
  /// In ru, this message translates to:
  /// **'Вернуть'**
  String get actionUndo;

  /// fieldName
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get fieldName;

  /// calendarsTitle
  ///
  /// In ru, this message translates to:
  /// **'Календари'**
  String get calendarsTitle;

  /// calendarOne
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get calendarOne;

  /// calendarNewShort
  ///
  /// In ru, this message translates to:
  /// **'Новый'**
  String get calendarNewShort;

  /// calendarNew
  ///
  /// In ru, this message translates to:
  /// **'Новый календарь'**
  String get calendarNew;

  /// calendarCreate
  ///
  /// In ru, this message translates to:
  /// **'Завести календарь'**
  String get calendarCreate;

  /// calendarsEmptyTitle
  ///
  /// In ru, this message translates to:
  /// **'Ни одного календаря'**
  String get calendarsEmptyTitle;

  /// calendarsEmptyBody
  ///
  /// In ru, this message translates to:
  /// **'Календарь задаёт цвет и иконку всем событиям внутри. Обычно их три-четыре: дом, работа, учёба, спорт.'**
  String get calendarsEmptyBody;

  /// branchOne
  ///
  /// In ru, this message translates to:
  /// **'Ветка'**
  String get branchOne;

  /// branchNone
  ///
  /// In ru, this message translates to:
  /// **'Без веток'**
  String get branchNone;

  /// branchAdd
  ///
  /// In ru, this message translates to:
  /// **'Добавить ветку'**
  String get branchAdd;

  /// branchOf
  ///
  /// In ru, this message translates to:
  /// **'Ветка «{name}»'**
  String branchOf(String name);

  /// branchCount
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} ветка} few{{count} ветки} other{{count} веток}}'**
  String branchCount(int count);

  /// colorInherits
  ///
  /// In ru, this message translates to:
  /// **'Наследует'**
  String get colorInherits;

  /// colorOwn
  ///
  /// In ru, this message translates to:
  /// **'Свой цвет'**
  String get colorOwn;

  /// fieldsTitle
  ///
  /// In ru, this message translates to:
  /// **'Свои поля'**
  String get fieldsTitle;

  /// fieldsShared
  ///
  /// In ru, this message translates to:
  /// **'Общие для всех'**
  String get fieldsShared;

  /// fieldsSharedRow
  ///
  /// In ru, this message translates to:
  /// **'Общие поля'**
  String get fieldsSharedRow;

  /// fieldsGroups
  ///
  /// In ru, this message translates to:
  /// **'Группы'**
  String get fieldsGroups;

  /// fieldsNoneYet
  ///
  /// In ru, this message translates to:
  /// **'Пока ни одного'**
  String get fieldsNoneYet;

  /// fieldsGroupEmpty
  ///
  /// In ru, this message translates to:
  /// **'Без своих полей'**
  String get fieldsGroupEmpty;

  /// fieldsGroupCreate
  ///
  /// In ru, this message translates to:
  /// **'Создать группу полей'**
  String get fieldsGroupCreate;

  /// fieldsGroupNew
  ///
  /// In ru, this message translates to:
  /// **'Новая группа'**
  String get fieldsGroupNew;

  /// fieldAddTo
  ///
  /// In ru, this message translates to:
  /// **'Добавить поле в «{name}»'**
  String fieldAddTo(String name);

  /// fieldNewIn
  ///
  /// In ru, this message translates to:
  /// **'Новое поле в «{name}»'**
  String fieldNewIn(String name);

  /// fieldOne
  ///
  /// In ru, this message translates to:
  /// **'Поле'**
  String get fieldOne;

  /// fieldShared
  ///
  /// In ru, this message translates to:
  /// **'Общее'**
  String get fieldShared;

  /// fieldNamePlaceholder
  ///
  /// In ru, this message translates to:
  /// **'Название поля'**
  String get fieldNamePlaceholder;

  /// fieldKind
  ///
  /// In ru, this message translates to:
  /// **'Чем заполнять'**
  String get fieldKind;

  /// fieldsOwnCount
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} своё поле} few{{count} своих поля} other{{count} своих полей}}'**
  String fieldsOwnCount(int count);

  /// fieldsInCard
  ///
  /// In ru, this message translates to:
  /// **'в карточке {count}'**
  String fieldsInCard(int count);

  /// fieldEraseValue
  ///
  /// In ru, this message translates to:
  /// **'Стереть'**
  String get fieldEraseValue;

  /// yes
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yes;

  /// no
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get no;

  /// typeText
  ///
  /// In ru, this message translates to:
  /// **'Текст'**
  String get typeText;

  /// typeNumber
  ///
  /// In ru, this message translates to:
  /// **'Число'**
  String get typeNumber;

  /// typeDate
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get typeDate;

  /// typeTime
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get typeTime;

  /// typeDuration
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get typeDuration;

  /// typeSelect
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get typeSelect;

  /// typeCheckbox
  ///
  /// In ru, this message translates to:
  /// **'Флажок'**
  String get typeCheckbox;

  /// typeUrl
  ///
  /// In ru, this message translates to:
  /// **'Ссылка'**
  String get typeUrl;

  /// typePhone
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get typePhone;

  /// typePerson
  ///
  /// In ru, this message translates to:
  /// **'Человек'**
  String get typePerson;

  /// typeMoney
  ///
  /// In ru, this message translates to:
  /// **'Деньги'**
  String get typeMoney;

  /// searchHint
  ///
  /// In ru, this message translates to:
  /// **'Найти событие'**
  String get searchHint;

  /// searchEmpty
  ///
  /// In ru, this message translates to:
  /// **'Ищите по названию, месту или своему полю — например по номеру кабинета.'**
  String get searchEmpty;

  /// searchNothing
  ///
  /// In ru, this message translates to:
  /// **'Ничего не нашлось.'**
  String get searchNothing;

  /// allDay
  ///
  /// In ru, this message translates to:
  /// **'весь день'**
  String get allDay;

  /// settingsTitle
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// settingsAppearance
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// settingsTheme
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingsTheme;

  /// settingsSystem
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get settingsSystem;

  /// settingsLight
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settingsLight;

  /// settingsDark
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settingsDark;

  /// settingsChroma
  ///
  /// In ru, this message translates to:
  /// **'Насыщенность'**
  String get settingsChroma;

  /// settingsChromaHint
  ///
  /// In ru, this message translates to:
  /// **'На фирменной мяте «Сочно» выкручивает пилюли до кислотного'**
  String get settingsChromaHint;

  /// settingsExact
  ///
  /// In ru, this message translates to:
  /// **'Точь-в-точь'**
  String get settingsExact;

  /// settingsVivid
  ///
  /// In ru, this message translates to:
  /// **'Сочно'**
  String get settingsVivid;

  /// settingsSeed
  ///
  /// In ru, this message translates to:
  /// **'Фирменный цвет'**
  String get settingsSeed;

  /// settingsCalendarGroup
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get settingsCalendarGroup;

  /// settingsWeekDays
  ///
  /// In ru, this message translates to:
  /// **'Дни в виде «Неделя»'**
  String get settingsWeekDays;

  /// settingsWeekFull
  ///
  /// In ru, this message translates to:
  /// **'Вся неделя'**
  String get settingsWeekFull;

  /// settingsWeekdaysOnly
  ///
  /// In ru, this message translates to:
  /// **'Только будни'**
  String get settingsWeekdaysOnly;

  /// settingsWeekSome
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день в неделе} few{{count} дня в неделе} other{{count} дней в неделе}}'**
  String settingsWeekSome(int count);

  /// settingsFieldsHint
  ///
  /// In ru, this message translates to:
  /// **'Кабинет, тренер, номер абонемента'**
  String get settingsFieldsHint;

  /// settingsLanguage
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// settingsDataGroup
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get settingsDataGroup;

  /// settingsAbout
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// settingsVersion
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get settingsVersion;

  /// settingsStorage
  ///
  /// In ru, this message translates to:
  /// **'Всё хранится на устройстве'**
  String get settingsStorage;

  /// settingsSource
  ///
  /// In ru, this message translates to:
  /// **'Исходный код'**
  String get settingsSource;

  /// monthViewTitle
  ///
  /// In ru, this message translates to:
  /// **'Вид месяца'**
  String get monthViewTitle;

  /// monthChips
  ///
  /// In ru, this message translates to:
  /// **'Чипы с названиями'**
  String get monthChips;

  /// monthChipsHint
  ///
  /// In ru, this message translates to:
  /// **'Видно, что именно в этот день'**
  String get monthChipsHint;

  /// monthTint
  ///
  /// In ru, this message translates to:
  /// **'Тонированные ячейки'**
  String get monthTint;

  /// monthTintHint
  ///
  /// In ru, this message translates to:
  /// **'Видно, чем занят день'**
  String get monthTintHint;

  /// monthDensity
  ///
  /// In ru, this message translates to:
  /// **'Плотность чипа'**
  String get monthDensity;

  /// monthDensityBoth
  ///
  /// In ru, this message translates to:
  /// **'Иконка и текст'**
  String get monthDensityBoth;

  /// monthDensityIcon
  ///
  /// In ru, this message translates to:
  /// **'Только иконка'**
  String get monthDensityIcon;

  /// monthPerCell
  ///
  /// In ru, this message translates to:
  /// **'Событий в ячейке'**
  String get monthPerCell;

  /// monthPerCellHint
  ///
  /// In ru, this message translates to:
  /// **'Дальше сворачивать в «+N»'**
  String get monthPerCellHint;

  /// eventOne
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get eventOne;

  /// eventWhen
  ///
  /// In ru, this message translates to:
  /// **'Когда'**
  String get eventWhen;

  /// eventTime
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get eventTime;

  /// eventRepeat
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get eventRepeat;

  /// eventCalendarAndBranch
  ///
  /// In ru, this message translates to:
  /// **'Календарь и ветка'**
  String get eventCalendarAndBranch;

  /// eventReminder
  ///
  /// In ru, this message translates to:
  /// **'Напоминание'**
  String get eventReminder;

  /// eventPlace
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get eventPlace;

  /// eventPlaceHint
  ///
  /// In ru, this message translates to:
  /// **'Где это будет'**
  String get eventPlaceHint;

  /// eventDelete
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие'**
  String get eventDelete;

  /// moreDetails
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get moreDetails;

  /// lookTitle
  ///
  /// In ru, this message translates to:
  /// **'Иконка и цвет'**
  String get lookTitle;

  /// lookInherit
  ///
  /// In ru, this message translates to:
  /// **'Как у календаря'**
  String get lookInherit;

  /// lookOwnColor
  ///
  /// In ru, this message translates to:
  /// **'Свой цвет'**
  String get lookOwnColor;

  /// inCard
  ///
  /// In ru, this message translates to:
  /// **'В карточке'**
  String get inCard;

  /// notesTitle
  ///
  /// In ru, this message translates to:
  /// **'Заметки'**
  String get notesTitle;

  /// noteOne
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get noteOne;

  /// noteAdd
  ///
  /// In ru, this message translates to:
  /// **'Добавить заметку'**
  String get noteAdd;

  /// noteHint
  ///
  /// In ru, this message translates to:
  /// **'Что не забыть'**
  String get noteHint;

  /// repeatNone
  ///
  /// In ru, this message translates to:
  /// **'Не повторяется'**
  String get repeatNone;

  /// repeatByRule
  ///
  /// In ru, this message translates to:
  /// **'По правилу'**
  String get repeatByRule;

  /// repeatTitle
  ///
  /// In ru, this message translates to:
  /// **'Повторение'**
  String get repeatTitle;

  /// repeatDaily
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get repeatDaily;

  /// repeatWeekly
  ///
  /// In ru, this message translates to:
  /// **'Каждую неделю'**
  String get repeatWeekly;

  /// repeatEvery
  ///
  /// In ru, this message translates to:
  /// **'Каждые'**
  String get repeatEvery;

  /// repeatEndsWhen
  ///
  /// In ru, this message translates to:
  /// **'Когда заканчивается'**
  String get repeatEndsWhen;

  /// repeatNextDates
  ///
  /// In ru, this message translates to:
  /// **'Ближайшие даты'**
  String get repeatNextDates;

  /// repeatNever
  ///
  /// In ru, this message translates to:
  /// **'Никогда'**
  String get repeatNever;

  /// repeatUntilDate
  ///
  /// In ru, this message translates to:
  /// **'До даты'**
  String get repeatUntilDate;

  /// repeatAfterCount
  ///
  /// In ru, this message translates to:
  /// **'После {count} повторов'**
  String repeatAfterCount(int count);

  /// unitDay
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get unitDay;

  /// unitWeek
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get unitWeek;

  /// unitMonth
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get unitMonth;

  /// unitYear
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get unitYear;

  /// scopeTitle
  ///
  /// In ru, this message translates to:
  /// **'Что изменить'**
  String get scopeTitle;

  /// scopeRepeats
  ///
  /// In ru, this message translates to:
  /// **'Занятие повторяется: {label}'**
  String scopeRepeats(String label);

  /// scopeOnly
  ///
  /// In ru, this message translates to:
  /// **'Только это занятие'**
  String get scopeOnly;

  /// scopeFollowing
  ///
  /// In ru, this message translates to:
  /// **'Это и следующие'**
  String get scopeFollowing;

  /// scopeFollowingHint
  ///
  /// In ru, this message translates to:
  /// **'Ряд разделится: прошедшие занятия останутся как были'**
  String get scopeFollowingHint;

  /// scopeWhole
  ///
  /// In ru, this message translates to:
  /// **'Весь ряд'**
  String get scopeWhole;

  /// scopeWholeHint
  ///
  /// In ru, this message translates to:
  /// **'Все занятия, включая прошедшие'**
  String get scopeWholeHint;

  /// msgEventDeleted
  ///
  /// In ru, this message translates to:
  /// **'Событие удалено'**
  String get msgEventDeleted;

  /// msgSeriesDeleted
  ///
  /// In ru, this message translates to:
  /// **'Ряд удалён'**
  String get msgSeriesDeleted;

  /// msgOccurrenceSkipped
  ///
  /// In ru, this message translates to:
  /// **'Занятие отменено'**
  String get msgOccurrenceSkipped;

  /// reminderNone
  ///
  /// In ru, this message translates to:
  /// **'Без напоминания'**
  String get reminderNone;

  /// reminderAtStart
  ///
  /// In ru, this message translates to:
  /// **'В момент начала'**
  String get reminderAtStart;

  /// reminderNever
  ///
  /// In ru, this message translates to:
  /// **'Не напоминать'**
  String get reminderNever;

  /// reminderHint
  ///
  /// In ru, this message translates to:
  /// **'Можно несколько: за день собраться, за десять минут выйти'**
  String get reminderHint;

  /// reminderMinutes
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{За {count} минуту} few{За {count} минуты} other{За {count} минут}}'**
  String reminderMinutes(int count);

  /// reminderHours
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{За час} few{За {count} часа} other{За {count} часов}}'**
  String reminderHours(int count);

  /// reminderDays
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{За день} few{За {count} дня} other{За {count} дней}}'**
  String reminderDays(int count);

  /// reminderWeek
  ///
  /// In ru, this message translates to:
  /// **'За неделю'**
  String get reminderWeek;

  /// reminderStarts
  ///
  /// In ru, this message translates to:
  /// **'Начинается'**
  String get reminderStarts;

  /// reminderStartsAt
  ///
  /// In ru, this message translates to:
  /// **'Начало в {time}'**
  String reminderStartsAt(String time);

  /// icsExport
  ///
  /// In ru, this message translates to:
  /// **'Выгрузить в .ics'**
  String get icsExport;

  /// icsExportHint
  ///
  /// In ru, this message translates to:
  /// **'Файл для другого календаря'**
  String get icsExportHint;

  /// icsImport
  ///
  /// In ru, this message translates to:
  /// **'Загрузить из .ics'**
  String get icsImport;

  /// icsImportHint
  ///
  /// In ru, this message translates to:
  /// **'События из чужого календаря'**
  String get icsImportHint;

  /// icsSaveTitle
  ///
  /// In ru, this message translates to:
  /// **'Куда сохранить календарь'**
  String get icsSaveTitle;

  /// icsPickTitle
  ///
  /// In ru, this message translates to:
  /// **'Выберите файл календаря'**
  String get icsPickTitle;

  /// icsNothingToExport
  ///
  /// In ru, this message translates to:
  /// **'Выгружать нечего: событий нет.'**
  String get icsNothingToExport;

  /// icsExported
  ///
  /// In ru, this message translates to:
  /// **'Выгружено событий: {count}.'**
  String icsExported(int count);

  /// icsImported
  ///
  /// In ru, this message translates to:
  /// **'Загружено событий: {count}.'**
  String icsImported(int count);

  /// icsUnreadable
  ///
  /// In ru, this message translates to:
  /// **'Файл не прочитался.'**
  String get icsUnreadable;

  /// icsNoEvents
  ///
  /// In ru, this message translates to:
  /// **'В файле не нашлось ни одного события.'**
  String get icsNoEvents;

  /// colorPickerOwn
  ///
  /// In ru, this message translates to:
  /// **'Свой цвет'**
  String get colorPickerOwn;

  /// colorHue
  ///
  /// In ru, this message translates to:
  /// **'Оттенок'**
  String get colorHue;

  /// colorChroma
  ///
  /// In ru, this message translates to:
  /// **'Насыщенность'**
  String get colorChroma;

  /// colorTone
  ///
  /// In ru, this message translates to:
  /// **'Светлота'**
  String get colorTone;

  /// colorMine
  ///
  /// In ru, this message translates to:
  /// **'Мои цвета'**
  String get colorMine;

  /// colorRecent
  ///
  /// In ru, this message translates to:
  /// **'Последние'**
  String get colorRecent;

  /// colorSaveMine
  ///
  /// In ru, this message translates to:
  /// **'В мои'**
  String get colorSaveMine;

  /// colorReadout
  ///
  /// In ru, this message translates to:
  /// **'Оттенок {hue}° · насыщенность {chroma} · светлота {tone}'**
  String colorReadout(int hue, int chroma, int tone);

  /// colorPickerHint
  ///
  /// In ru, this message translates to:
  /// **'Пипетка берёт цвет с картинки: откройте снимок экрана или фотографию и нажмите на нужное место. Сохранённые живут в «Моих цветах» и доступны из любого пикера приложения.'**
  String get colorPickerHint;

  /// branchColorTitle
  ///
  /// In ru, this message translates to:
  /// **'Цвет ветки'**
  String get branchColorTitle;

  /// branchColorOwnHint
  ///
  /// In ru, this message translates to:
  /// **'Задан у этой ветки'**
  String get branchColorOwnHint;

  /// branchColorOfCalendar
  ///
  /// In ru, this message translates to:
  /// **'Цвет «{name}»'**
  String branchColorOfCalendar(String name);

  /// branchColorPickerRow
  ///
  /// In ru, this message translates to:
  /// **'Свой цвет из пикера'**
  String get branchColorPickerRow;

  /// branchColorPickerHint
  ///
  /// In ru, this message translates to:
  /// **'Оттенок, насыщенность, hex, пипетка'**
  String get branchColorPickerHint;

  /// branchColorChain
  ///
  /// In ru, this message translates to:
  /// **'Перекрасите «{name}» — сменят цвет все ветки и события, где стоит наследование. Ветки со своим цветом останутся как есть.'**
  String branchColorChain(String name);

  /// branchColorEventRow
  ///
  /// In ru, this message translates to:
  /// **'Событие ветки'**
  String get branchColorEventRow;

  /// levelCalendar
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get levelCalendar;

  /// levelOwn
  ///
  /// In ru, this message translates to:
  /// **'Свой'**
  String get levelOwn;

  /// ruleDaily
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{каждый день} few{каждые {count} дня} other{каждые {count} дней}}'**
  String ruleDaily(int count);

  /// ruleWeekly
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{каждую неделю} few{каждые {count} недели} other{каждые {count} недель}}'**
  String ruleWeekly(int count);

  /// ruleMonthly
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{каждый месяц} few{каждые {count} месяца} other{каждые {count} месяцев}}'**
  String ruleMonthly(int count);

  /// ruleYearly
  ///
  /// In ru, this message translates to:
  /// **'каждый год'**
  String get ruleYearly;

  /// ruleWeekDays
  ///
  /// In ru, this message translates to:
  /// **'{every}: {days}'**
  String ruleWeekDays(String every, String days);

  /// ruleMonthPosition
  ///
  /// In ru, this message translates to:
  /// **'{every}: {ordinal} {weekday}'**
  String ruleMonthPosition(String every, String ordinal, String weekday);

  /// ordinalLast
  ///
  /// In ru, this message translates to:
  /// **'последний,последний,последняя,последний,последняя,последняя,последнее'**
  String get ordinalLast;

  /// ordinal1
  ///
  /// In ru, this message translates to:
  /// **'первый,первый,первая,первый,первая,первая,первое'**
  String get ordinal1;

  /// ordinal2
  ///
  /// In ru, this message translates to:
  /// **'второй,второй,вторая,второй,вторая,вторая,второе'**
  String get ordinal2;

  /// ordinal3
  ///
  /// In ru, this message translates to:
  /// **'третий,третий,третья,третий,третья,третья,третье'**
  String get ordinal3;

  /// ordinal4
  ///
  /// In ru, this message translates to:
  /// **'четвёртый,четвёртый,четвёртая,четвёртый,четвёртая,четвёртая,четвёртое'**
  String get ordinal4;

  /// weekSetupTitle
  ///
  /// In ru, this message translates to:
  /// **'Какие дни показывать'**
  String get weekSetupTitle;

  /// weekSetupHint
  ///
  /// In ru, this message translates to:
  /// **'Колонок будет столько, сколько дней отмечено'**
  String get weekSetupHint;

  /// weekSetupAll
  ///
  /// In ru, this message translates to:
  /// **'Вся неделя'**
  String get weekSetupAll;

  /// weekSetupWorkdays
  ///
  /// In ru, this message translates to:
  /// **'Будни'**
  String get weekSetupWorkdays;

  /// weekSetupWeekend
  ///
  /// In ru, this message translates to:
  /// **'Выходные'**
  String get weekSetupWeekend;

  /// weekSetupStartsWith
  ///
  /// In ru, this message translates to:
  /// **'Неделя начинается с'**
  String get weekSetupStartsWith;

  /// accessTitle
  ///
  /// In ru, this message translates to:
  /// **'Доступ'**
  String get accessTitle;

  /// accessCreateKey
  ///
  /// In ru, this message translates to:
  /// **'Создать ключ'**
  String get accessCreateKey;

  /// accessRevoke
  ///
  /// In ru, this message translates to:
  /// **'Отозвать'**
  String get accessRevoke;

  /// accessHint
  ///
  /// In ru, this message translates to:
  /// **'Ключи работают, пока включена синхронизация. Календарь, который живёт только на телефоне, снаружи недоступен — стучаться некуда.'**
  String get accessHint;

  /// repeatNever2
  ///
  /// In ru, this message translates to:
  /// **'Не повторять'**
  String get repeatNever2;

  /// repeatWeekdays
  ///
  /// In ru, this message translates to:
  /// **'По будням'**
  String get repeatWeekdays;

  /// repeatCountLabel
  ///
  /// In ru, this message translates to:
  /// **'Повторов'**
  String get repeatCountLabel;

  /// repeatTimes
  ///
  /// In ru, this message translates to:
  /// **'раз'**
  String get repeatTimes;

  /// repeatAfterSome
  ///
  /// In ru, this message translates to:
  /// **'После нескольких повторов'**
  String get repeatAfterSome;

  /// repeatNoDates
  ///
  /// In ru, this message translates to:
  /// **'По такому правилу занятий не будет'**
  String get repeatNoDates;

  /// unitDays
  ///
  /// In ru, this message translates to:
  /// **'дня'**
  String get unitDays;

  /// unitWeeks
  ///
  /// In ru, this message translates to:
  /// **'недели'**
  String get unitWeeks;

  /// unitMonths
  ///
  /// In ru, this message translates to:
  /// **'месяца'**
  String get unitMonths;

  /// unitYears
  ///
  /// In ru, this message translates to:
  /// **'года'**
  String get unitYears;

  /// repeatAdvEnd
  ///
  /// In ru, this message translates to:
  /// **'Окончание'**
  String get repeatAdvEnd;

  /// repeatAdvNotSet
  ///
  /// In ru, this message translates to:
  /// **'Не выбрана'**
  String get repeatAdvNotSet;

  /// repeatAdvMonthRule
  ///
  /// In ru, this message translates to:
  /// **'Правило месяца'**
  String get repeatAdvMonthRule;

  /// repeatAdvByDate
  ///
  /// In ru, this message translates to:
  /// **'По числу'**
  String get repeatAdvByDate;

  /// repeatAdvByPosition
  ///
  /// In ru, this message translates to:
  /// **'По позиции'**
  String get repeatAdvByPosition;

  /// repeatAdvSkipped
  ///
  /// In ru, this message translates to:
  /// **'Пропущенные даты'**
  String get repeatAdvSkipped;

  /// repeatAdvExceptions
  ///
  /// In ru, this message translates to:
  /// **'Исключения'**
  String get repeatAdvExceptions;

  /// repeatAdvShiftFirst
  ///
  /// In ru, this message translates to:
  /// **'Сдвигать вместе с первым'**
  String get repeatAdvShiftFirst;

  /// repeatAdvShiftHint
  ///
  /// In ru, this message translates to:
  /// **'Перенос первой даты двигает весь ряд'**
  String get repeatAdvShiftHint;

  /// repeatAdvHolidays
  ///
  /// In ru, this message translates to:
  /// **'Не повторять в праздники'**
  String get repeatAdvHolidays;

  /// repeatAdvHolidaysHint
  ///
  /// In ru, this message translates to:
  /// **'С учётом праздников страны'**
  String get repeatAdvHolidaysHint;

  /// repeatAdvParsed
  ///
  /// In ru, this message translates to:
  /// **'Разобрано в правило · нажмите, чтобы применить'**
  String get repeatAdvParsed;

  /// weekSetupCancel
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get weekSetupCancel;

  /// searchInCalendar
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get searchInCalendar;

  /// monthMore
  ///
  /// In ru, this message translates to:
  /// **'ещё {count}'**
  String monthMore(int count);

  /// eventCancelOn
  ///
  /// In ru, this message translates to:
  /// **'Отменить {date}'**
  String eventCancelOn(String date);

  /// eventDeleteSeries
  ///
  /// In ru, this message translates to:
  /// **'Удалить весь ряд'**
  String get eventDeleteSeries;

  /// untitled
  ///
  /// In ru, this message translates to:
  /// **'Без названия'**
  String get untitled;

  /// msgCancelledNamed
  ///
  /// In ru, this message translates to:
  /// **'«{title}» отменено'**
  String msgCancelledNamed(String title);

  /// iconPickerTitle
  ///
  /// In ru, this message translates to:
  /// **'Иконка'**
  String get iconPickerTitle;

  /// iconSearchHint
  ///
  /// In ru, this message translates to:
  /// **'Найти иконку (по-английски)'**
  String get iconSearchHint;

  /// iconPickerCommon
  ///
  /// In ru, this message translates to:
  /// **'Ходовые'**
  String get iconPickerCommon;

  /// iconFound
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Нашлась {count}} few{Нашлось {count}} other{Нашлось {count}}}'**
  String iconFound(int count);

  /// settingsAutoTime
  ///
  /// In ru, this message translates to:
  /// **'По времени суток'**
  String get settingsAutoTime;

  /// settingsAmoled
  ///
  /// In ru, this message translates to:
  /// **'AMOLED'**
  String get settingsAmoled;

  /// settingsAmoledHint
  ///
  /// In ru, this message translates to:
  /// **'Чистый чёрный фон в тёмной теме'**
  String get settingsAmoledHint;

  /// settingsMaterialYou
  ///
  /// In ru, this message translates to:
  /// **'Material You'**
  String get settingsMaterialYou;

  /// settingsMaterialYouHint
  ///
  /// In ru, this message translates to:
  /// **'Цвет из обоев системы (Android 12+)'**
  String get settingsMaterialYouHint;

  /// settingsStartScreen
  ///
  /// In ru, this message translates to:
  /// **'Стартовый экран'**
  String get settingsStartScreen;

  /// settingsStartScreenHint
  ///
  /// In ru, this message translates to:
  /// **'С него открывается приложение'**
  String get settingsStartScreenHint;

  /// settingsStartView
  ///
  /// In ru, this message translates to:
  /// **'Вид на старте'**
  String get settingsStartView;

  /// placeHere
  ///
  /// In ru, this message translates to:
  /// **'Я здесь'**
  String get placeHere;

  /// placeSearchHint
  ///
  /// In ru, this message translates to:
  /// **'Улица, заведение, город'**
  String get placeSearchHint;

  /// placeSearching
  ///
  /// In ru, this message translates to:
  /// **'Ищу…'**
  String get placeSearching;

  /// placeNoFix
  ///
  /// In ru, this message translates to:
  /// **'Не вышло определить место: нет разрешения или сигнала.'**
  String get placeNoFix;

  /// msgSaveFailed
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить'**
  String get msgSaveFailed;

  /// msgNotSaved
  ///
  /// In ru, this message translates to:
  /// **'Изменения не сохранены'**
  String get msgNotSaved;

  /// syncTitle
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get syncTitle;

  /// syncOff
  ///
  /// In ru, this message translates to:
  /// **'Выключена, календарь только здесь'**
  String get syncOff;

  /// syncClean
  ///
  /// In ru, this message translates to:
  /// **'Всё отправлено'**
  String get syncClean;

  /// syncPending
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} правка ждёт} few{{count} правки ждут} other{{count} правок ждут}}'**
  String syncPending(int count);

  /// syncConnectTitle
  ///
  /// In ru, this message translates to:
  /// **'Подключить сервер'**
  String get syncConnectTitle;

  /// syncServerAddress
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера'**
  String get syncServerAddress;

  /// syncCode
  ///
  /// In ru, this message translates to:
  /// **'Код с первого устройства'**
  String get syncCode;

  /// syncCodeHint
  ///
  /// In ru, this message translates to:
  /// **'Пусто — это первое устройство'**
  String get syncCodeHint;

  /// syncDeviceName
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get syncDeviceName;

  /// syncConnected
  ///
  /// In ru, this message translates to:
  /// **'Сервер подключён'**
  String get syncConnected;

  /// syncFailed
  ///
  /// In ru, this message translates to:
  /// **'Не вышло'**
  String get syncFailed;

  /// syncDone
  ///
  /// In ru, this message translates to:
  /// **'Отправлено {sent}, получено {received}'**
  String syncDone(int sent, int received);

  /// syncPairTitle
  ///
  /// In ru, this message translates to:
  /// **'Код для второго устройства'**
  String get syncPairTitle;

  /// syncPairHint
  ///
  /// In ru, this message translates to:
  /// **'Показать и ввести на другом'**
  String get syncPairHint;

  /// syncDisconnect
  ///
  /// In ru, this message translates to:
  /// **'Отключить сервер'**
  String get syncDisconnect;

  /// syncDisconnectHint
  ///
  /// In ru, this message translates to:
  /// **'Данные останутся на устройстве'**
  String get syncDisconnectHint;

  /// accessNeedsSync
  ///
  /// In ru, this message translates to:
  /// **'Ключи появятся, когда включите синхронизацию'**
  String get accessNeedsSync;

  /// accessNoKeys
  ///
  /// In ru, this message translates to:
  /// **'Ни одного ключа'**
  String get accessNoKeys;

  /// accessLoading
  ///
  /// In ru, this message translates to:
  /// **'Загружаю…'**
  String get accessLoading;

  /// accessKeyName
  ///
  /// In ru, this message translates to:
  /// **'Имя агента'**
  String get accessKeyName;

  /// accessScopesHint
  ///
  /// In ru, this message translates to:
  /// **'Какие календари видит ключ и где ему можно писать'**
  String get accessScopesHint;

  /// accessReadOnly
  ///
  /// In ru, this message translates to:
  /// **'Только чтение'**
  String get accessReadOnly;

  /// accessWrite
  ///
  /// In ru, this message translates to:
  /// **'Чтение и запись'**
  String get accessWrite;

  /// accessKeyOnce
  ///
  /// In ru, this message translates to:
  /// **'Ключ показывается один раз'**
  String get accessKeyOnce;

  /// accessKeyOnceHint
  ///
  /// In ru, this message translates to:
  /// **'Скопируйте его в агента сейчас: на сервере остался только хеш, и восстановить строку неоткуда.'**
  String get accessKeyOnceHint;

  /// accessLastUsed
  ///
  /// In ru, this message translates to:
  /// **'Работал {when}'**
  String accessLastUsed(String when);

  /// accessNeverUsed
  ///
  /// In ru, this message translates to:
  /// **'Ещё не работал'**
  String get accessNeverUsed;

  /// accessRevoked
  ///
  /// In ru, this message translates to:
  /// **'Отозван'**
  String get accessRevoked;

  /// accessLog
  ///
  /// In ru, this message translates to:
  /// **'Журнал'**
  String get accessLog;

  /// accessLogEmpty
  ///
  /// In ru, this message translates to:
  /// **'Ключ пока ничего не трогал'**
  String get accessLogEmpty;

  /// photosTitle
  ///
  /// In ru, this message translates to:
  /// **'Снимки'**
  String get photosTitle;

  /// photoAdd
  ///
  /// In ru, this message translates to:
  /// **'Добавить снимок'**
  String get photoAdd;

  /// photoCamera
  ///
  /// In ru, this message translates to:
  /// **'Снять'**
  String get photoCamera;

  /// photoGallery
  ///
  /// In ru, this message translates to:
  /// **'Из галереи'**
  String get photoGallery;

  /// photoRemove
  ///
  /// In ru, this message translates to:
  /// **'Убрать снимок'**
  String get photoRemove;

  /// photoRemoveAsk
  ///
  /// In ru, this message translates to:
  /// **'Убрать этот снимок?'**
  String get photoRemoveAsk;

  /// photoNeedsSave
  ///
  /// In ru, this message translates to:
  /// **'Снимки появятся, когда событие сохранено'**
  String get photoNeedsSave;

  /// navTasks
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get navTasks;

  /// tasksEmpty
  ///
  /// In ru, this message translates to:
  /// **'Задач пока нет'**
  String get tasksEmpty;

  /// tasksEmptyHint
  ///
  /// In ru, this message translates to:
  /// **'Кнопка внизу заводит первую'**
  String get tasksEmptyHint;

  /// taskNew
  ///
  /// In ru, this message translates to:
  /// **'Новая задача'**
  String get taskNew;

  /// taskOne
  ///
  /// In ru, this message translates to:
  /// **'Задача'**
  String get taskOne;

  /// taskTitleHint
  ///
  /// In ru, this message translates to:
  /// **'Что сделать'**
  String get taskTitleHint;

  /// taskDue
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get taskDue;

  /// taskNoDue
  ///
  /// In ru, this message translates to:
  /// **'Без срока'**
  String get taskNoDue;

  /// taskAtTime
  ///
  /// In ru, this message translates to:
  /// **'Ко времени'**
  String get taskAtTime;

  /// taskNotes
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get taskNotes;

  /// taskNotesHint
  ///
  /// In ru, this message translates to:
  /// **'Подробности'**
  String get taskNotesHint;

  /// taskDelete
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу'**
  String get taskDelete;

  /// taskOverdue
  ///
  /// In ru, this message translates to:
  /// **'Просрочена'**
  String get taskOverdue;

  /// tasksDoneSection
  ///
  /// In ru, this message translates to:
  /// **'Сделанные'**
  String get tasksDoneSection;

  /// tasksOpenCount
  ///
  /// In ru, this message translates to:
  /// **'{count} в работе'**
  String tasksOpenCount(int count);

  /// msgTaskDeleted
  ///
  /// In ru, this message translates to:
  /// **'Задача удалена'**
  String get msgTaskDeleted;

  /// dueToday
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get dueToday;

  /// dueTomorrow
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get dueTomorrow;

  /// statsTitle
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statsTitle;

  /// statsWeek
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get statsWeek;

  /// statsMonth
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get statsMonth;

  /// statsYear
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get statsYear;

  /// statsBusyTime
  ///
  /// In ru, this message translates to:
  /// **'Занято времени'**
  String get statsBusyTime;

  /// statsEventCount
  ///
  /// In ru, this message translates to:
  /// **'Событий'**
  String get statsEventCount;

  /// statsTasksClosed
  ///
  /// In ru, this message translates to:
  /// **'Задач закрыто'**
  String get statsTasksClosed;

  /// statsPerDay
  ///
  /// In ru, this message translates to:
  /// **'В среднем за день'**
  String get statsPerDay;

  /// statsByCalendar
  ///
  /// In ru, this message translates to:
  /// **'По календарям'**
  String get statsByCalendar;

  /// statsByWeekday
  ///
  /// In ru, this message translates to:
  /// **'По дням недели'**
  String get statsByWeekday;

  /// statsBusiestDay
  ///
  /// In ru, this message translates to:
  /// **'Самый плотный день'**
  String get statsBusiestDay;

  /// statsEmpty
  ///
  /// In ru, this message translates to:
  /// **'За этот период записей нет'**
  String get statsEmpty;

  /// statsHoursShort
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч'**
  String statsHoursShort(String hours);

  /// statsShare
  ///
  /// In ru, this message translates to:
  /// **'{percent}%'**
  String statsShare(int percent);

  /// colorSaved
  ///
  /// In ru, this message translates to:
  /// **'Цвет в «Моих»'**
  String get colorSaved;

  /// colorAlreadySaved
  ///
  /// In ru, this message translates to:
  /// **'Такой цвет уже сохранён'**
  String get colorAlreadySaved;

  /// colorRemovedFromMine
  ///
  /// In ru, this message translates to:
  /// **'Убрано из «Моих»'**
  String get colorRemovedFromMine;

  /// colorCopied
  ///
  /// In ru, this message translates to:
  /// **'Код скопирован'**
  String get colorCopied;

  /// colorCopy
  ///
  /// In ru, this message translates to:
  /// **'Скопировать код'**
  String get colorCopy;

  /// colorPickFromImage
  ///
  /// In ru, this message translates to:
  /// **'Взять цвет с картинки'**
  String get colorPickFromImage;

  /// colorTapImage
  ///
  /// In ru, this message translates to:
  /// **'Нажмите на картинку — цвет возьмётся оттуда'**
  String get colorTapImage;

  /// colorHexHint
  ///
  /// In ru, this message translates to:
  /// **'Свой код'**
  String get colorHexHint;

  /// scopeOnlyHint
  ///
  /// In ru, this message translates to:
  /// **'{day} встанет по-новому, остальные не тронутся'**
  String scopeOnlyHint(String day);

  /// scopeDeleteTitle
  ///
  /// In ru, this message translates to:
  /// **'Что удалить'**
  String get scopeDeleteTitle;

  /// scopeDeleteOnlyHint
  ///
  /// In ru, this message translates to:
  /// **'{day} исчезнет, ряд останется'**
  String scopeDeleteOnlyHint(String day);

  /// scopeDeleteFollowingHint
  ///
  /// In ru, this message translates to:
  /// **'Ряд оборвётся на этой дате, прошедшие занятия останутся'**
  String get scopeDeleteFollowingHint;

  /// scopeDeleteWholeHint
  ///
  /// In ru, this message translates to:
  /// **'Исчезнут все занятия, включая прошедшие'**
  String get scopeDeleteWholeHint;

  /// msgSeriesTrimmed
  ///
  /// In ru, this message translates to:
  /// **'Ряд оборван на этой дате'**
  String get msgSeriesTrimmed;

  /// eventDuplicate
  ///
  /// In ru, this message translates to:
  /// **'Сделать копию'**
  String get eventDuplicate;

  /// eventCopySuffix
  ///
  /// In ru, this message translates to:
  /// **'{title} — копия'**
  String eventCopySuffix(String title);

  /// moveTitle
  ///
  /// In ru, this message translates to:
  /// **'Перенести'**
  String get moveTitle;

  /// moveTomorrow
  ///
  /// In ru, this message translates to:
  /// **'На завтра'**
  String get moveTomorrow;

  /// moveNextWeek
  ///
  /// In ru, this message translates to:
  /// **'Через неделю'**
  String get moveNextWeek;

  /// movePickDate
  ///
  /// In ru, this message translates to:
  /// **'Выбрать дату'**
  String get movePickDate;

  /// msgEventMoved
  ///
  /// In ru, this message translates to:
  /// **'Событие перенесено на {day}'**
  String msgEventMoved(String day);

  /// actionShare
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get actionShare;

  /// msgEventCopiedText
  ///
  /// In ru, this message translates to:
  /// **'Событие скопировано текстом'**
  String get msgEventCopiedText;

  /// eventOpenMap
  ///
  /// In ru, this message translates to:
  /// **'Открыть на карте'**
  String get eventOpenMap;

  /// previewActions
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get previewActions;

  /// seriesPause
  ///
  /// In ru, this message translates to:
  /// **'Пауза ряда'**
  String get seriesPause;

  /// seriesPauseWeeks
  ///
  /// In ru, this message translates to:
  /// **'Не будет {weeks} нед.'**
  String seriesPauseWeeks(int weeks);

  /// msgSeriesPaused
  ///
  /// In ru, this message translates to:
  /// **'Пропущено занятий: {count}'**
  String msgSeriesPaused(int count);

  /// lookReset
  ///
  /// In ru, this message translates to:
  /// **'Как у ветки'**
  String get lookReset;

  /// msgLookReset
  ///
  /// In ru, this message translates to:
  /// **'Цвет и иконка снова наследуются'**
  String get msgLookReset;

  /// toTask
  ///
  /// In ru, this message translates to:
  /// **'Сделать задачей'**
  String get toTask;

  /// msgBecameTask
  ///
  /// In ru, this message translates to:
  /// **'Событие стало задачей'**
  String get msgBecameTask;

  /// shiftRest
  ///
  /// In ru, this message translates to:
  /// **'Сдвинуть остаток дня'**
  String get shiftRest;

  /// msgDayShifted
  ///
  /// In ru, this message translates to:
  /// **'Сдвинуто следом: {count}'**
  String msgDayShifted(int count);

  /// repeatDay
  ///
  /// In ru, this message translates to:
  /// **'Повторить день'**
  String get repeatDay;

  /// msgDayCopied
  ///
  /// In ru, this message translates to:
  /// **'День перенесён на {day}: событий {count}'**
  String msgDayCopied(String day, int count);

  /// stretchToNext
  ///
  /// In ru, this message translates to:
  /// **'Растянуть до следующего'**
  String get stretchToNext;

  /// msgStretched
  ///
  /// In ru, this message translates to:
  /// **'Событие идёт до {time}'**
  String msgStretched(String time);

  /// nothingToShift
  ///
  /// In ru, this message translates to:
  /// **'Дальше в этом дне ничего нет'**
  String get nothingToShift;

  /// msgEventShifted
  ///
  /// In ru, this message translates to:
  /// **'Событие в {time}'**
  String msgEventShifted(String time);

  /// msgEventResized
  ///
  /// In ru, this message translates to:
  /// **'Теперь до {time}'**
  String msgEventResized(String time);

  /// msgOverlaps
  ///
  /// In ru, this message translates to:
  /// **'Пересекается: {title}'**
  String msgOverlaps(String title);

  /// quickPhraseHint
  ///
  /// In ru, this message translates to:
  /// **'Созвон завтра в 15:00 на час'**
  String get quickPhraseHint;

  /// quickPhraseRead
  ///
  /// In ru, this message translates to:
  /// **'Понял из строки'**
  String get quickPhraseRead;

  /// findSlot
  ///
  /// In ru, this message translates to:
  /// **'Ближайшее окно'**
  String get findSlot;

  /// msgSlotFound
  ///
  /// In ru, this message translates to:
  /// **'Свободно: {when}'**
  String msgSlotFound(String when);

  /// msgNoSlot
  ///
  /// In ru, this message translates to:
  /// **'В ближайшие две недели окна нет'**
  String get msgNoSlot;

  /// trashTitle
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get trashTitle;

  /// trashHint
  ///
  /// In ru, this message translates to:
  /// **'Удалённое хранится 90 дней'**
  String get trashHint;

  /// trashEmpty
  ///
  /// In ru, this message translates to:
  /// **'Корзина пуста'**
  String get trashEmpty;

  /// trashRestore
  ///
  /// In ru, this message translates to:
  /// **'Вернуть'**
  String get trashRestore;

  /// trashClear
  ///
  /// In ru, this message translates to:
  /// **'Очистить корзину'**
  String get trashClear;

  /// msgTrashCleared
  ///
  /// In ru, this message translates to:
  /// **'Убрано записей: {count}'**
  String msgTrashCleared(int count);

  /// msgRestored
  ///
  /// In ru, this message translates to:
  /// **'Возвращено: {title}'**
  String msgRestored(String title);

  /// calendarDefaults
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get calendarDefaults;

  /// calendarDefaultReminder
  ///
  /// In ru, this message translates to:
  /// **'Напоминание у новых событий'**
  String get calendarDefaultReminder;

  /// calendarDefaultDuration
  ///
  /// In ru, this message translates to:
  /// **'Длительность у новых событий'**
  String get calendarDefaultDuration;

  /// actionSelect
  ///
  /// In ru, this message translates to:
  /// **'Выбрать несколько'**
  String get actionSelect;

  /// selectedCount
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String selectedCount(int count);

  /// bulkMove
  ///
  /// In ru, this message translates to:
  /// **'Перенести'**
  String get bulkMove;

  /// bulkCalendar
  ///
  /// In ru, this message translates to:
  /// **'В календарь'**
  String get bulkCalendar;

  /// msgBulkMoved
  ///
  /// In ru, this message translates to:
  /// **'Перенесено событий: {count}'**
  String msgBulkMoved(int count);

  /// msgBulkDeleted
  ///
  /// In ru, this message translates to:
  /// **'Удалено событий: {count}'**
  String msgBulkDeleted(int count);

  /// msgBulkCalendar
  ///
  /// In ru, this message translates to:
  /// **'Событий в другом календаре: {count}'**
  String msgBulkCalendar(int count);

  /// eventOpenEnd
  ///
  /// In ru, this message translates to:
  /// **'Без окончания'**
  String get eventOpenEnd;

  /// timeFrom
  ///
  /// In ru, this message translates to:
  /// **'с {time}'**
  String timeFrom(String time);

  /// noteMarkupHint
  ///
  /// In ru, this message translates to:
  /// **'«- » — пункт списка, «[ ] » — галочка'**
  String get noteMarkupHint;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'pl',
    'ro',
    'ru',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return LDe();
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'pl':
      return LPl();
    case 'ro':
      return LRo();
    case 'ru':
      return LRu();
    case 'uk':
      return LUk();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

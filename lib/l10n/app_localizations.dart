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
  /// **'добавить'**
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
  /// **'наследует'**
  String get colorInherits;

  /// colorOwn
  ///
  /// In ru, this message translates to:
  /// **'свой цвет'**
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
  /// **'общее'**
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
  /// **'да'**
  String get yes;

  /// no
  ///
  /// In ru, this message translates to:
  /// **'нет'**
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
  /// **'в карточке'**
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
  /// **'не повторяется'**
  String get repeatNone;

  /// repeatByRule
  ///
  /// In ru, this message translates to:
  /// **'по правилу'**
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
  /// **'Пипетка берёт цвет с обоев или скриншота. Сохранённые живут в «Моих цветах» и доступны из любого пикера в приложении.'**
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
  /// **'календарь'**
  String get levelCalendar;

  /// levelOwn
  ///
  /// In ru, this message translates to:
  /// **'свой'**
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

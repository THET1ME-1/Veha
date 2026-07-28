// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class LPl extends L {
  LPl([String locale = 'pl']) : super(locale);

  @override
  String get navCalendar => 'Kalendarz';

  @override
  String get navList => 'Lista';

  @override
  String get navAccess => 'Dostęp';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get viewDay => 'Dzień';

  @override
  String get viewDays => 'Dni';

  @override
  String get viewWeek => 'Tydzień';

  @override
  String get viewMonth => 'Miesiąc';

  @override
  String get readingClock => 'Zegar';

  @override
  String get readingChain => 'Łańcuch';

  @override
  String get viewNotBuilt => 'Ten widok nie jest gotowy';

  @override
  String get newEvent => 'Nowe wydarzenie';

  @override
  String get today => 'dziś';

  @override
  String get nothingPlanned => 'Nic nie zaplanowano';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours godz.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours godz. $minutes min';
  }

  @override
  String spanDayOf(int current, int total) {
    return '$current. z $total';
  }

  @override
  String spanUntil(String date) {
    return 'do $date';
  }

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionAdd => 'dodaj';

  @override
  String get actionEdit => 'Zmień';

  @override
  String get actionUndo => 'Cofnij';

  @override
  String get fieldName => 'Nazwa';

  @override
  String get calendarsTitle => 'Kalendarze';

  @override
  String get calendarOne => 'Kalendarz';

  @override
  String get calendarNewShort => 'Nowy';

  @override
  String get calendarNew => 'Nowy kalendarz';

  @override
  String get calendarCreate => 'Utwórz kalendarz';

  @override
  String get calendarsEmptyTitle => 'Brak kalendarzy';

  @override
  String get calendarsEmptyBody =>
      'Kalendarz nadaje kolor i ikonę wszystkim wydarzeniom w środku. Zwykle są trzy-cztery: dom, praca, nauka, sport.';

  @override
  String get branchOne => 'Gałąź';

  @override
  String get branchNone => 'Bez gałęzi';

  @override
  String get branchAdd => 'Dodaj gałąź';

  @override
  String branchOf(String name) {
    return 'Gałąź „$name”';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gałęzi',
      few: '$count gałęzie',
      one: '$count gałąź',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'dziedziczy';

  @override
  String get colorOwn => 'własny kolor';

  @override
  String get fieldsTitle => 'Własne pola';

  @override
  String get fieldsShared => 'Wspólne dla wszystkich';

  @override
  String get fieldsSharedRow => 'Wspólne pola';

  @override
  String get fieldsGroups => 'Grupy';

  @override
  String get fieldsNoneYet => 'Na razie żadnego';

  @override
  String get fieldsGroupEmpty => 'Bez własnych pól';

  @override
  String get fieldsGroupCreate => 'Utwórz grupę pól';

  @override
  String get fieldsGroupNew => 'Nowa grupa';

  @override
  String fieldAddTo(String name) {
    return 'Dodaj pole do „$name”';
  }

  @override
  String fieldNewIn(String name) {
    return 'Nowe pole w „$name”';
  }

  @override
  String get fieldOne => 'Pole';

  @override
  String get fieldShared => 'wspólne';

  @override
  String get fieldNamePlaceholder => 'Nazwa pola';

  @override
  String get fieldKind => 'Czym wypełniać';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count własnych pól',
      few: '$count własne pola',
      one: '$count własne pole',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'w karcie $count';
  }

  @override
  String get fieldEraseValue => 'Wymaż';

  @override
  String get yes => 'tak';

  @override
  String get no => 'nie';

  @override
  String get typeText => 'Tekst';

  @override
  String get typeNumber => 'Liczba';

  @override
  String get typeDate => 'Data';

  @override
  String get typeTime => 'Godzina';

  @override
  String get typeDuration => 'Czas trwania';

  @override
  String get typeSelect => 'Lista';

  @override
  String get typeCheckbox => 'Pole wyboru';

  @override
  String get typeUrl => 'Odnośnik';

  @override
  String get typePhone => 'Telefon';

  @override
  String get typePerson => 'Osoba';

  @override
  String get typeMoney => 'Pieniądze';

  @override
  String get searchHint => 'Znajdź wydarzenie';

  @override
  String get searchEmpty =>
      'Szukaj po nazwie, miejscu lub własnym polu — na przykład po numerze sali.';

  @override
  String get searchNothing => 'Nic nie znaleziono.';

  @override
  String get allDay => 'cały dzień';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get settingsSystem => 'Jak w systemie';

  @override
  String get settingsLight => 'Jasny';

  @override
  String get settingsDark => 'Ciemny';

  @override
  String get settingsChroma => 'Nasycenie';

  @override
  String get settingsChromaHint =>
      'Na firmowej mięcie „Soczyście” podkręca pigułki do kwaśnego tonu';

  @override
  String get settingsExact => 'Dokładnie';

  @override
  String get settingsVivid => 'Soczyście';

  @override
  String get settingsSeed => 'Kolor firmowy';

  @override
  String get settingsCalendarGroup => 'Kalendarz';

  @override
  String get settingsWeekDays => 'Dni w widoku „Tydzień”';

  @override
  String get settingsWeekFull => 'Cały tydzień';

  @override
  String get settingsWeekdaysOnly => 'Tylko dni robocze';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni w tygodniu',
      few: '$count dni w tygodniu',
      one: '$count dzień w tygodniu',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Sala, trener, numer karnetu';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsDataGroup => 'Dane';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get settingsVersion => 'Wersja';

  @override
  String get settingsStorage => 'Wszystko zostaje na urządzeniu';

  @override
  String get settingsSource => 'Kod źródłowy';

  @override
  String get monthViewTitle => 'Widok miesiąca';

  @override
  String get monthChips => 'Etykiety z nazwami';

  @override
  String get monthChipsHint => 'Widać, co dokładnie jest tego dnia';

  @override
  String get monthTint => 'Barwione komórki';

  @override
  String get monthTintHint => 'Widać, czym zajęty jest dzień';

  @override
  String get monthDensity => 'Gęstość etykiety';

  @override
  String get monthDensityBoth => 'Ikona i tekst';

  @override
  String get monthDensityIcon => 'Tylko ikona';

  @override
  String get monthPerCell => 'Wydarzeń w komórce';

  @override
  String get monthPerCellHint => 'Resztę zwijać w „+N”';

  @override
  String get eventOne => 'Wydarzenie';

  @override
  String get eventWhen => 'Kiedy';

  @override
  String get eventTime => 'Godzina';

  @override
  String get eventRepeat => 'Powtarzanie';

  @override
  String get eventCalendarAndBranch => 'Kalendarz i gałąź';

  @override
  String get eventReminder => 'Przypomnienie';

  @override
  String get eventPlace => 'Miejsce';

  @override
  String get eventPlaceHint => 'Gdzie to będzie';

  @override
  String get eventDelete => 'Usuń wydarzenie';

  @override
  String get moreDetails => 'Szczegóły';

  @override
  String get lookTitle => 'Ikona i kolor';

  @override
  String get lookInherit => 'Jak w kalendarzu';

  @override
  String get lookOwnColor => 'Własny kolor';

  @override
  String get inCard => 'w karcie';

  @override
  String get notesTitle => 'Notatki';

  @override
  String get noteOne => 'Notatka';

  @override
  String get noteAdd => 'Dodaj notatkę';

  @override
  String get noteHint => 'O czym nie zapomnieć';

  @override
  String get repeatNone => 'nie powtarza się';

  @override
  String get repeatByRule => 'według reguły';

  @override
  String get repeatTitle => 'Powtarzanie';

  @override
  String get repeatDaily => 'Codziennie';

  @override
  String get repeatWeekly => 'Co tydzień';

  @override
  String get repeatEvery => 'Co';

  @override
  String get repeatEndsWhen => 'Kiedy się kończy';

  @override
  String get repeatNextDates => 'Najbliższe daty';

  @override
  String get repeatNever => 'Nigdy';

  @override
  String get repeatUntilDate => 'Do daty';

  @override
  String repeatAfterCount(int count) {
    return 'Po $count powtórzeniach';
  }

  @override
  String get unitDay => 'Dzień';

  @override
  String get unitWeek => 'Tydzień';

  @override
  String get unitMonth => 'Miesiąc';

  @override
  String get unitYear => 'Rok';

  @override
  String get scopeTitle => 'Co zmienić';

  @override
  String scopeRepeats(String label) {
    return 'To się powtarza: $label';
  }

  @override
  String get scopeOnly => 'Tylko to jedno';

  @override
  String get scopeFollowing => 'To i następne';

  @override
  String get scopeFollowingHint =>
      'Seria się podzieli: przeszłe zostaną bez zmian';

  @override
  String get scopeWhole => 'Cała seria';

  @override
  String get scopeWholeHint => 'Wszystkie, także przeszłe';

  @override
  String get msgEventDeleted => 'Wydarzenie usunięte';

  @override
  String get msgSeriesDeleted => 'Seria usunięta';

  @override
  String get msgOccurrenceSkipped => 'Termin odwołany';

  @override
  String get reminderNone => 'Bez przypomnienia';

  @override
  String get reminderAtStart => 'W chwili startu';

  @override
  String get reminderNever => 'Nie przypominaj';

  @override
  String get reminderHint =>
      'Można kilka: dzień, żeby się przygotować, dziesięć minut, żeby wyjść';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minut wcześniej',
      few: '$count minuty wcześniej',
      one: '$count minutę wcześniej',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count godzin wcześniej',
      few: '$count godziny wcześniej',
      one: 'Godzinę wcześniej',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni wcześniej',
      few: '$count dni wcześniej',
      one: 'Dzień wcześniej',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'Tydzień wcześniej';

  @override
  String get reminderStarts => 'Zaczyna się';

  @override
  String reminderStartsAt(String time) {
    return 'Początek o $time';
  }

  @override
  String get icsExport => 'Eksportuj do .ics';

  @override
  String get icsExportHint => 'Plik dla innego kalendarza';

  @override
  String get icsImport => 'Importuj z .ics';

  @override
  String get icsImportHint => 'Wydarzenia z innego kalendarza';

  @override
  String get icsSaveTitle => 'Gdzie zapisać kalendarz';

  @override
  String get icsPickTitle => 'Wybierz plik kalendarza';

  @override
  String get icsNothingToExport => 'Nie ma czego eksportować: brak wydarzeń.';

  @override
  String icsExported(int count) {
    return 'Wyeksportowano wydarzeń: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Zaimportowano wydarzeń: $count.';
  }

  @override
  String get icsUnreadable => 'Nie udało się odczytać pliku.';

  @override
  String get icsNoEvents => 'W pliku nie znaleziono żadnego wydarzenia.';

  @override
  String get colorPickerOwn => 'Własny kolor';

  @override
  String get colorHue => 'Odcień';

  @override
  String get colorChroma => 'Nasycenie';

  @override
  String get colorTone => 'Jasność';

  @override
  String get colorMine => 'Moje kolory';

  @override
  String get colorRecent => 'Ostatnie';

  @override
  String get colorSaveMine => 'Zapisz';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Odcień $hue° · nasycenie $chroma · jasność $tone';
  }

  @override
  String get colorPickerHint =>
      'Zakraplacz pobiera kolor z tapety lub zrzutu ekranu. Zapisane trafiają do „Moich kolorów” i są dostępne wszędzie.';

  @override
  String get branchColorTitle => 'Kolor gałęzi';

  @override
  String get branchColorOwnHint => 'Ustawiony na tej gałęzi';

  @override
  String branchColorOfCalendar(String name) {
    return 'Kolor „$name”';
  }

  @override
  String get branchColorPickerRow => 'Własny kolor z próbnika';

  @override
  String get branchColorPickerHint => 'Odcień, nasycenie, hex, zakraplacz';

  @override
  String branchColorChain(String name) {
    return 'Zmienisz kolor „$name” — zmienią go wszystkie gałęzie i wydarzenia z dziedziczeniem. Te z własnym kolorem zostaną bez zmian.';
  }

  @override
  String get branchColorEventRow => 'Wydarzenie gałęzi';

  @override
  String get levelCalendar => 'kalendarz';

  @override
  String get levelOwn => 'własny';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'co $count dni',
      few: 'co $count dni',
      one: 'codziennie',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'co $count tygodni',
      few: 'co $count tygodnie',
      one: 'co tydzień',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'co $count miesięcy',
      few: 'co $count miesiące',
      one: 'co miesiąc',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'co rok';

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
      'ostatni,ostatni,ostatnia,ostatni,ostatni,ostatnia,ostatnia';

  @override
  String get ordinal1 =>
      'pierwszy,pierwszy,pierwsza,pierwszy,pierwszy,pierwsza,pierwsza';

  @override
  String get ordinal2 => 'drugi,drugi,druga,drugi,drugi,druga,druga';

  @override
  String get ordinal3 => 'trzeci,trzeci,trzecia,trzeci,trzeci,trzecia,trzecia';

  @override
  String get ordinal4 =>
      'czwarty,czwarty,czwarta,czwarty,czwarty,czwarta,czwarta';

  @override
  String get weekSetupTitle => 'Które dni pokazywać';

  @override
  String get weekSetupHint => 'Kolumn będzie tyle, ile zaznaczonych dni';

  @override
  String get weekSetupAll => 'Cały tydzień';

  @override
  String get weekSetupWorkdays => 'Dni robocze';

  @override
  String get weekSetupWeekend => 'Weekend';

  @override
  String get weekSetupStartsWith => 'Tydzień zaczyna się od';

  @override
  String get accessTitle => 'Dostęp';

  @override
  String get accessCreateKey => 'Utwórz klucz';

  @override
  String get accessRevoke => 'Odwołaj';

  @override
  String get accessHint =>
      'Klucze działają, dopóki włączona jest synchronizacja. Kalendarz, który żyje tylko w telefonie, jest z zewnątrz niedostępny — nie ma dokąd zapukać.';

  @override
  String get repeatNever2 => 'Nie powtarzaj';

  @override
  String get repeatWeekdays => 'W dni robocze';

  @override
  String get repeatCountLabel => 'Powtórzeń';

  @override
  String get repeatTimes => 'razy';

  @override
  String get repeatAfterSome => 'Po kilku powtórzeniach';

  @override
  String get repeatNoDates => 'Przy takiej regule nic nie wypadnie';

  @override
  String get unitDays => 'dni';

  @override
  String get unitWeeks => 'tygodni';

  @override
  String get unitMonths => 'miesięcy';

  @override
  String get unitYears => 'lat';

  @override
  String get repeatAdvEnd => 'Zakończenie';

  @override
  String get repeatAdvNotSet => 'Nie wybrano';

  @override
  String get repeatAdvMonthRule => 'Reguła miesiąca';

  @override
  String get repeatAdvByDate => 'Według dnia miesiąca';

  @override
  String get repeatAdvByPosition => 'Według pozycji';

  @override
  String get repeatAdvSkipped => 'Pominięte daty';

  @override
  String get repeatAdvExceptions => 'Wyjątki';

  @override
  String get repeatAdvShiftFirst => 'Przesuwaj razem z pierwszą datą';

  @override
  String get repeatAdvShiftHint =>
      'Przesunięcie pierwszej daty przesuwa całą serię';

  @override
  String get repeatAdvHolidays => 'Nie powtarzaj w święta';

  @override
  String get repeatAdvHolidaysHint => 'Uwzględnia święta w kraju';

  @override
  String get repeatAdvParsed => 'Zamienione w regułę · dotknij, aby zastosować';

  @override
  String get weekSetupCancel => 'Anuluj';

  @override
  String get searchInCalendar => 'Szukaj';

  @override
  String monthMore(int count) {
    return 'jeszcze $count';
  }

  @override
  String eventCancelOn(String date) {
    return 'Odwołaj $date';
  }

  @override
  String get eventDeleteSeries => 'Usuń całą serię';

  @override
  String get untitled => 'Bez nazwy';

  @override
  String msgCancelledNamed(String title) {
    return '„$title” odwołane';
  }

  @override
  String get iconPickerTitle => 'Ikona';

  @override
  String get iconSearchHint => 'Znajdź ikonę (po angielsku)';

  @override
  String get iconPickerCommon => 'Popularne';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono $count',
      few: 'Znaleziono $count',
      one: 'Znaleziono $count',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'Zależnie od pory dnia';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Czysto czarne tło w ciemnym motywie';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint => 'Kolor z tapety systemu (Android 12+)';

  @override
  String get settingsStartScreen => 'Ekran startowy';

  @override
  String get settingsStartScreenHint => 'Aplikacja otwiera się na nim';

  @override
  String get settingsStartView => 'Widok na starcie';

  @override
  String get placeHere => 'Jestem tutaj';

  @override
  String get placeSearchHint => 'Ulica, lokal, miasto';

  @override
  String get placeSearching => 'Szukam…';

  @override
  String get placeNoFix =>
      'Nie udało się ustalić miejsca: brak zgody lub sygnału.';

  @override
  String get msgSaveFailed => 'Nie udało się zapisać';

  @override
  String get msgNotSaved => 'Zmiany nie zostały zapisane';

  @override
  String get syncTitle => 'Synchronizacja';

  @override
  String get syncOff => 'Wyłączona, kalendarz tylko tutaj';

  @override
  String get syncClean => 'wszystko wysłane';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zmian czeka',
      few: '$count zmiany czekają',
      one: '$count zmiana czeka',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Podłącz serwer';

  @override
  String get syncServerAddress => 'Adres serwera';

  @override
  String get syncCode => 'Kod z pierwszego urządzenia';

  @override
  String get syncCodeHint => 'Puste — to pierwsze urządzenie';

  @override
  String get syncDeviceName => 'Telefon';

  @override
  String get syncConnected => 'Serwer podłączony';

  @override
  String get syncFailed => 'Nie udało się';

  @override
  String syncDone(int sent, int received) {
    return 'Wysłano $sent, odebrano $received';
  }

  @override
  String get syncPairTitle => 'Kod dla drugiego urządzenia';

  @override
  String get syncPairHint => 'Pokaż i wpisz na drugim';

  @override
  String get syncDisconnect => 'Odłącz serwer';

  @override
  String get syncDisconnectHint => 'Dane zostaną na urządzeniu';
}

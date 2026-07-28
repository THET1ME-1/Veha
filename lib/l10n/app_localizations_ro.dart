// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class LRo extends L {
  LRo([String locale = 'ro']) : super(locale);

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navList => 'Listă';

  @override
  String get navAccess => 'Acces';

  @override
  String get navSettings => 'Setări';

  @override
  String get viewDay => 'Zi';

  @override
  String get viewDays => 'Zile';

  @override
  String get viewWeek => 'Săptămână';

  @override
  String get viewMonth => 'Lună';

  @override
  String get readingClock => 'Ceas';

  @override
  String get readingChain => 'Lanț';

  @override
  String get viewNotBuilt => 'Vizualizarea nu este gata';

  @override
  String get newEvent => 'Eveniment nou';

  @override
  String get today => 'azi';

  @override
  String get nothingPlanned => 'Nimic planificat';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String spanDayOf(int current, int total) {
    return 'ziua $current din $total';
  }

  @override
  String spanUntil(String date) {
    return 'până la $date';
  }

  @override
  String get actionDone => 'Gata';

  @override
  String get actionCancel => 'Anulează';

  @override
  String get actionDelete => 'Șterge';

  @override
  String get actionSave => 'Salvează';

  @override
  String get actionAdd => 'Adaugă';

  @override
  String get actionEdit => 'Modifică';

  @override
  String get actionUndo => 'Anulează';

  @override
  String get fieldName => 'Nume';

  @override
  String get calendarsTitle => 'Calendare';

  @override
  String get calendarOne => 'Calendar';

  @override
  String get calendarNewShort => 'Nou';

  @override
  String get calendarNew => 'Calendar nou';

  @override
  String get calendarCreate => 'Creează un calendar';

  @override
  String get calendarsEmptyTitle => 'Niciun calendar';

  @override
  String get calendarsEmptyBody =>
      'Un calendar dă culoarea și pictograma tuturor evenimentelor din el. De obicei sunt trei-patru: acasă, muncă, studiu, sport.';

  @override
  String get branchOne => 'Ramură';

  @override
  String get branchNone => 'Fără ramuri';

  @override
  String get branchAdd => 'Adaugă o ramură';

  @override
  String branchOf(String name) {
    return 'Ramura „$name”';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ramuri',
      one: '$count ramură',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'Moștenit';

  @override
  String get colorOwn => 'Culoare proprie';

  @override
  String get fieldsTitle => 'Câmpuri proprii';

  @override
  String get fieldsShared => 'Comune tuturor';

  @override
  String get fieldsSharedRow => 'Câmpuri comune';

  @override
  String get fieldsGroups => 'Grupuri';

  @override
  String get fieldsNoneYet => 'Deocamdată niciunul';

  @override
  String get fieldsGroupEmpty => 'Fără câmpuri proprii';

  @override
  String get fieldsGroupCreate => 'Creează un grup de câmpuri';

  @override
  String get fieldsGroupNew => 'Grup nou';

  @override
  String fieldAddTo(String name) {
    return 'Adaugă un câmp în „$name”';
  }

  @override
  String fieldNewIn(String name) {
    return 'Câmp nou în „$name”';
  }

  @override
  String get fieldOne => 'Câmp';

  @override
  String get fieldShared => 'Comun';

  @override
  String get fieldNamePlaceholder => 'Numele câmpului';

  @override
  String get fieldKind => 'Cu ce se completează';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count câmpuri proprii',
      one: '$count câmp propriu',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'în card $count';
  }

  @override
  String get fieldEraseValue => 'Șterge';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Nu';

  @override
  String get typeText => 'Text';

  @override
  String get typeNumber => 'Număr';

  @override
  String get typeDate => 'Dată';

  @override
  String get typeTime => 'Oră';

  @override
  String get typeDuration => 'Durată';

  @override
  String get typeSelect => 'Listă';

  @override
  String get typeCheckbox => 'Bifă';

  @override
  String get typeUrl => 'Link';

  @override
  String get typePhone => 'Telefon';

  @override
  String get typePerson => 'Persoană';

  @override
  String get typeMoney => 'Bani';

  @override
  String get searchHint => 'Caută un eveniment';

  @override
  String get searchEmpty =>
      'Caută după titlu, loc sau un câmp propriu — de exemplu, după numărul sălii.';

  @override
  String get searchNothing => 'Nu s-a găsit nimic.';

  @override
  String get allDay => 'toată ziua';

  @override
  String get settingsTitle => 'Setări';

  @override
  String get settingsAppearance => 'Aspect';

  @override
  String get settingsTheme => 'Temă';

  @override
  String get settingsSystem => 'Ca în sistem';

  @override
  String get settingsLight => 'Deschisă';

  @override
  String get settingsDark => 'Închisă';

  @override
  String get settingsChroma => 'Saturație';

  @override
  String get settingsChromaHint =>
      'Pe menta de brand, „Viu” duce pastilele spre un ton acid';

  @override
  String get settingsExact => 'Exact';

  @override
  String get settingsVivid => 'Viu';

  @override
  String get settingsSeed => 'Culoarea de brand';

  @override
  String get settingsCalendarGroup => 'Calendar';

  @override
  String get settingsWeekDays => 'Zilele în vizualizarea „Săptămână”';

  @override
  String get settingsWeekFull => 'Toată săptămâna';

  @override
  String get settingsWeekdaysOnly => 'Doar zilele lucrătoare';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zile pe săptămână',
      one: '$count zi pe săptămână',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Sala, antrenorul, numărul abonamentului';

  @override
  String get settingsLanguage => 'Limbă';

  @override
  String get settingsDataGroup => 'Date';

  @override
  String get settingsAbout => 'Despre aplicație';

  @override
  String get settingsVersion => 'Versiune';

  @override
  String get settingsStorage => 'Totul rămâne pe dispozitiv';

  @override
  String get settingsSource => 'Cod sursă';

  @override
  String get monthViewTitle => 'Vizualizarea lunii';

  @override
  String get monthChips => 'Etichete cu titluri';

  @override
  String get monthChipsHint => 'Se vede exact ce e în ziua aceea';

  @override
  String get monthTint => 'Celule colorate';

  @override
  String get monthTintHint => 'Se vede cu ce e ocupată ziua';

  @override
  String get monthDensity => 'Densitatea etichetei';

  @override
  String get monthDensityBoth => 'Pictogramă și text';

  @override
  String get monthDensityIcon => 'Doar pictogramă';

  @override
  String get monthPerCell => 'Evenimente pe celulă';

  @override
  String get monthPerCellHint => 'Restul se strâng în „+N”';

  @override
  String get eventOne => 'Eveniment';

  @override
  String get eventWhen => 'Când';

  @override
  String get eventTime => 'Ora';

  @override
  String get eventRepeat => 'Repetare';

  @override
  String get eventCalendarAndBranch => 'Calendar și ramură';

  @override
  String get eventReminder => 'Memento';

  @override
  String get eventPlace => 'Loc';

  @override
  String get eventPlaceHint => 'Unde va fi';

  @override
  String get eventDelete => 'Șterge evenimentul';

  @override
  String get moreDetails => 'Detalii';

  @override
  String get lookTitle => 'Pictogramă și culoare';

  @override
  String get lookInherit => 'Ca la calendar';

  @override
  String get lookOwnColor => 'Culoare proprie';

  @override
  String get inCard => 'În card';

  @override
  String get notesTitle => 'Notițe';

  @override
  String get noteOne => 'Notiță';

  @override
  String get noteAdd => 'Adaugă o notiță';

  @override
  String get noteHint => 'Ce să nu uiți';

  @override
  String get repeatNone => 'Nu se repetă';

  @override
  String get repeatByRule => 'După regulă';

  @override
  String get repeatTitle => 'Repetare';

  @override
  String get repeatDaily => 'În fiecare zi';

  @override
  String get repeatWeekly => 'În fiecare săptămână';

  @override
  String get repeatEvery => 'La fiecare';

  @override
  String get repeatEndsWhen => 'Când se termină';

  @override
  String get repeatNextDates => 'Următoarele date';

  @override
  String get repeatNever => 'Niciodată';

  @override
  String get repeatUntilDate => 'Până la o dată';

  @override
  String repeatAfterCount(int count) {
    return 'După $count repetări';
  }

  @override
  String get unitDay => 'Zi';

  @override
  String get unitWeek => 'Săptămână';

  @override
  String get unitMonth => 'Lună';

  @override
  String get unitYear => 'An';

  @override
  String get scopeTitle => 'Ce se schimbă';

  @override
  String scopeRepeats(String label) {
    return 'Se repetă: $label';
  }

  @override
  String get scopeOnly => 'Doar această apariție';

  @override
  String get scopeFollowing => 'Aceasta și următoarele';

  @override
  String get scopeFollowingHint =>
      'Seria se împarte: cele trecute rămân cum au fost';

  @override
  String get scopeWhole => 'Toată seria';

  @override
  String get scopeWholeHint => 'Toate aparițiile, inclusiv cele trecute';

  @override
  String get msgEventDeleted => 'Eveniment șters';

  @override
  String get msgSeriesDeleted => 'Serie ștearsă';

  @override
  String get msgOccurrenceSkipped => 'Apariție anulată';

  @override
  String get reminderNone => 'Fără memento';

  @override
  String get reminderAtStart => 'La început';

  @override
  String get reminderNever => 'Fără memento';

  @override
  String get reminderHint =>
      'Poți pune mai multe: cu o zi să te pregătești, cu zece minute să pleci';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cu $count de minute înainte',
      one: 'Cu $count minut înainte',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cu $count ore înainte',
      one: 'Cu o oră înainte',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cu $count zile înainte',
      one: 'Cu o zi înainte',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'Cu o săptămână înainte';

  @override
  String get reminderStarts => 'Începe';

  @override
  String reminderStartsAt(String time) {
    return 'Începe la $time';
  }

  @override
  String get icsExport => 'Exportă în .ics';

  @override
  String get icsExportHint => 'Un fișier pentru alt calendar';

  @override
  String get icsImport => 'Importă din .ics';

  @override
  String get icsImportHint => 'Evenimente din alt calendar';

  @override
  String get icsSaveTitle => 'Unde salvăm calendarul';

  @override
  String get icsPickTitle => 'Alege un fișier de calendar';

  @override
  String get icsNothingToExport =>
      'Nu e nimic de exportat: nu există evenimente.';

  @override
  String icsExported(int count) {
    return 'Evenimente exportate: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Evenimente importate: $count.';
  }

  @override
  String get icsUnreadable => 'Fișierul nu a putut fi citit.';

  @override
  String get icsNoEvents => 'În fișier nu s-a găsit niciun eveniment.';

  @override
  String get colorPickerOwn => 'Culoare proprie';

  @override
  String get colorHue => 'Nuanță';

  @override
  String get colorChroma => 'Saturație';

  @override
  String get colorTone => 'Luminozitate';

  @override
  String get colorMine => 'Culorile mele';

  @override
  String get colorRecent => 'Recente';

  @override
  String get colorSaveMine => 'Salvează';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Nuanță $hue° · saturație $chroma · luminozitate $tone';
  }

  @override
  String get colorPickerHint =>
      'Pipeta ia culoarea din fundal sau dintr-o captură. Cele salvate stau în „Culorile mele” și sunt disponibile peste tot.';

  @override
  String get branchColorTitle => 'Culoarea ramurii';

  @override
  String get branchColorOwnHint => 'Setată pe această ramură';

  @override
  String branchColorOfCalendar(String name) {
    return 'Culoarea „$name”';
  }

  @override
  String get branchColorPickerRow => 'Culoare proprie din selector';

  @override
  String get branchColorPickerHint => 'Nuanță, saturație, hex, pipetă';

  @override
  String branchColorChain(String name) {
    return 'Dacă schimbi culoarea „$name”, se schimbă toate ramurile și evenimentele care moștenesc. Cele cu culoare proprie rămân la fel.';
  }

  @override
  String get branchColorEventRow => 'Eveniment al ramurii';

  @override
  String get levelCalendar => 'Calendar';

  @override
  String get levelOwn => 'Proprie';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count zile',
      one: 'în fiecare zi',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count săptămâni',
      one: 'în fiecare săptămână',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count luni',
      one: 'în fiecare lună',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'în fiecare an';

  @override
  String ruleWeekDays(String every, String days) {
    return '$every: $days';
  }

  @override
  String ruleMonthPosition(String every, String ordinal, String weekday) {
    return '$every: $ordinal $weekday';
  }

  @override
  String get ordinalLast => 'ultima,ultima,ultima,ultima,ultima,ultima,ultima';

  @override
  String get ordinal1 => 'prima,prima,prima,prima,prima,prima,prima';

  @override
  String get ordinal2 => 'a doua,a doua,a doua,a doua,a doua,a doua,a doua';

  @override
  String get ordinal3 =>
      'a treia,a treia,a treia,a treia,a treia,a treia,a treia';

  @override
  String get ordinal4 =>
      'a patra,a patra,a patra,a patra,a patra,a patra,a patra';

  @override
  String get weekSetupTitle => 'Ce zile să arătăm';

  @override
  String get weekSetupHint => 'Vor fi atâtea coloane câte zile sunt bifate';

  @override
  String get weekSetupAll => 'Toată săptămâna';

  @override
  String get weekSetupWorkdays => 'Zile lucrătoare';

  @override
  String get weekSetupWeekend => 'Weekend';

  @override
  String get weekSetupStartsWith => 'Săptămâna începe cu';

  @override
  String get accessTitle => 'Acces';

  @override
  String get accessCreateKey => 'Creează o cheie';

  @override
  String get accessRevoke => 'Revocă';

  @override
  String get accessHint =>
      'Cheile funcționează cât timp sincronizarea e pornită. Un calendar care trăiește doar pe telefon nu e accesibil din afară — nu ai unde să bați.';

  @override
  String get repeatNever2 => 'Nu repeta';

  @override
  String get repeatWeekdays => 'În zilele lucrătoare';

  @override
  String get repeatCountLabel => 'Repetări';

  @override
  String get repeatTimes => 'ori';

  @override
  String get repeatAfterSome => 'După câteva repetări';

  @override
  String get repeatNoDates => 'Cu această regulă nu iese nicio apariție';

  @override
  String get unitDays => 'zile';

  @override
  String get unitWeeks => 'săptămâni';

  @override
  String get unitMonths => 'luni';

  @override
  String get unitYears => 'ani';

  @override
  String get repeatAdvEnd => 'Sfârșit';

  @override
  String get repeatAdvNotSet => 'Nealeasă';

  @override
  String get repeatAdvMonthRule => 'Regula lunii';

  @override
  String get repeatAdvByDate => 'După dată';

  @override
  String get repeatAdvByPosition => 'După poziție';

  @override
  String get repeatAdvSkipped => 'Date sărite';

  @override
  String get repeatAdvExceptions => 'Excepții';

  @override
  String get repeatAdvShiftFirst => 'Mută odată cu prima dată';

  @override
  String get repeatAdvShiftHint => 'Mutarea primei date mută toată seria';

  @override
  String get repeatAdvHolidays => 'Nu repeta în sărbători';

  @override
  String get repeatAdvHolidaysHint => 'Ține cont de sărbătorile țării';

  @override
  String get repeatAdvParsed =>
      'Transformat în regulă · atinge pentru a aplica';

  @override
  String get weekSetupCancel => 'Anulează';

  @override
  String get searchInCalendar => 'Căutare';

  @override
  String monthMore(int count) {
    return 'încă $count';
  }

  @override
  String eventCancelOn(String date) {
    return 'Anulează pe $date';
  }

  @override
  String get eventDeleteSeries => 'Șterge toată seria';

  @override
  String get untitled => 'Fără titlu';

  @override
  String msgCancelledNamed(String title) {
    return '„$title” anulat';
  }

  @override
  String get iconPickerTitle => 'Pictogramă';

  @override
  String get iconSearchHint => 'Caută o pictogramă (în engleză)';

  @override
  String get iconPickerCommon => 'Frecvente';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count găsite',
      one: '$count găsită',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'După ora zilei';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Fundal negru pur în tema închisă';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint =>
      'Culoare din fundalul sistemului (Android 12+)';

  @override
  String get settingsStartScreen => 'Ecran de pornire';

  @override
  String get settingsStartScreenHint => 'Aplicația se deschide pe el';

  @override
  String get settingsStartView => 'Vizualizarea la pornire';

  @override
  String get placeHere => 'Sunt aici';

  @override
  String get placeSearchHint => 'Stradă, local, oraș';

  @override
  String get placeSearching => 'Caut…';

  @override
  String get placeNoFix =>
      'Nu am putut afla locul: fără permisiune sau semnal.';

  @override
  String get msgSaveFailed => 'Nu s-a putut salva';

  @override
  String get msgNotSaved => 'Modificările nu au fost salvate';

  @override
  String get syncTitle => 'Sincronizare';

  @override
  String get syncOff => 'Oprită, calendarul e doar aici';

  @override
  String get syncClean => 'Totul trimis';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modificări așteaptă',
      one: '$count modificare așteaptă',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Conectează un server';

  @override
  String get syncServerAddress => 'Adresa serverului';

  @override
  String get syncCode => 'Cod de pe primul dispozitiv';

  @override
  String get syncCodeHint => 'Gol înseamnă că e primul dispozitiv';

  @override
  String get syncDeviceName => 'Telefon';

  @override
  String get syncConnected => 'Server conectat';

  @override
  String get syncFailed => 'Nu a mers';

  @override
  String syncDone(int sent, int received) {
    return 'Trimise $sent, primite $received';
  }

  @override
  String get syncPairTitle => 'Cod pentru al doilea dispozitiv';

  @override
  String get syncPairHint => 'Arată-l și scrie-l pe celălalt';

  @override
  String get syncDisconnect => 'Deconectează serverul';

  @override
  String get syncDisconnectHint => 'Datele rămân pe dispozitiv';

  @override
  String get accessNeedsSync => 'Cheile apar când pornești sincronizarea';

  @override
  String get accessNoKeys => 'Nicio cheie';

  @override
  String get accessLoading => 'Se încarcă…';

  @override
  String get accessKeyName => 'Numele agentului';

  @override
  String get accessScopesHint => 'Ce calendare vede cheia și unde poate scrie';

  @override
  String get accessReadOnly => 'Doar citire';

  @override
  String get accessWrite => 'Citire și scriere';

  @override
  String get accessKeyOnce => 'Cheia se arată o singură dată';

  @override
  String get accessKeyOnceHint =>
      'Copiaz-o acum în agent: pe server a rămas doar un hash, iar șirul nu poate fi recuperat.';

  @override
  String accessLastUsed(String when) {
    return 'A lucrat $when';
  }

  @override
  String get accessNeverUsed => 'Încă nefolosită';

  @override
  String get accessRevoked => 'Revocată';

  @override
  String get accessLog => 'Jurnal';

  @override
  String get accessLogEmpty => 'Cheia nu a atins nimic încă';
}

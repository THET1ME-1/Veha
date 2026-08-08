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
      'Pipeta ia culoarea dintr-o imagine: deschide o captură sau o fotografie și atinge locul dorit. Culorile salvate stau în «Culorile mele» și apar în orice selector.';

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

  @override
  String get photosTitle => 'Fotografii';

  @override
  String get photoAdd => 'Adaugă o fotografie';

  @override
  String get photoCamera => 'Fotografiază';

  @override
  String get photoGallery => 'Din galerie';

  @override
  String get photoRemove => 'Șterge fotografia';

  @override
  String get photoRemoveAsk => 'Ștergi această fotografie?';

  @override
  String get photoNeedsSave =>
      'Fotografiile apar după ce evenimentul este salvat';

  @override
  String get navTasks => 'Sarcini';

  @override
  String get tasksEmpty => 'Deocamdată nicio sarcină';

  @override
  String get tasksEmptyHint => 'Butonul de jos o adaugă pe prima';

  @override
  String get taskNew => 'Sarcină nouă';

  @override
  String get taskOne => 'Sarcină';

  @override
  String get taskTitleHint => 'Ce ai de făcut';

  @override
  String get taskDue => 'Termen';

  @override
  String get taskNoDue => 'Fără termen';

  @override
  String get taskAtTime => 'La o oră';

  @override
  String get taskNotes => 'Notă';

  @override
  String get taskNotesHint => 'Detalii';

  @override
  String get taskDelete => 'Șterge sarcina';

  @override
  String get taskOverdue => 'Depășit';

  @override
  String get tasksDoneSection => 'Făcute';

  @override
  String tasksOpenCount(int count) {
    return '$count în lucru';
  }

  @override
  String get msgTaskDeleted => 'Sarcina a fost ștearsă';

  @override
  String get dueToday => 'Azi';

  @override
  String get dueTomorrow => 'Mâine';

  @override
  String get statsTitle => 'Statistici';

  @override
  String get statsWeek => 'Săptămână';

  @override
  String get statsMonth => 'Lună';

  @override
  String get statsYear => 'An';

  @override
  String get statsBusyTime => 'Timp ocupat';

  @override
  String get statsEventCount => 'Evenimente';

  @override
  String get statsTasksClosed => 'Sarcini încheiate';

  @override
  String get statsPerDay => 'În medie pe zi';

  @override
  String get statsByCalendar => 'Pe calendare';

  @override
  String get statsByWeekday => 'Pe zilele săptămânii';

  @override
  String get statsBusiestDay => 'Cea mai plină zi';

  @override
  String get statsEmpty => 'Nimic în această perioadă';

  @override
  String statsHoursShort(String hours) {
    return '$hours h';
  }

  @override
  String statsShare(int percent) {
    return '$percent%';
  }

  @override
  String get colorSaved => 'Culoarea e în «Ale mele»';

  @override
  String get colorAlreadySaved => 'Culoarea e deja salvată';

  @override
  String get colorRemovedFromMine => 'Scos din «Ale mele»';

  @override
  String get colorCopied => 'Codul a fost copiat';

  @override
  String get colorCopy => 'Copiază codul';

  @override
  String get colorPickFromImage => 'Ia culoarea dintr-o imagine';

  @override
  String get colorTapImage => 'Atinge imaginea — culoarea se ia de acolo';

  @override
  String get colorHexHint => 'Codul tău';

  @override
  String scopeOnlyHint(String day) {
    return '$day se schimbă, restul rămân la locul lor';
  }

  @override
  String get scopeDeleteTitle => 'Ce ștergem';

  @override
  String scopeDeleteOnlyHint(String day) {
    return '$day dispare, seria rămâne';
  }

  @override
  String get scopeDeleteFollowingHint =>
      'Seria se oprește la această dată; cele trecute rămân';

  @override
  String get scopeDeleteWholeHint => 'Dispar toate, inclusiv cele trecute';

  @override
  String get msgSeriesTrimmed => 'Seria se oprește la această dată';

  @override
  String get eventDuplicate => 'Fă o copie';

  @override
  String eventCopySuffix(String title) {
    return '$title — copie';
  }

  @override
  String get moveTitle => 'Mută';

  @override
  String get moveTomorrow => 'Pe mâine';

  @override
  String get moveNextWeek => 'Peste o săptămână';

  @override
  String get movePickDate => 'Alege data';

  @override
  String msgEventMoved(String day) {
    return 'Mutat pe $day';
  }

  @override
  String get actionShare => 'Partajează';

  @override
  String get msgEventCopiedText => 'Evenimentul a fost copiat ca text';

  @override
  String get eventOpenMap => 'Deschide pe hartă';

  @override
  String get previewActions => 'Acțiuni';

  @override
  String get seriesPause => 'Pauză la serie';

  @override
  String seriesPauseWeeks(int weeks) {
    return 'Sar $weeks săpt.';
  }

  @override
  String msgSeriesPaused(int count) {
    return 'Ocurențe sărite: $count';
  }

  @override
  String get lookReset => 'Ca la ramură';

  @override
  String get msgLookReset => 'Culoarea și pictograma se moștenesc din nou';

  @override
  String get toTask => 'Fă din el o sarcină';

  @override
  String get msgBecameTask => 'Evenimentul a devenit sarcină';

  @override
  String get shiftRest => 'Mută restul zilei';

  @override
  String msgDayShifted(int count) {
    return 'Mutate după el: $count';
  }

  @override
  String get repeatDay => 'Repetă ziua';

  @override
  String msgDayCopied(String day, int count) {
    return 'Ziua a fost copiată pe $day: $count evenimente';
  }

  @override
  String get stretchToNext => 'Întinde până la următorul';

  @override
  String msgStretched(String time) {
    return 'Evenimentul ține până la $time';
  }

  @override
  String get nothingToShift => 'Nimic mai departe în ziua asta';

  @override
  String msgEventShifted(String time) {
    return 'Eveniment la $time';
  }

  @override
  String msgEventResized(String time) {
    return 'Acum până la $time';
  }

  @override
  String msgOverlaps(String title) {
    return 'Se suprapune: $title';
  }

  @override
  String get quickPhraseHint => 'Apel mâine la 15:00 o oră';

  @override
  String get quickPhraseRead => 'Am înțeles din text';

  @override
  String get findSlot => 'Prima fereastră liberă';

  @override
  String msgSlotFound(String when) {
    return 'Liber: $when';
  }

  @override
  String get msgNoSlot => 'Nicio fereastră în următoarele două săptămâni';

  @override
  String get trashTitle => 'Coș';

  @override
  String get trashHint => 'Ștersele se păstrează 90 de zile';

  @override
  String get trashEmpty => 'Coșul e gol';

  @override
  String get trashRestore => 'Restaurează';

  @override
  String get trashClear => 'Golește coșul';

  @override
  String msgTrashCleared(int count) {
    return 'Înregistrări șterse: $count';
  }

  @override
  String msgRestored(String title) {
    return 'Restaurat: $title';
  }

  @override
  String get calendarDefaults => 'Implicite';

  @override
  String get calendarDefaultReminder => 'Amintire la evenimente noi';

  @override
  String get calendarDefaultDuration => 'Durata evenimentelor noi';

  @override
  String get actionSelect => 'Selectează mai multe';

  @override
  String selectedCount(int count) {
    return 'Selectate: $count';
  }

  @override
  String get bulkMove => 'Mută';

  @override
  String get bulkCalendar => 'În calendar';

  @override
  String msgBulkMoved(int count) {
    return 'Evenimente mutate: $count';
  }

  @override
  String msgBulkDeleted(int count) {
    return 'Evenimente șterse: $count';
  }

  @override
  String msgBulkCalendar(int count) {
    return 'Evenimente în alt calendar: $count';
  }

  @override
  String get eventOpenEnd => 'Fără oră de final';

  @override
  String timeFrom(String time) {
    return 'de la $time';
  }

  @override
  String get noteMarkupHint => '„- ” face un punct, „[ ] ” o bifă';

  @override
  String get dayReviewTitle => 'Ziua pe scurt';

  @override
  String get dayReviewBusy => 'Ocupat';

  @override
  String get dayReviewFree => 'Liber';

  @override
  String get dayReviewLongest => 'Cel mai lung';

  @override
  String dayReviewClashes(int count) {
    return 'Suprapuneri: $count';
  }

  @override
  String get dayReviewGaps => 'Unde încape';

  @override
  String get dayReviewNoBreaks => 'O zi fără nicio pauză';

  @override
  String get dayReviewEmpty => 'Nimic programat în această zi';

  @override
  String get filesTitle => 'Atașamente';

  @override
  String get fileAttach => 'Atașează un fișier';

  @override
  String get fileRemove => 'Elimină atașamentul';

  @override
  String get fileMissing => 'Fișierul nu mai este pe dispozitiv';

  @override
  String get historyTitle => 'Istoricul modificărilor';

  @override
  String get historyCreated => 'Eveniment creat';

  @override
  String get historyName => 'Titlu';

  @override
  String get historyTime => 'Ora';

  @override
  String get historyEmpty => 'Nimic nu a fost modificat încă';

  @override
  String sizeBytes(String value) {
    return '$value B';
  }

  @override
  String sizeKb(String value) {
    return '$value KB';
  }

  @override
  String sizeMb(String value) {
    return '$value MB';
  }

  @override
  String get eventTravel => 'Timp de deplasare';

  @override
  String get travelNone => 'Nu socoti';

  @override
  String travelLeaveAt(String time) {
    return 'Pleacă la $time';
  }

  @override
  String get storageFailed => 'Calendarul nu s-a deschis. Reporniți aplicația';

  @override
  String get storageRetry => 'Reîncercați';

  @override
  String get hiddenCalendarWarning =>
      'Evenimentul este într-un calendar ascuns și nu apare în grilă';

  @override
  String get hiddenCalendarShow => 'Afișați';

  @override
  String get previewMore => 'Mai multe';

  @override
  String monthOnDay(int day) {
    return 'În ziua $day';
  }

  @override
  String get monthLastWorkday => 'Ultima zi lucrătoare';

  @override
  String get monthRuleTitle => 'Cum se măsoară luna';

  @override
  String everyDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count zile',
      one: 'în fiecare zi',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count săptămâni',
      one: 'în fiecare săptămână',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count luni',
      one: 'în fiecare lună',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la fiecare $count ani',
      one: 'în fiecare an',
    );
    return '$_temp0';
  }

  @override
  String get repeatHowOften => 'Cât de des';

  @override
  String get calendarSharing => 'Ce ajunge pe server';

  @override
  String get calendarShared => 'Calendar partajat';

  @override
  String get calendarSharedOn => 'Pleacă pe server';

  @override
  String get calendarSharedOff => 'Rămâne pe dispozitiv';

  @override
  String get syncSharedList => 'Trimis pe server';

  @override
  String get syncSharedNone => 'Nimic: totul rămâne pe dispozitiv';

  @override
  String get eventDescription => 'Descriere';

  @override
  String get eventDescriptionHint => 'Ce să luați, ce s-a stabilit';

  @override
  String get eventHoldsTime => 'Ocupă timp';

  @override
  String get dayOpenFull => 'Deschideți ziua';

  @override
  String get dayEmpty => 'Nimic planificat pentru această zi';

  @override
  String get monthDensityText => 'Doar text';
}

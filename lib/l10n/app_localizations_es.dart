// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navList => 'Lista';

  @override
  String get navAccess => 'Acceso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get viewDay => 'Día';

  @override
  String get viewDays => 'Días';

  @override
  String get viewWeek => 'Semana';

  @override
  String get viewMonth => 'Mes';

  @override
  String get readingClock => 'Reloj';

  @override
  String get readingChain => 'Cadena';

  @override
  String get viewNotBuilt => 'Esta vista aún no está lista';

  @override
  String get newEvent => 'Nuevo evento';

  @override
  String get today => 'hoy';

  @override
  String get nothingPlanned => 'Nada planeado';

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
    return 'día $current de $total';
  }

  @override
  String spanUntil(String date) {
    return 'hasta $date';
  }

  @override
  String get actionDone => 'Listo';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get fieldName => 'Nombre';

  @override
  String get calendarsTitle => 'Calendarios';

  @override
  String get calendarOne => 'Calendario';

  @override
  String get calendarNewShort => 'Nuevo';

  @override
  String get calendarNew => 'Calendario nuevo';

  @override
  String get calendarCreate => 'Crear un calendario';

  @override
  String get calendarsEmptyTitle => 'Ningún calendario';

  @override
  String get calendarsEmptyBody =>
      'Un calendario define el color y el icono de todos sus eventos. Suelen ser tres o cuatro: casa, trabajo, estudio, deporte.';

  @override
  String get branchOne => 'Rama';

  @override
  String get branchNone => 'Sin ramas';

  @override
  String get branchAdd => 'Añadir rama';

  @override
  String branchOf(String name) {
    return 'Rama «$name»';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ramas',
      one: '$count rama',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'Heredado';

  @override
  String get colorOwn => 'Color propio';

  @override
  String get fieldsTitle => 'Campos propios';

  @override
  String get fieldsShared => 'Comunes para todos';

  @override
  String get fieldsSharedRow => 'Campos comunes';

  @override
  String get fieldsGroups => 'Grupos';

  @override
  String get fieldsNoneYet => 'Ninguno todavía';

  @override
  String get fieldsGroupEmpty => 'Sin campos propios';

  @override
  String get fieldsGroupCreate => 'Crear un grupo de campos';

  @override
  String get fieldsGroupNew => 'Grupo nuevo';

  @override
  String fieldAddTo(String name) {
    return 'Añadir un campo a «$name»';
  }

  @override
  String fieldNewIn(String name) {
    return 'Campo nuevo en «$name»';
  }

  @override
  String get fieldOne => 'Campo';

  @override
  String get fieldShared => 'Común';

  @override
  String get fieldNamePlaceholder => 'Nombre del campo';

  @override
  String get fieldKind => 'Con qué se rellena';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos propios',
      one: '$count campo propio',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'en la tarjeta $count';
  }

  @override
  String get fieldEraseValue => 'Borrar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get typeText => 'Texto';

  @override
  String get typeNumber => 'Número';

  @override
  String get typeDate => 'Fecha';

  @override
  String get typeTime => 'Hora';

  @override
  String get typeDuration => 'Duración';

  @override
  String get typeSelect => 'Lista';

  @override
  String get typeCheckbox => 'Casilla';

  @override
  String get typeUrl => 'Enlace';

  @override
  String get typePhone => 'Teléfono';

  @override
  String get typePerson => 'Persona';

  @override
  String get typeMoney => 'Dinero';

  @override
  String get searchHint => 'Buscar un evento';

  @override
  String get searchEmpty =>
      'Busca por título, lugar o un campo propio: por ejemplo, el número de aula.';

  @override
  String get searchNothing => 'No se encontró nada.';

  @override
  String get allDay => 'todo el día';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSystem => 'Como el sistema';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsChroma => 'Saturación';

  @override
  String get settingsChromaHint =>
      'Sobre el menta de marca, «Vivo» lleva las píldoras a un tono ácido';

  @override
  String get settingsExact => 'Exacto';

  @override
  String get settingsVivid => 'Vivo';

  @override
  String get settingsSeed => 'Color de marca';

  @override
  String get settingsCalendarGroup => 'Calendario';

  @override
  String get settingsWeekDays => 'Días en la vista «Semana»';

  @override
  String get settingsWeekFull => 'Semana entera';

  @override
  String get settingsWeekdaysOnly => 'Solo días laborables';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días por semana',
      one: '$count día por semana',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Aula, entrenador, número de abono';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsDataGroup => 'Datos';

  @override
  String get settingsAbout => 'Acerca de la app';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsStorage => 'Todo se guarda en el dispositivo';

  @override
  String get settingsSource => 'Código fuente';

  @override
  String get monthViewTitle => 'Vista del mes';

  @override
  String get monthChips => 'Fichas con títulos';

  @override
  String get monthChipsHint => 'Se ve exactamente qué hay ese día';

  @override
  String get monthTint => 'Celdas tintadas';

  @override
  String get monthTintHint => 'Se ve con qué está ocupado el día';

  @override
  String get monthDensity => 'Densidad de la ficha';

  @override
  String get monthDensityBoth => 'Icono y texto';

  @override
  String get monthDensityIcon => 'Solo icono';

  @override
  String get monthPerCell => 'Eventos por celda';

  @override
  String get monthPerCellHint => 'El resto se pliega en «+N»';

  @override
  String get eventOne => 'Evento';

  @override
  String get eventWhen => 'Cuándo';

  @override
  String get eventTime => 'Hora';

  @override
  String get eventRepeat => 'Repetición';

  @override
  String get eventCalendarAndBranch => 'Calendario y rama';

  @override
  String get eventReminder => 'Recordatorio';

  @override
  String get eventPlace => 'Lugar';

  @override
  String get eventPlaceHint => 'Dónde será';

  @override
  String get eventDelete => 'Eliminar el evento';

  @override
  String get moreDetails => 'Más';

  @override
  String get lookTitle => 'Icono y color';

  @override
  String get lookInherit => 'Igual que el calendario';

  @override
  String get lookOwnColor => 'Color propio';

  @override
  String get inCard => 'En la tarjeta';

  @override
  String get notesTitle => 'Notas';

  @override
  String get noteOne => 'Nota';

  @override
  String get noteAdd => 'Añadir una nota';

  @override
  String get noteHint => 'Qué no olvidar';

  @override
  String get repeatNone => 'No se repite';

  @override
  String get repeatByRule => 'Según la regla';

  @override
  String get repeatTitle => 'Repetición';

  @override
  String get repeatDaily => 'Cada día';

  @override
  String get repeatWeekly => 'Cada semana';

  @override
  String get repeatEvery => 'Cada';

  @override
  String get repeatEndsWhen => 'Cuándo termina';

  @override
  String get repeatNextDates => 'Próximas fechas';

  @override
  String get repeatNever => 'Nunca';

  @override
  String get repeatUntilDate => 'Hasta una fecha';

  @override
  String repeatAfterCount(int count) {
    return 'Tras $count repeticiones';
  }

  @override
  String get unitDay => 'Día';

  @override
  String get unitWeek => 'Semana';

  @override
  String get unitMonth => 'Mes';

  @override
  String get unitYear => 'Año';

  @override
  String get scopeTitle => 'Qué cambiar';

  @override
  String scopeRepeats(String label) {
    return 'Se repite: $label';
  }

  @override
  String get scopeOnly => 'Solo esta vez';

  @override
  String get scopeFollowing => 'Esta y las siguientes';

  @override
  String get scopeFollowingHint =>
      'La serie se divide: las pasadas quedan como estaban';

  @override
  String get scopeWhole => 'Toda la serie';

  @override
  String get scopeWholeHint => 'Todas, incluidas las pasadas';

  @override
  String get msgEventDeleted => 'Evento eliminado';

  @override
  String get msgSeriesDeleted => 'Serie eliminada';

  @override
  String get msgOccurrenceSkipped => 'Cita cancelada';

  @override
  String get reminderNone => 'Sin recordatorio';

  @override
  String get reminderAtStart => 'Al comenzar';

  @override
  String get reminderNever => 'No recordar';

  @override
  String get reminderHint =>
      'Puedes poner varios: un día para prepararte, diez minutos para salir';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos antes',
      one: '$count minuto antes',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas antes',
      one: 'Una hora antes',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días antes',
      one: 'Un día antes',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'Una semana antes';

  @override
  String get reminderStarts => 'Comienza';

  @override
  String reminderStartsAt(String time) {
    return 'Comienza a las $time';
  }

  @override
  String get icsExport => 'Exportar a .ics';

  @override
  String get icsExportHint => 'Un archivo para otro calendario';

  @override
  String get icsImport => 'Importar desde .ics';

  @override
  String get icsImportHint => 'Eventos de otro calendario';

  @override
  String get icsSaveTitle => 'Dónde guardar el calendario';

  @override
  String get icsPickTitle => 'Elige un archivo de calendario';

  @override
  String get icsNothingToExport => 'No hay nada que exportar: no hay eventos.';

  @override
  String icsExported(int count) {
    return 'Eventos exportados: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Eventos importados: $count.';
  }

  @override
  String get icsUnreadable => 'No se pudo leer el archivo.';

  @override
  String get icsNoEvents => 'No se encontró ningún evento en el archivo.';

  @override
  String get colorPickerOwn => 'Color propio';

  @override
  String get colorHue => 'Tono';

  @override
  String get colorChroma => 'Saturación';

  @override
  String get colorTone => 'Luminosidad';

  @override
  String get colorMine => 'Mis colores';

  @override
  String get colorRecent => 'Recientes';

  @override
  String get colorSaveMine => 'Guardar';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Tono $hue° · saturación $chroma · luminosidad $tone';
  }

  @override
  String get colorPickerHint =>
      'El cuentagotas toma el color de una imagen: abre una captura o una foto y toca el punto que quieras. Los colores guardados viven en «Mis colores» y están en cualquier selector.';

  @override
  String get branchColorTitle => 'Color de la rama';

  @override
  String get branchColorOwnHint => 'Definido en esta rama';

  @override
  String branchColorOfCalendar(String name) {
    return 'Color de «$name»';
  }

  @override
  String get branchColorPickerRow => 'Color propio del selector';

  @override
  String get branchColorPickerHint => 'Tono, saturación, hex, cuentagotas';

  @override
  String branchColorChain(String name) {
    return 'Si cambias el color de «$name», cambian todas las ramas y eventos que heredan. Las de color propio se quedan igual.';
  }

  @override
  String get branchColorEventRow => 'Evento de la rama';

  @override
  String get levelCalendar => 'Calendario';

  @override
  String get levelOwn => 'Propio';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count días',
      one: 'cada día',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count semanas',
      one: 'cada semana',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count meses',
      one: 'cada mes',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'cada año';

  @override
  String ruleWeekDays(String every, String days) {
    return '$every: $days';
  }

  @override
  String ruleMonthPosition(String every, String ordinal, String weekday) {
    return '$every: el $ordinal $weekday';
  }

  @override
  String get ordinalLast => 'último,último,último,último,último,último,último';

  @override
  String get ordinal1 => 'primer,primer,primer,primer,primer,primer,primer';

  @override
  String get ordinal2 =>
      'segundo,segundo,segundo,segundo,segundo,segundo,segundo';

  @override
  String get ordinal3 => 'tercer,tercer,tercer,tercer,tercer,tercer,tercer';

  @override
  String get ordinal4 => 'cuarto,cuarto,cuarto,cuarto,cuarto,cuarto,cuarto';

  @override
  String get weekSetupTitle => 'Qué días mostrar';

  @override
  String get weekSetupHint => 'Habrá tantas columnas como días marcados';

  @override
  String get weekSetupAll => 'Semana entera';

  @override
  String get weekSetupWorkdays => 'Días laborables';

  @override
  String get weekSetupWeekend => 'Fin de semana';

  @override
  String get weekSetupStartsWith => 'La semana empieza el';

  @override
  String get accessTitle => 'Acceso';

  @override
  String get accessCreateKey => 'Crear una clave';

  @override
  String get accessRevoke => 'Revocar';

  @override
  String get accessHint =>
      'Las claves funcionan mientras la sincronización esté activa. Un calendario que solo vive en el teléfono no es accesible desde fuera.';

  @override
  String get repeatNever2 => 'No repetir';

  @override
  String get repeatWeekdays => 'En días laborables';

  @override
  String get repeatCountLabel => 'Repeticiones';

  @override
  String get repeatTimes => 'veces';

  @override
  String get repeatAfterSome => 'Tras varias repeticiones';

  @override
  String get repeatNoDates => 'Con esta regla no habrá ninguna cita';

  @override
  String get unitDays => 'días';

  @override
  String get unitWeeks => 'semanas';

  @override
  String get unitMonths => 'meses';

  @override
  String get unitYears => 'años';

  @override
  String get repeatAdvEnd => 'Final';

  @override
  String get repeatAdvNotSet => 'Sin elegir';

  @override
  String get repeatAdvMonthRule => 'Regla del mes';

  @override
  String get repeatAdvByDate => 'Por fecha';

  @override
  String get repeatAdvByPosition => 'Por posición';

  @override
  String get repeatAdvSkipped => 'Fechas omitidas';

  @override
  String get repeatAdvExceptions => 'Excepciones';

  @override
  String get repeatAdvShiftFirst => 'Desplazar junto con la primera fecha';

  @override
  String get repeatAdvShiftHint => 'Mover la primera fecha mueve toda la serie';

  @override
  String get repeatAdvHolidays => 'No repetir en festivos';

  @override
  String get repeatAdvHolidaysHint => 'Según los festivos del país';

  @override
  String get repeatAdvParsed => 'Convertido en regla · toca para aplicar';

  @override
  String get weekSetupCancel => 'Cancelar';

  @override
  String get searchInCalendar => 'Buscar';

  @override
  String monthMore(int count) {
    return '$count más';
  }

  @override
  String eventCancelOn(String date) {
    return 'Cancelar el $date';
  }

  @override
  String get eventDeleteSeries => 'Eliminar toda la serie';

  @override
  String get untitled => 'Sin título';

  @override
  String msgCancelledNamed(String title) {
    return '«$title» cancelado';
  }

  @override
  String get iconPickerTitle => 'Icono';

  @override
  String get iconSearchHint => 'Buscar un icono (en inglés)';

  @override
  String get iconPickerCommon => 'Frecuentes';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontrados',
      one: '$count encontrado',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'Según la hora del día';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Fondo negro puro en el tema oscuro';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint =>
      'Color del fondo del sistema (Android 12+)';

  @override
  String get settingsStartScreen => 'Pantalla de inicio';

  @override
  String get settingsStartScreenHint => 'La app se abre en ella';

  @override
  String get settingsStartView => 'Vista al inicio';

  @override
  String get placeHere => 'Estoy aquí';

  @override
  String get placeSearchHint => 'Calle, local, ciudad';

  @override
  String get placeSearching => 'Buscando…';

  @override
  String get placeNoFix =>
      'No se pudo obtener el lugar: sin permiso o sin señal.';

  @override
  String get msgSaveFailed => 'No se pudo guardar';

  @override
  String get msgNotSaved => 'Los cambios no se guardaron';

  @override
  String get syncTitle => 'Sincronización';

  @override
  String get syncOff => 'Desactivada: el calendario vive solo aquí';

  @override
  String get syncClean => 'Todo enviado';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios en espera',
      one: '$count cambio en espera',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Conectar un servidor';

  @override
  String get syncServerAddress => 'Dirección del servidor';

  @override
  String get syncCode => 'Código del primer dispositivo';

  @override
  String get syncCodeHint => 'Vacío significa que es el primer dispositivo';

  @override
  String get syncDeviceName => 'Teléfono';

  @override
  String get syncConnected => 'Servidor conectado';

  @override
  String get syncFailed => 'No funcionó';

  @override
  String syncDone(int sent, int received) {
    return 'Enviados $sent, recibidos $received';
  }

  @override
  String get syncPairTitle => 'Código para un segundo dispositivo';

  @override
  String get syncPairHint => 'Muéstralo y escríbelo en el otro';

  @override
  String get syncDisconnect => 'Desconectar el servidor';

  @override
  String get syncDisconnectHint => 'Los datos se quedan en el dispositivo';

  @override
  String get accessNeedsSync =>
      'Las claves aparecen al activar la sincronización';

  @override
  String get accessNoKeys => 'Ninguna clave';

  @override
  String get accessLoading => 'Cargando…';

  @override
  String get accessKeyName => 'Nombre del agente';

  @override
  String get accessScopesHint =>
      'Qué calendarios ve la clave y dónde puede escribir';

  @override
  String get accessReadOnly => 'Solo lectura';

  @override
  String get accessWrite => 'Lectura y escritura';

  @override
  String get accessKeyOnce => 'La clave se muestra una vez';

  @override
  String get accessKeyOnceHint =>
      'Cópiala ahora en tu agente: en el servidor solo queda un hash y la cadena no se puede recuperar.';

  @override
  String accessLastUsed(String when) {
    return 'Usada $when';
  }

  @override
  String get accessNeverUsed => 'Aún sin usar';

  @override
  String get accessRevoked => 'Revocada';

  @override
  String get accessLog => 'Registro';

  @override
  String get accessLogEmpty => 'La clave aún no ha tocado nada';

  @override
  String get photosTitle => 'Fotos';

  @override
  String get photoAdd => 'Añadir foto';

  @override
  String get photoCamera => 'Hacer una foto';

  @override
  String get photoGallery => 'De la galería';

  @override
  String get photoRemove => 'Quitar la foto';

  @override
  String get photoRemoveAsk => '¿Quitar esta foto?';

  @override
  String get photoNeedsSave =>
      'Las fotos aparecen cuando el evento está guardado';

  @override
  String get navTasks => 'Tareas';

  @override
  String get tasksEmpty => 'Todavía no hay tareas';

  @override
  String get tasksEmptyHint => 'El botón de abajo crea la primera';

  @override
  String get taskNew => 'Tarea nueva';

  @override
  String get taskOne => 'Tarea';

  @override
  String get taskTitleHint => 'Qué hacer';

  @override
  String get taskDue => 'Plazo';

  @override
  String get taskNoDue => 'Sin plazo';

  @override
  String get taskAtTime => 'A una hora';

  @override
  String get taskNotes => 'Nota';

  @override
  String get taskNotesHint => 'Detalles';

  @override
  String get taskDelete => 'Eliminar la tarea';

  @override
  String get taskOverdue => 'Vencida';

  @override
  String get tasksDoneSection => 'Hechas';

  @override
  String tasksOpenCount(int count) {
    return '$count pendientes';
  }

  @override
  String get msgTaskDeleted => 'Tarea eliminada';

  @override
  String get dueToday => 'Hoy';

  @override
  String get dueTomorrow => 'Mañana';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsWeek => 'Semana';

  @override
  String get statsMonth => 'Mes';

  @override
  String get statsYear => 'Año';

  @override
  String get statsBusyTime => 'Tiempo ocupado';

  @override
  String get statsEventCount => 'Eventos';

  @override
  String get statsTasksClosed => 'Tareas cerradas';

  @override
  String get statsPerDay => 'Media por día';

  @override
  String get statsByCalendar => 'Por calendarios';

  @override
  String get statsByWeekday => 'Por días de la semana';

  @override
  String get statsBusiestDay => 'El día más lleno';

  @override
  String get statsEmpty => 'No hay nada en este periodo';

  @override
  String statsHoursShort(String hours) {
    return '$hours h';
  }

  @override
  String statsShare(int percent) {
    return '$percent %';
  }

  @override
  String get colorSaved => 'Color en «Mis colores»';

  @override
  String get colorAlreadySaved => 'Ese color ya está guardado';

  @override
  String get colorRemovedFromMine => 'Quitado de «Mis colores»';

  @override
  String get colorCopied => 'Código copiado';

  @override
  String get colorCopy => 'Copiar el código';

  @override
  String get colorPickFromImage => 'Tomar el color de una imagen';

  @override
  String get colorTapImage => 'Toca la imagen y el color se toma de ahí';

  @override
  String get colorHexHint => 'Tu código';

  @override
  String scopeOnlyHint(String day) {
    return '$day cambia, el resto se queda';
  }

  @override
  String get scopeDeleteTitle => 'Qué eliminar';

  @override
  String scopeDeleteOnlyHint(String day) {
    return '$day desaparece, la serie se queda';
  }

  @override
  String get scopeDeleteFollowingHint =>
      'La serie termina en esta fecha; lo pasado se queda';

  @override
  String get scopeDeleteWholeHint => 'Desaparecen todas, también las pasadas';

  @override
  String get msgSeriesTrimmed => 'La serie termina en esta fecha';

  @override
  String get eventDuplicate => 'Hacer una copia';

  @override
  String eventCopySuffix(String title) {
    return '$title — copia';
  }

  @override
  String get moveTitle => 'Mover';

  @override
  String get moveTomorrow => 'A mañana';

  @override
  String get moveNextWeek => 'En una semana';

  @override
  String get movePickDate => 'Elegir fecha';

  @override
  String msgEventMoved(String day) {
    return 'Movido al $day';
  }

  @override
  String get actionShare => 'Compartir';

  @override
  String get msgEventCopiedText => 'Evento copiado como texto';

  @override
  String get eventOpenMap => 'Abrir en el mapa';

  @override
  String get previewActions => 'Acciones';

  @override
  String get seriesPause => 'Pausar la serie';

  @override
  String seriesPauseWeeks(int weeks) {
    return 'Sin $weeks sem.';
  }

  @override
  String msgSeriesPaused(int count) {
    return 'Ocurrencias omitidas: $count';
  }

  @override
  String get lookReset => 'Como la rama';

  @override
  String get msgLookReset => 'El color y el icono se heredan de nuevo';

  @override
  String get toTask => 'Convertir en tarea';

  @override
  String get msgBecameTask => 'El evento ahora es una tarea';

  @override
  String get shiftRest => 'Mover el resto del día';

  @override
  String msgDayShifted(int count) {
    return 'Movidos detrás: $count';
  }

  @override
  String get repeatDay => 'Repetir el día';

  @override
  String msgDayCopied(String day, int count) {
    return 'Día copiado al $day: $count eventos';
  }

  @override
  String get stretchToNext => 'Estirar hasta el siguiente';

  @override
  String msgStretched(String time) {
    return 'El evento va hasta las $time';
  }

  @override
  String get nothingToShift => 'No hay nada más ese día';

  @override
  String msgEventShifted(String time) {
    return 'Evento a las $time';
  }

  @override
  String msgEventResized(String time) {
    return 'Ahora hasta las $time';
  }

  @override
  String msgOverlaps(String title) {
    return 'Se cruza con: $title';
  }

  @override
  String get quickPhraseHint => 'Llamada mañana a las 15:00 una hora';

  @override
  String get quickPhraseRead => 'Leído de la frase';

  @override
  String get findSlot => 'Primer hueco libre';

  @override
  String msgSlotFound(String when) {
    return 'Libre: $when';
  }

  @override
  String get msgNoSlot => 'No hay hueco en las próximas dos semanas';

  @override
  String get trashTitle => 'Papelera';

  @override
  String get trashHint => 'Lo eliminado se guarda 90 días';

  @override
  String get trashEmpty => 'La papelera está vacía';

  @override
  String get trashRestore => 'Restaurar';

  @override
  String get trashClear => 'Vaciar la papelera';

  @override
  String msgTrashCleared(int count) {
    return 'Registros borrados: $count';
  }

  @override
  String msgRestored(String title) {
    return 'Restaurado: $title';
  }

  @override
  String get calendarDefaults => 'Por defecto';

  @override
  String get calendarDefaultReminder => 'Aviso en los eventos nuevos';

  @override
  String get calendarDefaultDuration => 'Duración de los eventos nuevos';

  @override
  String get actionSelect => 'Seleccionar varios';

  @override
  String selectedCount(int count) {
    return 'Seleccionados: $count';
  }

  @override
  String get bulkMove => 'Mover';

  @override
  String get bulkCalendar => 'Al calendario';

  @override
  String msgBulkMoved(int count) {
    return 'Eventos movidos: $count';
  }

  @override
  String msgBulkDeleted(int count) {
    return 'Eventos eliminados: $count';
  }

  @override
  String msgBulkCalendar(int count) {
    return 'Eventos en otro calendario: $count';
  }

  @override
  String get eventOpenEnd => 'Sin hora de fin';

  @override
  String timeFrom(String time) {
    return 'desde $time';
  }

  @override
  String get noteMarkupHint => '«- » crea un punto, «[ ] » una casilla';

  @override
  String get dayReviewTitle => 'Resumen del día';

  @override
  String get dayReviewBusy => 'Ocupado';

  @override
  String get dayReviewFree => 'Libre';

  @override
  String get dayReviewLongest => 'Lo más largo';

  @override
  String dayReviewClashes(int count) {
    return 'Solapamientos: $count';
  }

  @override
  String get dayReviewGaps => 'Dónde cabe';

  @override
  String get dayReviewNoBreaks => 'Un día sin una sola pausa';

  @override
  String get dayReviewEmpty => 'No hay nada previsto este día';

  @override
  String get filesTitle => 'Adjuntos';

  @override
  String get fileAttach => 'Adjuntar archivo';

  @override
  String get fileRemove => 'Quitar el adjunto';

  @override
  String get fileMissing => 'El archivo ya no está en el dispositivo';

  @override
  String get historyTitle => 'Historial de cambios';

  @override
  String get historyCreated => 'Evento creado';

  @override
  String get historyName => 'Título';

  @override
  String get historyTime => 'Hora';

  @override
  String get historyEmpty => 'Todavía no se ha cambiado nada';

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
  String get eventTravel => 'Tiempo de viaje';

  @override
  String get travelNone => 'No contarlo';

  @override
  String travelLeaveAt(String time) {
    return 'Salir a las $time';
  }

  @override
  String get storageFailed =>
      'El calendario no se abrió. Reinicie la aplicación';

  @override
  String get storageRetry => 'Reintentar';

  @override
  String get hiddenCalendarWarning =>
      'El evento está en un calendario oculto y no se ve en la cuadrícula';

  @override
  String get hiddenCalendarShow => 'Mostrar';

  @override
  String get previewMore => 'Más';

  @override
  String monthOnDay(int day) {
    return 'El día $day';
  }

  @override
  String get monthLastWorkday => 'Último día laborable';

  @override
  String get monthRuleTitle => 'Cómo se mide el mes';

  @override
  String everyDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count días',
      one: 'cada día',
    );
    return '$_temp0';
  }

  @override
  String everyWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count semanas',
      one: 'cada semana',
    );
    return '$_temp0';
  }

  @override
  String everyMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count meses',
      one: 'cada mes',
    );
    return '$_temp0';
  }

  @override
  String everyYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cada $count años',
      one: 'cada año',
    );
    return '$_temp0';
  }

  @override
  String get repeatHowOften => 'Con qué frecuencia';

  @override
  String get calendarSharing => 'Qué va al servidor';

  @override
  String get calendarShared => 'Calendario compartido';

  @override
  String get calendarSharedOn => 'Se envía al servidor';

  @override
  String get calendarSharedOff => 'Permanece en el dispositivo';

  @override
  String get syncSharedList => 'Enviado al servidor';

  @override
  String get syncSharedNone => 'Nada: todo permanece en el dispositivo';

  @override
  String get eventDescription => 'Descripción';

  @override
  String get eventDescriptionHint => 'Qué llevar, qué se acordó';

  @override
  String get eventHoldsTime => 'Ocupa tiempo';

  @override
  String get dayOpenFull => 'Abrir el día';

  @override
  String get dayEmpty => 'No hay nada planeado para este día';

  @override
  String get monthDensityText => 'Solo texto';

  @override
  String get labelsTitle => 'Etiqueta de eventos';

  @override
  String get labelsIcon => 'Iconos';

  @override
  String get labelsText => 'Texto';

  @override
  String get labelsBoth => 'Iconos y texto';

  @override
  String get cornerTitle => 'Redondeo de esquinas';

  @override
  String get cornerSquare => 'Rectas';

  @override
  String get cornerRound => 'Cápsula';

  @override
  String get cornerPreview => 'Así se ve un evento';

  @override
  String get tasksRowHint => 'Tareas con fecha límite';

  @override
  String get calendarsRowHint => 'Ramas, colores y visibilidad';

  @override
  String tapeFree(String span) {
    return '$span libre';
  }

  @override
  String get dayFreeTitle => 'El día está libre';

  @override
  String get dayFreeHint => 'Sin eventos. El botón de arriba crea el primero.';

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '$count evento',
    );
    return '$_temp0';
  }
}

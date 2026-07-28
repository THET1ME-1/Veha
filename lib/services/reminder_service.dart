import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_plan.dart';

/// Постановка будильников в систему.
///
/// Что показать и когда, решает `planReminders` — чистая функция под тестами.
/// Здесь только разговор с платформой, поэтому проверять тут почти нечего, а
/// ошибиться легко: у Android свои правила на точное время и на разрешения.
class ReminderService {
  ReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'veha_reminders',
    'Напоминания',
    channelDescription: 'Предупреждения о событиях календаря',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    if (_ready) return;

    // База часовых поясов нужна целиком: событие помнит свой пояс, и
    // напоминание обязано сработать по нему, а не по поясу телефона.
    tzdata.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// Разрешение спрашиваем при первой постановке, а не на старте: человек
  /// охотнее соглашается, когда уже понятно, о чём его предупредят.
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  /// План ставится целиком: старые будильники снимаются, новые встают.
  ///
  /// Точечная правка потребовала бы помнить, что уже поставлено, а система
  /// такого списка не отдаёт. Ключи считаются из события и срока, поэтому
  /// пересборка попадает в те же и дублей не плодит.
  /// Правки в базе идут пачками, а постановка асинхронная: без очереди два
  /// пересчёта наложились бы друг на друга, и `cancelAll` второго снёс бы
  /// будильники, поставленные первым.
  Future<void> _queue = Future.value();

  Future<void> apply(List<PlannedReminder> plan) {
    if (!Platform.isAndroid) return Future.value();
    return _queue = _queue.then((_) => _apply(plan));
  }

  Future<void> _apply(List<PlannedReminder> plan) async {
    await init();
    // Разрешение спрашивается один раз за сеанс и только когда есть что
    // ставить: пустой план — не повод для системного окна.
    if (!_asked && plan.isNotEmpty) {
      _asked = true;
      await requestPermission();
    }
    await _plugin.cancelAll();

    for (final r in plan) {
      await _schedule(r, exact: _exactAllowed);
    }
  }

  bool _asked = false;

  /// Точное время системе приходится разрешать отдельно. Календарю его дают
  /// (`USE_EXACT_ALARM` в манифесте), но на прошивках с урезанным поведением
  /// постановка падает. Один отказ переводит на приблизительное время до конца
  /// сеанса: напоминание, опоздавшее на минуту, всё равно лучше исключения.
  bool _exactAllowed = true;

  Future<void> _schedule(PlannedReminder r, {required bool exact}) async {
    try {
      await _plugin.zonedSchedule(
        r.alarmId,
        r.title,
        _subtitle(r),
        tz.TZDateTime.from(r.moment, tz.local),
        const NotificationDetails(android: _channel),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: r.eventId,
      );
    } on Exception {
      if (!exact) rethrow;
      _exactAllowed = false;
      await _schedule(r, exact: false);
    }
  }

  Future<void> cancelAll() async {
    if (!Platform.isAndroid) return;
    await init();
    await _plugin.cancelAll();
  }

  /// «Начало в 16:00» полезнее, чем «за 30 минут»: человек смотрит на
  /// уведомление, чтобы понять, сколько у него осталось.
  static String _subtitle(PlannedReminder r) {
    final h = r.eventStart.hour.toString().padLeft(2, '0');
    final m = r.eventStart.minute.toString().padLeft(2, '0');
    return r.minutesBefore == 0 ? 'Начинается' : 'Начало в $h:$m';
  }
}

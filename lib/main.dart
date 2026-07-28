import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/app_timezone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Русские названия месяцев нужны ещё до первого кадра — заголовок «Июль 2026»
  // строится на них.
  await initializeDateFormatting('ru');
  // Пояс устройства нужен до первого события: он ложится в каждую новую
  // запись и в расчёт напоминаний.
  try {
    AppTimezone.set((await FlutterTimezone.getLocalTimezone()).identifier);
  } on Exception {
    // Пояс не отдался — остаётся UTC. Приложение из-за этого не запускаться
    // не должно.
  }
  runApp(const ProviderScope(child: VehaApp()));
}

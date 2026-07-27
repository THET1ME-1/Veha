import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Русские названия месяцев нужны ещё до первого кадра — заголовок «Июль 2026»
  // строится на них.
  await initializeDateFormatting('ru');
  runApp(const ProviderScope(child: VehaApp()));
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Вложения событий на диске.
///
/// Тот же приём, что и со снимками: выбранный файл принадлежит чужому
/// приложению и доступ к нему живёт до перезапуска, поэтому он сразу
/// копируется в папку приложения, а в базу уходит относительный путь —
/// абсолютный протухает после переустановки.
class FileService {
  FileService._();

  static const _folder = 'files';

  /// Папка вложений. Создаётся при первом обращении.
  static Future<Directory> directory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folder));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<String> resolve(String relative) async {
    final base = await getApplicationDocumentsDirectory();
    return p.join(base.path, relative);
  }

  /// Выбрать файл и положить копию рядом с базой.
  ///
  /// Возвращает относительный путь, имя и размер — `null`, если человек
  /// передумал. Имя сохраняем отдельным полем: на диске файл лежит под
  /// ключом записи, иначе два «Билет.pdf» затрут друг друга.
  static Future<({String path, String name, int size})?> pick({
    required String id,
  }) async {
    final picked = await FilePicker.platform.pickFiles();
    final chosen = picked?.files.singleOrNull;
    final source = chosen?.path;
    if (chosen == null || source == null) return null;

    final dir = await directory();
    final target = File(p.join(dir.path, '$id${p.extension(source)}'));
    await File(source).copy(target.path);

    return (
      path: p.join(_folder, p.basename(target.path)),
      name: chosen.name,
      size: await target.length(),
    );
  }

  /// Убрать файл с диска. Мягкого удаления у вложения нет: строка уходит
  /// вместе с файлом, осиротевший файл держать незачем.
  static Future<void> erase(String relative) async {
    final file = File(await resolve(relative));
    if (file.existsSync()) await file.delete();
  }
}

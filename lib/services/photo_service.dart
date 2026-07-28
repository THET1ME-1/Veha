import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Снимки событий на диске.
///
/// Файл камеры и файл из галереи одинаково временные: первый лежит в кеше,
/// второй вообще принадлежит чужому приложению и доступ к нему живёт до
/// перезапуска. Поэтому оба сразу копируются в папку приложения, а в базу
/// уходит относительный путь.
class PhotoService {
  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _folder = 'photos';

  /// Папка со снимками. Создаётся при первом обращении.
  static Future<Directory> directory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folder));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Абсолютный путь по тому, что лежит в базе.
  static Future<String> resolve(String relative) async {
    final base = await getApplicationDocumentsDirectory();
    return p.join(base.path, relative);
  }

  /// Снять камерой. Возвращает относительный путь или `null`, если человек
  /// передумал.
  Future<String?> fromCamera({required String name}) =>
      _take(ImageSource.camera, name);

  /// Выбрать из галереи.
  Future<String?> fromGallery({required String name}) =>
      _take(ImageSource.gallery, name);

  Future<String?> _take(ImageSource source, String name) async {
    // Ужимаем на входе: снимок с двенадцатимегапиксельной камеры весит
    // четыре мегабайта, а в карточке он живёт полоской в сто пикселей.
    final shot = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (shot == null) return null;

    final dir = await directory();
    final ext = p.extension(shot.path).isEmpty ? '.jpg' : p.extension(shot.path);
    final file = File(p.join(dir.path, '$name$ext'));
    await File(shot.path).copy(file.path);
    return p.join(_folder, p.basename(file.path));
  }

  /// Картинка для чтения цвета: пипетке файл нужен только чтобы посмотреть
  /// на пиксель, копировать его в папку приложения незачем.
  Future<String?> pickForReading() async {
    final shot = await _picker.pickImage(source: ImageSource.gallery);
    return shot?.path;
  }

  /// Убрать файл с диска. Мягкого удаления у снимка нет: строка в базе уходит
  /// вместе с ним, и держать осиротевший файл незачем.
  static Future<void> erase(String relative) async {
    final file = File(await resolve(relative));
    if (file.existsSync()) await file.delete();
  }
}

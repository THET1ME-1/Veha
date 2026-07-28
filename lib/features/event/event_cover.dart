import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../services/photo_service.dart';

/// Обложка события: снимок фоном большой карточки.
///
/// Отдельной ленты снимков нет намеренно. Фотография в календаре нужна не
/// галереей, а приметой: увидел карточку — вспомнил, что за встреча. Поэтому
/// снимок один и лежит фоном там, где и так смотрят.

/// Корень, от которого отсчитываются пути. Спрашивается один раз на всё
/// приложение: системный вызов на каждую карточку — это мигающие заглушки.
final photoRootProvider = FutureProvider<String>(
  (ref) async => (await getApplicationDocumentsDirectory()).path,
);

/// Обложка события картинкой. `null` — обложки нет или файл пропал.
///
/// Отдаётся `ImageProvider`, а не `File`: экраны не должны знать про диск, а
/// снимки экранов подставляют сюда картинку из памяти — файловая загрузка в
/// `flutter_test` не доходит до декодера.
final coverProvider = Provider.family<ImageProvider?, String>((ref, eventId) {
  final photos = ref.watch(photosProvider(eventId)).valueOrNull ?? const [];
  final root = ref.watch(photoRootProvider).valueOrNull;
  if (photos.isEmpty || root == null) return null;

  final file = File(p.join(root, photos.first.path));
  return file.existsSync() ? FileImage(file) : null;
});

/// Круглая кнопка в углу карточки: снять, выбрать, убрать.
class CoverButton extends ConsumerWidget {
  const CoverButton({
    super.key,
    required this.eventId,
    required this.ink,
    this.size = 40,
  });

  final String eventId;
  final EventInk ink;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final has = ref.watch(coverProvider(eventId)) != null;

    return InkWell(
      onTap: () => _choose(context, ref, has),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: ink.foreground.withValues(alpha: 0.15),
          shape: const CircleBorder(),
        ),
        child: Icon(
          VehaIcons.byName(has ? 'photo' : 'photo_camera'),
          size: size * 0.5,
          color: ink.foreground,
        ),
      ),
    );
  }

  Future<void> _choose(BuildContext context, WidgetRef ref, bool has) async {
    final l = L.of(context);
    final choice = await showModalBottomSheet<_Choice>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(VehaIcons.byName('photo_camera')),
              title: Text(l.photoCamera),
              onTap: () => Navigator.pop(sheet, _Choice.camera),
            ),
            ListTile(
              leading: Icon(VehaIcons.byName('photo_library')),
              title: Text(l.photoGallery),
              onTap: () => Navigator.pop(sheet, _Choice.gallery),
            ),
            if (has)
              ListTile(
                leading: Icon(VehaIcons.byName('trash'),
                    color: Theme.of(sheet).colorScheme.error),
                title: Text(
                  l.photoRemove,
                  style: TextStyle(color: Theme.of(sheet).colorScheme.error),
                ),
                onTap: () => Navigator.pop(sheet, _Choice.remove),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    final repo = ref.read(repositoryProvider);
    if (choice == _Choice.remove) {
      await _clear(ref);
      return;
    }

    final service = ref.read(photoServiceProvider);
    final id = repo.newId();
    try {
      final path = choice == _Choice.camera
          ? await service.fromCamera(name: id)
          : await service.fromGallery(name: id);
      if (path == null) return;

      // Обложка одна: новая заменяет прежнюю, а её файл убирается с диска.
      await _clear(ref);
      await repo.addPhoto(VPhoto(id: id, eventId: eventId, path: path));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${L.of(context).msgSaveFailed}: $e')),
      );
    }
  }

  Future<void> _clear(WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final photos = ref.read(photosProvider(eventId)).valueOrNull ?? const [];
    for (final photo in photos) {
      final path = await repo.deletePhoto(photo.id);
      if (path != null) await PhotoService.erase(path);
    }
  }
}

enum _Choice { camera, gallery, remove }

/// Заливка поверх снимка, чтобы текст читался.
///
/// Ровная, а не градиентом: градиентов в приложении нет. Прозрачность
/// подобрана так, что снимок узнаётся, а буквы не спорят с ним.
const double coverScrim = 0.72;

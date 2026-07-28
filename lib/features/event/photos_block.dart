import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../services/photo_service.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// Корень, от которого отсчитываются пути снимков.
///
/// Спрашивается один раз на всё приложение: системный вызов на каждую
/// миниатюру превратил бы ленту в мигающий список заглушек.
final photoRootProvider = FutureProvider<String>(
  (ref) async => (await getApplicationDocumentsDirectory()).path,
);

/// Лента снимков события: миниатюры и кнопка «добавить».
///
/// Снимки живут на устройстве и на сервер не уезжают — там хранятся записи,
/// а не файлы. Поэтому и правятся они сразу, без «Сохранить»: как заметки.
class PhotosBlock extends ConsumerWidget {
  const PhotosBlock({super.key, required this.eventId, required this.color});

  final String eventId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final photos = ref.watch(photosProvider(eventId)).valueOrNull ?? const [];
    final root = ref.watch(photoRootProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VBlockCap(l.photosTitle),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => i == photos.length
                ? _AddButton(onTap: () => _add(context, ref, photos.length))
                : _Thumb(
                    photo: photos[i],
                    root: root,
                    color: color,
                    onTap: () => _open(context, ref, photos[i], root),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, int count) async {
    final source = await showModalBottomSheet<_Source>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(VehaIcons.byName('photo_camera')),
              title: Text(L.of(sheet).photoCamera),
              onTap: () => Navigator.pop(sheet, _Source.camera),
            ),
            ListTile(
              leading: Icon(VehaIcons.byName('photo_library')),
              title: Text(L.of(sheet).photoGallery),
              onTap: () => Navigator.pop(sheet, _Source.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final repo = ref.read(repositoryProvider);
    final service = ref.read(photoServiceProvider);
    final id = repo.newId();

    // Ошибку показываем строкой: молчаливый отказ камеры человек принимает
    // за поломку приложения и жмёт кнопку ещё раз.
    try {
      final path = source == _Source.camera
          ? await service.fromCamera(name: id)
          : await service.fromGallery(name: id);
      if (path == null) return;
      await repo.addPhoto(
        VPhoto(id: id, eventId: eventId, path: path, sortOrder: count),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${L.of(context).msgSaveFailed}: $e')));
    }
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    VPhoto photo,
    String? root,
  ) async {
    if (root == null) return;
    final removed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _PhotoScreen(file: File(p.join(root, photo.path))),
      ),
    );
    if (removed != true) return;

    final path = await ref.read(repositoryProvider).deletePhoto(photo.id);
    if (path != null) await PhotoService.erase(path);
  }
}

enum _Source { camera, gallery }

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.photo,
    required this.root,
    required this.color,
    required this.onTap,
  });

  final VPhoto photo;
  final String? root;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = EventColors.of(color, Theme.of(context).brightness);
    final file = root == null ? null : File(p.join(root!, photo.path));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 96,
          height: 96,
          color: ink.background,
          child: file == null || !file.existsSync()
              // Файл мог уехать вместе с чисткой хранилища: показываем знак,
              // а не пустой прямоугольник, чтобы это читалось как пропажа.
              ? Icon(VehaIcons.byName('image'), color: ink.foreground, size: 26)
              : Image.file(file, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(VehaIcons.byName('add'), size: 22, color: scheme.primary),
            const SizedBox(height: 4),
            Text(
              L.of(context).photoAdd,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 10.5,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Снимок во весь экран. Убрать можно отсюда: в ленте кнопка удаления на
/// миниатюре размером с палец промахивается по соседней.
class _PhotoScreen extends StatelessWidget {
  const _PhotoScreen({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        toolbarHeight: 56,
        leading: vBack(context),
        leadingWidth: 60,
        backgroundColor: scheme.surfaceContainerLowest,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(child: Image.file(file)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 8, VehaInsets.screen, 24),
            child: TextButton.icon(
              onPressed: () => _confirm(context),
              icon: Icon(VehaIcons.byName('trash'), size: 18),
              label: Text(L.of(context).photoRemove),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final l = L.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l.photoRemoveAsk),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (yes == true && context.mounted) Navigator.pop(context, true);
  }
}

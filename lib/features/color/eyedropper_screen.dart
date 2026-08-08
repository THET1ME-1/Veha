import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../l10n/app_localizations.dart';
import '../common/morph_widgets.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart' show vBack;

/// Пипетка по картинке.
///
/// Взять цвет прямо с обоев Android не даёт: чужой экран приложению не виден,
/// а скриншот системы требует записи экрана. Поэтому человек открывает снимок
/// или фотографию и тыкает в нужное место — тот же результат, без разрешения
/// на запись всего, что происходит на телефоне.
class EyedropperScreen extends StatefulWidget {
  const EyedropperScreen({super.key, required this.file});

  final File file;

  @override
  State<EyedropperScreen> createState() => _EyedropperScreenState();
}

class _EyedropperScreenState extends State<EyedropperScreen> {
  ui.Image? _image;
  ByteData? _pixels;
  Color? _picked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await widget.file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    // Пиксели читаем один раз: тянуть их на каждое касание — заметная пауза
    // под пальцем на снимке в двенадцать мегапикселей.
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (!mounted) return;
    setState(() {
      _image = frame.image;
      _pixels = data;
    });
  }

  /// Цвет пикселя под пальцем. Координата приходит в логических пикселях
  /// виджета, а картинка нарисована `BoxFit.contain` — переводим обратно.
  Color? _colorAt(Offset local, Size box) {
    final image = _image;
    final pixels = _pixels;
    if (image == null || pixels == null) return null;

    final scale = (box.width / image.width) < (box.height / image.height)
        ? box.width / image.width
        : box.height / image.height;
    final drawn = Size(image.width * scale, image.height * scale);
    final offset = Offset(
      (box.width - drawn.width) / 2,
      (box.height - drawn.height) / 2,
    );

    final x = ((local.dx - offset.dx) / scale).floor();
    final y = ((local.dy - offset.dy) / scale).floor();
    if (x < 0 || y < 0 || x >= image.width || y >= image.height) return null;

    final index = (y * image.width + x) * 4;
    return Color.fromARGB(
      255,
      pixels.getUint8(index),
      pixels.getUint8(index + 1),
      pixels.getUint8(index + 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final picked = _picked;

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
      body: Column(
        children: [
          Expanded(
            child: _image == null
                ? const Center(child: MorphLoader())
                : LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      onTapDown: (details) {
                        final color = _colorAt(
                          details.localPosition,
                          constraints.biggest,
                        );
                        if (color != null) setState(() => _picked = color);
                      },
                      child: RawImage(
                        image: _image,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 12, VehaInsets.screen, 22),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: ShapeDecoration(
                    color: picked ?? scheme.surfaceContainerHigh,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    picked == null
                        ? l.colorTapImage
                        : '#${(picked.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                    style: TextStyle(
                      fontFamily: picked == null
                          ? AppFonts.body
                          : AppFonts.display,
                      fontSize: picked == null ? 13.5 : 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: picked == null ? 0 : -0.5,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed:
                      picked == null ? null : () => Navigator.pop(context, picked),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 13),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l.actionDone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart';

/// Список одним блоком: строки внутри, разделители — тонкая заливка.
///
/// Отдельная карточка вокруг каждой строки даёт рваный ритм и съедает
/// вертикаль, поэтому весь список живёт в одном контейнере.
class VBlock extends StatelessWidget {
  const VBlock({super.key, required this.children, this.color});

  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: color ?? scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Column(children: children),
    );
  }
}

/// Разделитель внутри блока. Именно заливка, а не рамка строки: обводок
/// в приложении нет нигде.
class VSep extends StatelessWidget {
  const VSep({super.key, this.inset = 66});

  final double inset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: inset),
      child: Container(
        height: 1,
        color: scheme.outlineVariant.withValues(alpha: 0.55),
      ),
    );
  }
}

/// Подпись группы над блоком.
class VBlockCap extends StatelessWidget {
  const VBlockCap(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Строка списка: круг с иконкой, подпись и значение, хвост справа.
class VRow extends StatelessWidget {
  const VRow({
    super.key,
    required this.icon,
    this.label,
    this.value,
    this.trailing,
    this.iconColor,
    this.iconBackground,
    this.onTap,
    this.labelFirst = true,
  });

  /// Имя иконки из белого списка.
  final String icon;

  /// Мелкая подпись над значением. Может отсутствовать — тогда значение
  /// становится основной строкой.
  final String? label;
  final String? value;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBackground;
  final VoidCallback? onTap;

  /// Где стоит мелкая подпись. В карточке события сверху («Кабинет» → «312»),
  /// в списке групп снизу («Учёба» → перечень её полей).
  final bool labelFirst;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      color: scheme.onSurfaceVariant,
    );
    final valueStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: iconBackground ?? scheme.surfaceContainerHigh,
                shape: const CircleBorder(),
              ),
              child: Icon(VehaIcons.byName(icon),
                  size: 18, color: iconColor ?? scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (labelFirst && label != null)
                    Text(label!, style: labelStyle),
                  if (value != null)
                    Padding(
                      padding: EdgeInsets.only(
                          top: labelFirst && label != null ? 1 : 0),
                      child: Text(value!, style: valueStyle),
                    ),
                  if (!labelFirst && label != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(label!, style: labelStyle),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Плашка «в карточке» и подобные метки.
class VTag extends StatelessWidget {
  const VTag(this.text, {super.key, this.accent = true});

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        color: accent
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Тумблер без обводки: и трек, и ползунок — заливки.
class VSwitch extends StatelessWidget {
  const VSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Container(
        width: 46,
        height: 28,
        decoration: ShapeDecoration(
          color: value ? scheme.primary : scheme.surfaceContainerHighest,
          shape: const StadiumBorder(),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: value ? 4 : 5),
            child: Container(
              width: value ? 20 : 14,
              height: value ? 20 : 14,
              decoration: ShapeDecoration(
                color: value ? scheme.onPrimary : scheme.outline,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка выбора из списка вариантов: выбранная получает заливку и галочку.
class VOption extends StatelessWidget {
  const VOption({
    super.key,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: selected
                              ? fg.withValues(alpha: 0.8)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: scheme.primary,
                  shape: const CircleBorder(),
                ),
                child: Icon(VehaIcons.byName('exam'),
                    size: 14, color: scheme.onPrimary),
              ),
          ],
        ),
      ),
    );
  }
}

/// Шапка-герой над списком: крупное название события на цветной заливке.
class VHero extends StatelessWidget {
  const VHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    this.progress,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;

  /// Доля пройденного для многодневных событий.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: ShapeDecoration(
        color: background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: foreground.withValues(alpha: 0.14),
              shape: const CircleBorder(),
            ),
            child: Icon(VehaIcons.byName(icon), size: 26, color: foreground),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 24,
              height: 1.15,
              letterSpacing: -0.6,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: foreground.withValues(alpha: 0.85),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            ClipPath(
              clipper: const ShapeBorderClipper(shape: StadiumBorder()),
              child: Container(
                height: 6,
                color: foreground.withValues(alpha: 0.18),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress!.clamp(0.0, 1.0),
                  child: ColoredBox(
                    color: foreground.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Круглая кнопка с заливкой. Голая иконка кнопкой не читается: в приложении
/// нет ни обводок, ни теней, и нажимаемое от текста отличает только заливка.
class VRoundButton extends StatelessWidget {
  const VRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
  });

  final String icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: const CircleBorder(),
        ),
        child: Icon(VehaIcons.byName(icon), size: size * 0.48,
            color: scheme.onSurface),
      ),
    );
  }
}

/// Стрелка «назад» для шапки экрана. Своя, а не стоковая: стоковая берёт глиф
/// из чужого шрифта, а он в сборке урезается до пары символов и на месте
/// стрелки остаётся квадрат.
Widget vBack(BuildContext context) => Padding(
      padding: const EdgeInsets.only(left: 8),
      // Подпись для озвучки обязательна: у своей кнопки её нет, а стоковая
      // `BackButton` подставляет свою сама.
      child: Semantics(
        label: MaterialLocalizations.of(context).backButtonTooltip,
        button: true,
        child: VRoundButton(
          icon: 'back',
          size: 40,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
    );

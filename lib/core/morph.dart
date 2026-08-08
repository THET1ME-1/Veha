import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Фирменные фигуры Veha и переходы между ними.
///
/// Material 3 Expressive построен на морфинге фигур, а не на подмигивании
/// цветом. Своя реализация нужна потому, что во Flutter 3.41 готовых фигур
/// Expressive ещё нет, а ждать их — значит не иметь узнаваемости вовсе.
///
/// Фигура описывается радиусом как функцией угла: `r(θ) = 1 + amplitude *
/// cos(lobes * θ)`. Круг — нулевая амплитуда, четырёхлистник — четыре доли,
/// лепесток — пять. Такое описание даёт главное: любые две фигуры
/// превращаются друг в друга покомпонентно, без сопоставления точек контура
/// и без разрывов на полпути.
@immutable
class MorphShape {
  const MorphShape({
    required this.lobes,
    required this.amplitude,
    this.squareness = 0,
    this.rotation = 0,
  });

  /// Круг: то, с чего начинается и чем заканчивается любой переход.
  static const circle = MorphShape(lobes: 0, amplitude: 0);

  /// Четырёхлистник — знак Veha в отметках и загрузке.
  static const clover = MorphShape(lobes: 4, amplitude: 0.16);

  /// Лепесток: пять долей, мягче четырёхлистника.
  static const petal = MorphShape(lobes: 5, amplitude: 0.12, rotation: 0.3);

  /// Скруглённый квадрат — форма кнопки, к которой FAB приходит, раскрываясь
  /// в форму события.
  static const squircle = MorphShape(lobes: 4, amplitude: 0.0, squareness: 1);

  /// Сколько долей у контура.
  final int lobes;

  /// Насколько доли выпирают. Ноль — ровная окружность.
  final double amplitude;

  /// Насколько фигура тянется к квадрату: 0 — круг, 1 — суперэллипс.
  final double squareness;

  /// Поворот контура в оборотах, не в радианах: доли считаются по кругу, и
  /// доля оборота читается понятнее, чем доля пи.
  final double rotation;

  /// Промежуточная фигура. Доли — целое число, поэтому берётся та, к которой
  /// переход ближе: контур с тремя с половиной долями не бывает.
  static MorphShape lerp(MorphShape a, MorphShape b, double t) => MorphShape(
        lobes: t < 0.5 ? a.lobes : b.lobes,
        // Амплитуда гасится к середине перехода: доли исчезают в круг и
        // отрастают уже новым числом, поэтому смены `lobes` глазом не видно.
        amplitude: t < 0.5
            ? lerpDouble(a.amplitude, 0, t * 2)!
            : lerpDouble(0, b.amplitude, (t - 0.5) * 2)!,
        squareness: lerpDouble(a.squareness, b.squareness, t)!,
        rotation: lerpDouble(a.rotation, b.rotation, t)!,
      );

  /// Контур фигуры, вписанный в квадрат [size].
  Path path(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy);
    final turn = rotation * 2 * math.pi;

    // Шаг в один градус: на кнопке в 56 логических пикселей грань между
    // соседними точками короче полупикселя, и контур читается гладким.
    const steps = 360;
    final path = Path();

    for (var i = 0; i <= steps; i++) {
      final angle = turn + i * 2 * math.pi / steps;
      final wave = lobes == 0 ? 1.0 : 1 + amplitude * math.cos(lobes * angle);

      // Суперэллипс подмешивается множителем: чистая формула квадрата дала бы
      // острые углы, а нам нужен именно скруглённый квадрат.
      final square = squareness == 0
          ? 1.0
          : lerpDouble(
              1,
              1 /
                  math.pow(
                    math.pow(math.cos(angle).abs(), 4) +
                        math.pow(math.sin(angle).abs(), 4),
                    0.25,
                  ),
              squareness,
            )!;

      final r = radius * wave * square;
      final point = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path..close();
  }

  @override
  bool operator ==(Object other) =>
      other is MorphShape &&
      other.lobes == lobes &&
      other.amplitude == amplitude &&
      other.squareness == squareness &&
      other.rotation == rotation;

  @override
  int get hashCode => Object.hash(lobes, amplitude, squareness, rotation);
}

/// Фигура как форма контейнера: годится для `ShapeDecoration`, обрезки и
/// разводов нажатия.
class MorphBorder extends OutlinedBorder {
  const MorphBorder(this.shape);

  final MorphShape shape;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      shape.path(rect.size).shift(rect.topLeft);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  MorphBorder copyWith({BorderSide? side}) => this;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder lerpFrom(ShapeBorder? a, double t) => a is MorphBorder
      ? MorphBorder(MorphShape.lerp(a.shape, shape, t))
      : this;

  @override
  ShapeBorder lerpTo(ShapeBorder? b, double t) => b is MorphBorder
      ? MorphBorder(MorphShape.lerp(shape, b.shape, t))
      : this;
}

/// Пружины движения.
///
/// ТЗ требует пружинной физики, а не кривых Безье: у пружины есть масса и
/// затухание, и остановка получается живой, а не расчётной. Значения общие на
/// приложение — разнобой в упругости читается как небрежность.
abstract final class VehaSprings {
  /// Обычное движение: перенос, раскрытие, смена вида.
  static const standard = SpringDescription(mass: 1, stiffness: 380, damping: 32);

  /// Отклик на касание: чуть жёстче, чтобы не отставать от пальца.
  static const snappy = SpringDescription(mass: 1, stiffness: 520, damping: 34);

  /// Перелёт для отметок: слегка проскакивает и возвращается.
  static const bouncy = SpringDescription(mass: 1, stiffness: 320, damping: 18);
}

/// Уважает системную настройку «уменьшить движение».
///
/// Человек, отключивший анимации, просит не двигать интерфейс — фигуры при
/// этом меняются мгновенно, а не исчезают вовсе.
bool motionAllowed(BuildContext context) =>
    !MediaQuery.disableAnimationsOf(context);

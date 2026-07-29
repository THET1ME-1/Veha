import 'dart:math' as math;

/// Автоскролл сетки, когда блок дотащили до её края.
///
/// Без него перенести событие с утра на вечер нельзя вовсе: палец упирается в
/// границу экрана, а сетка стоит. Арифметика вынесена из виджета — на живом
/// жесте ошибку в знаке не разглядеть, а тестом видно сразу.

/// Ширина полосы у края, внутри которой сетка начинает разгоняться.
const double kEdgeZone = 56;

/// Потолок скорости, пикселей в секунду. Быстрее — и день пролетает мимо
/// прежде, чем человек успевает отпустить палец.
const double kEdgeSpeed = 420;

/// Скорость прокрутки для пальца в точке [pointer] при видимой сетке от [top]
/// до [bottom]. Отрицательная — вверх, ноль — сетка стоит.
double edgeScrollSpeed({
  required double pointer,
  required double top,
  required double bottom,
  double zone = kEdgeZone,
  double maxSpeed = kEdgeSpeed,
}) {
  final height = bottom - top;
  if (height <= 0) return 0;

  // На узком окне зона ужимается: две полосы по 56 пикселей в окне высотой
  // 120 не оставили бы места, где блок стоит на месте.
  final band = math.min(zone, height / 3);
  if (band <= 0) return 0;

  final aboveTop = top + band - pointer;
  if (aboveTop > 0) return -maxSpeed * math.min(aboveTop, band) / band;

  final belowBottom = pointer - (bottom - band);
  if (belowBottom > 0) return maxSpeed * math.min(belowBottom, band) / band;

  return 0;
}

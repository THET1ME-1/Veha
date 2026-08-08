import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/morph.dart';
import 'package:veha/features/common/morph_widgets.dart';

import 'golden_harness.dart';

/// Фирменные фигуры и переходы между ними.
///
/// Морфинг назван в ТЗ главной анимацией, и живёт он ровно в трёх местах:
/// отметка задачи, кнопка «завести», индикатор загрузки. Здесь проверяется
/// сама фигура — что переход непрерывен и что выключенные анимации его
/// останавливают.
void main() {
  setUpAll(loadAppFonts);

  test('Переход между фигурами не рвётся посередине', () {
    // На середине доли гасятся в круг: смены их числа глазом не видно.
    final middle = MorphShape.lerp(MorphShape.circle, MorphShape.clover, 0.5);
    expect(middle.amplitude, 0);

    // К концу перехода фигура становится целевой.
    final end = MorphShape.lerp(MorphShape.circle, MorphShape.clover, 1);
    expect(end.lobes, MorphShape.clover.lobes);
    expect(end.amplitude, closeTo(MorphShape.clover.amplitude, 0.001));
  });

  test('Контур замкнут и вписан в отведённый квадрат', () {
    final path = MorphShape.clover.path(const Size(48, 48));
    final bounds = path.getBounds();

    expect(bounds.width,
        closeTo(48 * (1 + MorphShape.clover.amplitude), 0.01));
    expect(path.contains(const Offset(24, 24)), isTrue,
        reason: 'центр фигуры должен быть внутри контура');
  });

  testWidgets('Снимок фигур в фазах перехода', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: _ShapeSheet())),
    );
    await shoot(tester, 'morph_shapes');
  });

  testWidgets('Выключенные анимации не двигают отметку', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MorphMark(
            done: false,
            color: Color(0xFF41CCB5),
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MorphMark(
            done: true,
            color: Color(0xFF41CCB5),
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    // Ни одного кадра анимации: состояние сменилось сразу.
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}

/// Раскладка фигур: три ряда переходов по пять фаз.
class _ShapeSheet extends StatelessWidget {
  const _ShapeSheet();

  @override
  Widget build(BuildContext context) {
    const pairs = [
      (MorphShape.circle, MorphShape.clover),
      (MorphShape.clover, MorphShape.petal),
      (MorphShape.petal, MorphShape.squircle),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (from, to) in pairs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final t in const [0.0, 0.25, 0.5, 0.75, 1.0])
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: MorphBorder(MorphShape.lerp(from, to, t)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

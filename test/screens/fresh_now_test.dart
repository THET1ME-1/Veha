import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/providers.dart';
import 'package:veha/features/shell/fresh_now.dart';

/// Сторож даты.
///
/// Календарь держит «сегодня» одним значением на всё приложение, а приложение
/// на телефоне живёт неделями: его сворачивают, а не закрывают. Пока значение
/// не пересчитывается, вернувшийся через сутки человек видит вчерашний день —
/// и заведённое событие уезжает во вчера вместе с ним.
void main() {
  testWidgets('Возврат из фона обновляет «сейчас»', (tester) async {
    final seen = <DateTime>[];

    await tester.pumpWidget(
      ProviderScope(
        child: FreshNow(
          child: Consumer(
            builder: (_, ref, __) {
              seen.add(ref.watch(nowProvider));
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    final first = seen.last;
    // Часы в тестах поддельные, и без настоящей паузы второе «сейчас» попадает
    // в ту же миллисекунду, что и первое: проверять было бы нечего.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(seen.last.isAfter(first), isTrue,
        reason: 'после возврата из фона «сейчас» осталось прежним');
  });
}

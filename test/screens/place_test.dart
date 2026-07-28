import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/providers.dart';
import 'package:veha/features/shell/home_shell.dart';
import 'package:veha/services/place_service.dart';

import 'golden_harness.dart';

/// Место ставится по координатам или поиском. Набирать адрес руками — худший
/// способ: человек стоит у входа и не помнит номера дома.
class _FakePlaces implements PlaceSource {
  _FakePlaces({this.fix = const (lat: 47.02, lon: 28.83)});

  final ({double lat, double lon})? fix;
  int searches = 0;

  @override
  Future<({double lat, double lon})?> current() async => fix;

  @override
  Future<String?> nameOf(double lat, double lon, String languageCode) async =>
      'Штефан чел Маре 12';

  @override
  Future<List<String>> search(String query, String languageCode) async {
    searches++;
    return ['Языковой центр, $query', 'Кофейня на $query'];
  }
}

void main() {
  setUpAll(loadAppFonts);

  Future<void> openPlace(WidgetTester tester, PlaceSource places) async {
    await pumpScreen(
      tester,
      const HomeShell(),
      overrides: [placeSourceProvider.overrideWithValue(places)],
    );

    await openEventEditor(tester, find.text('Завтрак').first);
    await tester.scrollUntilVisible(find.text('Место'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Место'));
    await tester.pumpAndSettle();
  }

  testWidgets('«Я здесь» подставляет название по координатам', (tester) async {
    await openPlace(tester, _FakePlaces());

    await tester.tap(find.text('Я здесь'));
    await tester.pumpAndSettle();

    expect(find.text('Штефан чел Маре 12'), findsOneWidget);
  });

  testWidgets('Без разрешения место не ставится, но экран жив', (tester) async {
    await openPlace(tester, _FakePlaces(fix: null));

    await tester.tap(find.text('Я здесь'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Не вышло определить место'), findsOneWidget);
    expect(find.text('Я здесь'), findsOneWidget, reason: 'Лист не закрылся');
  });

  testWidgets('Поиск отдаёт готовые подписи', (tester) async {
    final places = _FakePlaces();
    await openPlace(tester, places);

    await tester.enterText(find.byType(TextField).last, 'Штефана');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(places.searches, 1, reason: 'Ищем не на каждую букву');
    await tester.tap(find.text('Кофейня на Штефана'));
    await tester.pumpAndSettle();

    expect(find.text('Кофейня на Штефана'), findsOneWidget);
  });
}

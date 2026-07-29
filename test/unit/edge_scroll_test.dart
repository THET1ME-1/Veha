import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/edge_scroll.dart';

/// Скорость автоскролла: блок дотащили до края сетки, дальше её надо крутить
/// самой. Чистая арифметика вынесена отдельно — на живом жесте такое не
/// проверить, а ошибка в знаке уводит сетку в противоположную сторону.
void main() {
  test('В середине окна сетка стоит', () {
    expect(edgeScrollSpeed(pointer: 300, top: 100, bottom: 600), 0);
  });

  test('У верхнего края сетка едет вверх', () {
    expect(edgeScrollSpeed(pointer: 110, top: 100, bottom: 600), lessThan(0));
  });

  test('У нижнего края сетка едет вниз', () {
    expect(edgeScrollSpeed(pointer: 590, top: 100, bottom: 600), greaterThan(0));
  });

  test('Чем ближе к краю, тем быстрее', () {
    final near = edgeScrollSpeed(pointer: 595, top: 100, bottom: 600);
    final far = edgeScrollSpeed(pointer: 570, top: 100, bottom: 600);
    expect(near, greaterThan(far));
  });

  test('За краем скорость не растёт бесконечно', () {
    final atEdge = edgeScrollSpeed(pointer: 600, top: 100, bottom: 600);
    final beyond = edgeScrollSpeed(pointer: 900, top: 100, bottom: 600);
    expect(beyond, atEdge);
  });

  test('Узкое окно не превращается в сплошную зону разгона', () {
    // Окно в полторы зоны: середина обязана остаться местом, где сетка стоит,
    // иначе на маленьком экране блок нельзя удержать на месте.
    expect(edgeScrollSpeed(pointer: 140, top: 100, bottom: 180), 0);
  });
}

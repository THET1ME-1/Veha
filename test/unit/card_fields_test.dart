import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/card_fields.dart';

/// Поля в карточке события.
///
/// Отметка «показывать в карточке» — половина смысла своих полей: человек
/// заводит кабинет и преподавателя, чтобы видеть их в сетке, не открывая
/// событие. Виды брали первое значение подряд, и отметка ничего не решала.
void main() {
  VFieldDef def(String id, {bool shown = true, int order = 0}) => VFieldDef(
        id: id,
        name: id,
        type: VFieldType.text,
        iconName: 'text',
        showInCard: shown,
        sortOrder: order,
      );

  VEvent eventWith(List<String> ids) => VEvent(
        id: 'e1',
        calendarId: 'c1',
        title: 'Урок',
        start: DateTime(2026, 7, 27, 10),
        end: DateTime(2026, 7, 27, 11),
        fields: [for (final id in ids) VFieldValue(fieldId: id, value: id)],
      );

  test('Неотмеченное поле в карточку не идёт', () {
    final defs = {
      'заметка': def('заметка', shown: false),
      'кабинет': def('кабинет'),
    };

    expect(
      cardFields(eventWith(['заметка', 'кабинет']), defs).map((f) => f.fieldId),
      ['кабинет'],
    );
  });

  test('Порядок задаёт человек, а не очерёдность в запросе', () {
    final defs = {
      'преподаватель': def('преподаватель', order: 2),
      'кабинет': def('кабинет', order: 1),
    };

    expect(
      cardFields(eventWith(['преподаватель', 'кабинет']), defs)
          .map((f) => f.fieldId),
      ['кабинет', 'преподаватель'],
    );
  });

  test('Больше трёх строк карточка не берёт', () {
    final defs = {
      for (var i = 0; i < 5; i++) 'f$i': def('f$i', order: i),
    };

    expect(cardFields(eventWith(defs.keys.toList()), defs), hasLength(3));
  });
}

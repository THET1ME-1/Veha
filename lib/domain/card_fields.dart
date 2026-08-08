import '../data/models.dart';

/// Какие свои поля показывает карточка события.
///
/// ТЗ отводит на карточку максимум три поля, отмеченных «в карточке», в
/// порядке, который человек задал сам. Виды раньше брали первое попавшееся
/// значение из списка события: у события с заметкой для себя и кабинетом в
/// карточку попадала заметка, а кабинет — тот, ради которого отметку и
/// ставили, — не попадал.
///
/// Ограничение в три строки не настраивается: карточка на четыре строки
/// перестаёт читаться, а таймлайн ради этого теряет плотность.
const int cardFieldLimit = 3;

List<VFieldValue> cardFields(
  VEvent event,
  Map<String, VFieldDef> defs, {
  int limit = cardFieldLimit,
}) {
  final shown = [
    for (final v in event.fields)
      if (defs[v.fieldId]?.showInCard ?? false) v,
  ]..sort((a, b) {
      final left = defs[a.fieldId]?.sortOrder ?? 0;
      final right = defs[b.fieldId]?.sortOrder ?? 0;
      // Ничью разрешаем именем поля: порядок в карточке не должен зависеть от
      // того, в каком порядке значения приехали из запроса.
      if (left != right) return left.compareTo(right);
      return (defs[a.fieldId]?.name ?? '')
          .compareTo(defs[b.fieldId]?.name ?? '');
    });

  return shown.take(limit).toList();
}

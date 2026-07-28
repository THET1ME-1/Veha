import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// Подпись типа поля. Живёт в слое интерфейса, а не в модели: модель про
/// словарь и язык не знает и знать не должна.
String fieldTypeLabel(L l, VFieldType type) => switch (type) {
      VFieldType.text => l.typeText,
      VFieldType.number => l.typeNumber,
      VFieldType.date => l.typeDate,
      VFieldType.time => l.typeTime,
      VFieldType.duration => l.typeDuration,
      VFieldType.select => l.typeSelect,
      VFieldType.checkbox => l.typeCheckbox,
      VFieldType.url => l.typeUrl,
      VFieldType.phone => l.typePhone,
      VFieldType.person => l.typePerson,
      VFieldType.money => l.typeMoney,
    };

import 'dart:ui' show Locale;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Место события: где я сейчас и что называется так, как я ищу.
///
/// Источник подменяется в тестах: и координаты, и геокодер живут в плагинах,
/// которых в `flutter test` нет, а логика «спросить разрешение → взять фикс →
/// получить название» проверяться должна.
abstract class PlaceSource {
  /// Координаты устройства. `null` — разрешения нет или фикс не пришёл.
  Future<({double lat, double lon})?> current();

  /// Название по координатам: «Штефан чел Маре 12» вместо «47.02, 28.83».
  Future<String?> nameOf(double lat, double lon, String languageCode);

  /// Поиск места по названию. Отдаёт подписи, а не координаты: событию нужна
  /// строка, по которой человек узнает адрес.
  Future<List<String>> search(String query, String languageCode);
}

/// Настоящий источник: `geolocator` для координат, `geocoding` для названий.
class DevicePlaceSource implements PlaceSource {
  const DevicePlaceSource();

  @override
  Future<({double lat, double lon})?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Средняя точность и жёсткий срок: событию хватит улицы, а держать
      // человека у крутилки ради метров нельзя.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return (lat: position.latitude, lon: position.longitude);
    } on Exception {
      // Плагина нет (десктоп), сервис выключен, срок вышел — место просто
      // не подставится, а событие заведётся.
      return null;
    }
  }

  @override
  Future<String?> nameOf(double lat, double lon, String languageCode) async {
    try {
      final marks = await Geocoding()
          .placemarkFromCoordinates(lat, lon, locale: Locale(languageCode));
      if (marks.isEmpty) return null;
      return _label(marks.first);
    } on Exception {
      return null;
    }
  }

  @override
  Future<List<String>> search(String query, String languageCode) async {
    if (query.trim().length < 3) return const [];
    try {
      final found = await Geocoding()
          .locationFromAddress(query, locale: Locale(languageCode));
      final out = <String>[];
      for (final location in found.take(5)) {
        final name = await nameOf(
          location.latitude,
          location.longitude,
          languageCode,
        );
        if (name != null && !out.contains(name)) out.add(name);
      }
      return out;
    } on Exception {
      return const [];
    }
  }

  /// Человеческая подпись: улица с домом, иначе район, иначе город.
  /// Координаты в поле «Место» не значат ничего.
  static String? _label(Placemark m) {
    final street = [m.street, m.subThoroughfare]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ')
        .trim();
    for (final candidate in [
      street.isEmpty ? null : street,
      m.subLocality,
      m.locality,
      m.administrativeArea,
      m.country,
    ]) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }
}

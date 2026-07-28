import 'dart:convert';

import 'package:http/http.dart' as http;

/// Разговор с сервером Veha.
///
/// Отдельным слоем, чтобы синхронизацию можно было проверить без сети: в
/// тестах подставляется подделка, а логика «слить очередь → забрать чужое →
/// применить» проверяется целиком.
abstract class SyncApi {
  /// Регистрация устройства: заводит человека и отдаёт ключ.
  Future<DeviceCredentials> register(String deviceName);

  /// Второе устройство по коду с первого.
  Future<DeviceCredentials> claim(String code, String deviceName);

  /// Код для второго устройства.
  Future<String> pairCode(String token);

  /// Отправка накопленного.
  Future<PushResult> push(String token, Map<String, List<Map<String, Object?>>> changes);

  /// Приём изменений после курсора.
  Future<PullResult> pull(String token, int since);
}

class DeviceCredentials {
  const DeviceCredentials({required this.userId, required this.token});

  final String userId;
  final String token;
}

class PushResult {
  const PushResult({required this.cursor, required this.applied, required this.skipped});

  final int cursor;
  final int applied;

  /// Сколько строк сервер отклонил как устаревшие: его версия новее.
  final int skipped;
}

class PullResult {
  const PullResult({required this.cursor, required this.changes});

  final int cursor;
  final Map<String, List<Map<String, Object?>>> changes;
}

/// Настоящий разговор по HTTP.
class HttpSyncApi implements SyncApi {
  HttpSyncApi({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers([String? token]) => {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      };

  @override
  Future<DeviceCredentials> register(String deviceName) async {
    final response = await _client.post(
      _uri('/api/v1/devices/register'),
      headers: _headers(),
      body: jsonEncode({'name': deviceName}),
    );
    return _credentials(response);
  }

  @override
  Future<DeviceCredentials> claim(String code, String deviceName) async {
    final response = await _client.post(
      _uri('/api/v1/pair/claim'),
      headers: _headers(),
      body: jsonEncode({'code': code, 'name': deviceName}),
    );
    return _credentials(response);
  }

  @override
  Future<String> pairCode(String token) async {
    final response = await _client.post(
      _uri('/api/v1/pair/start'),
      headers: _headers(token),
    );
    final body = _decode(response);
    return body['code'] as String;
  }

  @override
  Future<PushResult> push(
    String token,
    Map<String, List<Map<String, Object?>>> changes,
  ) async {
    final response = await _client.post(
      _uri('/api/v1/sync/push'),
      headers: _headers(token),
      body: jsonEncode({'changes': changes}),
    );
    final body = _decode(response);
    return PushResult(
      cursor: (body['cursor'] as num).toInt(),
      applied: (body['applied'] as num?)?.toInt() ?? 0,
      skipped: (body['skipped'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<PullResult> pull(String token, int since) async {
    final response = await _client.get(
      _uri('/api/v1/sync/pull', {'since': '$since'}),
      headers: _headers(token),
    );
    final body = _decode(response);
    final changes = <String, List<Map<String, Object?>>>{};
    for (final entry in (body['changes'] as Map).entries) {
      changes[entry.key as String] = [
        for (final row in entry.value as List) Map<String, Object?>.from(row as Map),
      ];
    }
    return PullResult(
      cursor: (body['cursor'] as num).toInt(),
      changes: changes,
    );
  }

  DeviceCredentials _credentials(http.Response response) {
    final body = _decode(response);
    return DeviceCredentials(
      userId: body['user_id'] as String,
      token: body['token'] as String,
    );
  }

  Map<String, Object?> _decode(http.Response response) {
    if (response.statusCode >= 400) {
      throw SyncFailure(response.statusCode, response.body);
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
  }
}

/// Сервер ответил отказом. Отдельный тип, чтобы экран мог сказать человеку,
/// что именно случилось, а не «что-то пошло не так».
class SyncFailure implements Exception {
  const SyncFailure(this.status, this.body);

  final int status;
  final String body;

  @override
  String toString() => 'Сервер ответил $status: $body';
}

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

  /// Ключи агентов, заведённые этим человеком.
  Future<List<AgentKey>> tokens(String token);

  /// Новый ключ. Строка возвращается один раз — дальше её негде взять.
  Future<AgentKeyCreated> createToken(
    String token, {
    required String name,
    required List<KeyScope> scopes,
    int? expiresAt,
  });

  Future<void> revokeToken(String token, String id);

  /// Журнал: что и когда ключ трогал.
  Future<List<KeyAction>> tokenLog(String token, String id);
}

/// Ключ агента в списке. Самой строки тут нет и быть не может.
class AgentKey {
  const AgentKey({
    required this.id,
    required this.name,
    required this.prefix,
    this.expiresAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  final String id;
  final String name;
  final String prefix;
  final int? expiresAt;
  final int? lastUsedAt;
  final int? revokedAt;

  bool get revoked => revokedAt != null;
}

class AgentKeyCreated {
  const AgentKeyCreated({required this.id, required this.token});

  final String id;

  /// Показывается человеку один раз: на сервере остался только хеш.
  final String token;
}

class KeyScope {
  const KeyScope({required this.calendarId, required this.canWrite});

  final String calendarId;
  final bool canWrite;
}

/// Строка журнала.
class KeyAction {
  const KeyAction({
    required this.at,
    required this.tool,
    required this.action,
    required this.result,
  });

  final int at;
  final String tool;
  final String action;
  final String result;
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

  @override
  Future<List<AgentKey>> tokens(String token) async {
    final response =
        await _client.get(_uri('/api/v1/tokens'), headers: _headers(token));
    final list = _decodeList(response);
    return [
      for (final row in list)
        AgentKey(
          id: row['id'] as String,
          name: row['name'] as String,
          prefix: row['prefix'] as String,
          expiresAt: (row['expires_at'] as num?)?.toInt(),
          lastUsedAt: (row['last_used_at'] as num?)?.toInt(),
          revokedAt: (row['revoked_at'] as num?)?.toInt(),
        ),
    ];
  }

  @override
  Future<AgentKeyCreated> createToken(
    String token, {
    required String name,
    required List<KeyScope> scopes,
    int? expiresAt,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/tokens'),
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'expires_at': expiresAt,
        'scopes': [
          for (final scope in scopes)
            {'calendar_id': scope.calendarId, 'can_write': scope.canWrite},
        ],
      }),
    );
    final body = _decode(response);
    return AgentKeyCreated(
      id: body['id'] as String,
      token: body['token'] as String,
    );
  }

  @override
  Future<void> revokeToken(String token, String id) async {
    final response = await _client.delete(
      _uri('/api/v1/tokens/$id'),
      headers: _headers(token),
    );
    _decode(response);
  }

  @override
  Future<List<KeyAction>> tokenLog(String token, String id) async {
    final response = await _client.get(
      _uri('/api/v1/tokens/$id/log'),
      headers: _headers(token),
    );
    return [
      for (final row in _decodeList(response))
        KeyAction(
          at: (row['at'] as num).toInt(),
          tool: row['tool'] as String,
          action: row['action'] as String,
          result: row['result'] as String,
        ),
    ];
  }

  List<Map<String, Object?>> _decodeList(http.Response response) {
    if (response.statusCode >= 400) {
      throw SyncFailure(response.statusCode, response.body);
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return [for (final row in decoded) Map<String, Object?>.from(row as Map)];
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

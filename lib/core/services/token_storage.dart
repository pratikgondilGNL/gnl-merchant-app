import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String clubIdKey = 'club_id';

  final FlutterSecureStorage _storage;

  AppStorage() : _storage = const FlutterSecureStorage();

  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> writeAll(Map<String, String> pairs) async {
    await Future.wait(
      pairs.entries.map((e) => _storage.write(key: e.key, value: e.value)),
    );
  }

  Future<void> deleteAll(List<String> keys) async {
    await Future.wait(
      keys.map((k) => _storage.delete(key: k)),
    );
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final tokens = <String, String>{
      accessTokenKey: accessToken,
    };

    if (refreshToken != null && refreshToken.isNotEmpty) {
      tokens[refreshTokenKey] = refreshToken;
    }

    await writeAll(tokens);
  }

  Future<String?> getAccessToken() async => read(accessTokenKey);

  Future<String?> getRefreshToken() async => read(refreshTokenKey);

  Future<void> clearTokens() async =>
      deleteAll([accessTokenKey, refreshTokenKey]);

  Future<void> clearAll() => _storage.deleteAll();

  Future<void> saveClubId(String clubId) => write(key: clubIdKey, value: clubId);

  Future<String?> getClubId() => read(clubIdKey);
}

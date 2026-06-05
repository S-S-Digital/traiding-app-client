import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';
  static const _userIdKey = 'user_id';
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    // write() overwrites existing values, no need to delete first.
    // Write the refresh token FIRST: if the process is killed between the two
    // writes, we'd rather end up with a refresh token but no access token
    // (recoverable — the interceptor/splash can refresh) than an access token
    // with a stale/absent refresh token (which would eventually force a logout).
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _accessKey, value: access);
  }

  Future<(String?, String?)> getTokens() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    return (access, refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userIdKey);
  }
}

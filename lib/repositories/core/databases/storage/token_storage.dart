import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);

    
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<(String?, String?)> getTokens() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    return (access, refresh);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}

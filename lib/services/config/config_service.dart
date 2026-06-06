import 'dart:convert';

import 'package:aspiro_trade/api/models/app_config/app_config_dto.dart';
import 'package:aspiro_trade/services/config/app_config_defaults.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:talker/talker.dart';

/// Network + local-cache layer for the server-driven app config.
///
/// - `fetch()` GETs the public `/app-config` (no auth) on its own Dio so the
///   auth interceptor / force-logout path can never touch it.
/// - The last good payload is persisted to secure storage so the app works
///   offline and survives a cold start with the last known config.
/// - Every failure path returns the last cache, then the baked default — the
///   app is never left without a usable config.
class ConfigService {
  ConfigService({
    required String apiUrl,
    required FlutterSecureStorage storage,
    Talker? talker,
    Dio? dio,
  })  : _storage = storage,
        _talker = talker,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: apiUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  static const _cacheKey = 'app_config_cache_v1';

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final Talker? _talker;

  /// Fetch fresh config from the server. Throws on any failure (caller decides
  /// whether to fall back to [loadCached] / [defaultConfig]).
  Future<AppConfigDto> fetch() async {
    final res = await _dio.get<dynamic>('/app-config');
    final data = res.data;
    final map = data is Map
        ? data.map((k, v) => MapEntry(k.toString(), v))
        : jsonDecode(data as String) as Map<String, dynamic>;
    final config = AppConfigDto.fromJson(Map<String, dynamic>.from(map));
    await _persist(config);
    return config;
  }

  /// Last successfully-fetched config, or null if none cached / unparsable.
  Future<AppConfigDto?> loadCached() async {
    try {
      final raw = await _storage.read(key: _cacheKey);
      if (raw == null || raw.isEmpty) return null;
      return AppConfigDto.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (e, st) {
      _talker?.handle(e, st, 'ConfigService: failed to read cache');
      return null;
    }
  }

  /// Baked crypto-only default == today's hardcoded behavior.
  AppConfigDto defaultConfig() => AppConfigDefaults.build();

  Future<void> _persist(AppConfigDto config) async {
    try {
      await _storage.write(key: _cacheKey, value: jsonEncode(config.toJson()));
    } catch (e, st) {
      _talker?.handle(e, st, 'ConfigService: failed to persist cache');
    }
  }
}

import 'dart:async';

import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/realm/realm.dart' as signals_realm;
import 'package:aspiro_trade/repositories/tickers/realm/realm.dart' as tickers_realm;
import 'package:aspiro_trade/repositories/assets/realm/realm.dart' as assets_realm;
import 'package:aspiro_trade/services/websocket_service.dart';
import 'package:aspiro_trade/services/widget_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:realm/realm.dart';

class AuthRepository extends BaseRepository implements AuthRepositoryI {
  AuthRepository(
    super.talker, {
    required this.api,
    required this.realm,
    required this.tokenStorage,
    required this.firebaseAuth,
    required this.webSocketService,
    required this.apiUrl,
  });

  final AspiroTradeApi api;
  Realm realm;
  final TokenStorage tokenStorage;
  final FirebaseAuth firebaseAuth;
  final WebSocketService webSocketService;
  final String apiUrl;

  @override
  Future<User> login(Login login) => safeApiCall(() async {
    final userDto = await api.login(login);

    await tokenStorage.saveTokens(userDto.accessToken, userDto.refreshToken);

    talker.info('Login successful, token length: ${userDto.accessToken.length}');

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(userDto.user.toLocal(), update: true);
    });

    await WidgetService.pushAuth(accessToken: userDto.accessToken, apiUrl: apiUrl);
    webSocketService.connect();

    return userDto.user.toEntity();
  });

  @override
  Future<void> logout() => safeApiCall(() async {
    await api.logout();
    await tokenStorage.clear();
    // Hard-clear ALL user-scoped caches so the next account that logs in on this
    // device never sees the previous user's (possibly premium-gated) data.
    // Tokens + UserLocal alone are not enough: signals/tickers/assets/candles
    // were persisted in Realm and would otherwise survive across sessions.
    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.deleteAll<signals_realm.SignalsLocal>();
      realm.deleteAll<tickers_realm.TickersLocal>();
      realm.deleteAll<assets_realm.AssetsLocal>();
      realm.deleteAll<assets_realm.CandlesLocal>();
    });
  });

  @override
  Future<String> refresh() => safeApiCall(() async {
    final (_, refresh) = await tokenStorage.getTokens();

    if (refresh == null || refresh.isEmpty) {
      throw UnauthorizedException(AppLocalizations.errorSessionExpired);
    }

    final tokens = await api.refresh(Refresh(refreshToken: refresh));

    await tokenStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
    // Fire-and-forget: the home-widget platform channel can HANG on some
    // launchers/ROMs (no built-in timeout), and refresh() runs on the splash —
    // awaiting it could freeze the app on the loading screen forever. The
    // widget update is best-effort, so never block startup on it.
    unawaited(
      WidgetService.pushAuth(accessToken: tokens.accessToken, apiUrl: apiUrl),
    );
    webSocketService.connect();

    return tokens.accessToken;
  });

  @override
  Future<User> register(Register register) => safeApiCall(() async {
    final userDto = await api.register(register);

    await tokenStorage.saveTokens(userDto.accessToken, userDto.refreshToken);

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(userDto.user.toLocal(), update: true);
    });

    await WidgetService.pushAuth(accessToken: userDto.accessToken, apiUrl: apiUrl);
    webSocketService.connect();

    return userDto.user.toEntity();
  });

  @override
  Future<void> registerFcmToken(FirebaseToken token) => safeApiCall(() async {
    // Only register the FCM token once we actually have a session. Firing this
    // tokenless during cold start produces a spurious 401 (and previously a
    // logout loop). If there is no access token yet, skip silently — it will be
    // (re)sent on the next authenticated app open / token refresh.
    final (accessToken, _) = await tokenStorage.getTokens();
    if (accessToken == null || accessToken.isEmpty) {
      talker.info('Skip FCM token registration: no access token yet');
      return;
    }
    await api.registerFcmToken(token);
  });

  @override
  Future<User> getCurrentUser() async {
    try {
      final userLocal = realm.all<UserLocal>().isNotEmpty
          ? realm.all<UserLocal>().first
          : null;
      if (userLocal == null) {
        throw const UnauthorizedException();
      }
      return User(
        id: userLocal.id,
        email: userLocal.email,
        phone: userLocal.phone,
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<User> appleSignIn(AppleAuth appleAuth) => safeApiCall(() async {
    talker.debug('Apple auth completed (email=${appleAuth.email})');
    final response = await api.appleSignIn(appleAuth);

    await tokenStorage.saveTokens(response.accessToken, response.refreshToken);

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(response.user.toLocal(), update: true);
    });

    await WidgetService.pushAuth(accessToken: response.accessToken, apiUrl: apiUrl);
    webSocketService.connect();

    return response.user.toEntity();
  });

  @override
  Future<User> googleSignIn(GoogleAuth googleAuth) => safeApiCall(() async {
    talker.debug('Google auth completed (email=${googleAuth.email})');
    final response = await api.googleSignIn(googleAuth);

    await tokenStorage.saveTokens(response.accessToken, response.refreshToken);

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(response.user.toLocal(), update: true);
    });

    await WidgetService.pushAuth(accessToken: response.accessToken, apiUrl: apiUrl);
    webSocketService.connect();

    return response.user.toEntity();
  });
}



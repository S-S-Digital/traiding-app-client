import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:realm/realm.dart';

class AuthRepository extends BaseRepository implements AuthRepositoryI {
  AuthRepository(
    super.talker, {
    required this.api,
    required this.realm,
    required this.tokenStorage,
    required this.firebaseAuth,
  });

  final AspiroTradeApi api;
  Realm realm;
  final TokenStorage tokenStorage;
  final FirebaseAuth firebaseAuth;

  @override
  Future<User> login(Login login) => safeApiCall(() async {
    final userDto = await api.login(login);

    await tokenStorage.saveTokens(userDto.accessToken, userDto.refreshToken);

    talker.info(userDto.accessToken);

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(userDto.user.toLocal(), update: true);
    });

    return userDto.user.toEntity();
  });

  @override
  Future<void> logout() => safeApiCall(() async {
    await api.logout();
    await tokenStorage.clear();
  });

  @override
  Future<String> refresh() => safeApiCall(() async {
    final (_, refresh) = await tokenStorage.getTokens();

    if (refresh == null || refresh.isEmpty) {
      throw const UnauthorizedException('Необходимо переавторизоваться!');
    }

    final tokens = await api.refresh(Refresh(refreshToken: refresh));

    await tokenStorage.saveTokens(tokens.accessToken, tokens.refreshToken);

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
    return userDto.user.toEntity();
  });

  @override
  Future<void> registerFcmToken(FirebaseToken token) => safeApiCall(() async {
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
    final response = await api.appleSignIn(appleAuth);

    await tokenStorage.saveTokens(response.accessToken, response.refreshToken);

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(response.user.toLocal(), update: true);
    });
    return response.user.toEntity();
  });

  @override
  Future<User> googleSignIn(GoogleAuth googleAuth) => safeApiCall(() async {
    final response = await api.googleSignIn(googleAuth);

    await tokenStorage.saveTokens(response.accessToken, response.refreshToken);

    realm.write(() {
      realm.deleteAll<UserLocal>();
      realm.add(response.user.toLocal(), update: true);
    });
    return response.user.toEntity();
  });
}

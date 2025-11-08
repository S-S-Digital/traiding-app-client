import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:realm/realm.dart';

class AuthRepository extends BaseRepository implements AuthRepositoryI {
  AuthRepository(
    super.talker, {
    required this.api,
    required this.realm,
    required this.tokenStorage,
  });

  final AspiroTradeApi api;
  final Realm realm;
  final TokenStorage tokenStorage;

  @override
  Future<User> login(Login login) => safeApiCall(() async {
    final userDto = await api.login(login);

    await tokenStorage.saveTokens(userDto.accessToken, userDto.refreshToken);

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
    realm.write(() {
      realm.deleteAll();
    });
  });

  @override
  Future<String> refresh() => safeApiCall(() async {
    final (_, refresh) = await tokenStorage.getTokens();

    if (refresh == null || refresh.isEmpty) {
      throw UnauthorizedException('Необходимо переавторизоваться!');
    }

    final tokens = await api.refresh(Refresh(refreshToken: refresh));

    await tokenStorage.clear();
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
  Future<String> registerFcmToken(FirebaseToken token) =>
      safeApiCall(() => api.registerFcmToken(token));
}

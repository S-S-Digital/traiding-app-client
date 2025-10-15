import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:realm/realm.dart';

class AuthRepository implements AuthRepositoryI{
  AuthRepository({required this.api, required this.realm});

  final AspiroTradeApi api;
  final Realm realm;

  
  @override
  Future<User> login(Login login) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<RefreshDto> refresh(Refresh refresh) {
    // TODO: implement refresh
    throw UnimplementedError();
  }

  @override
  Future<User> register(Register register) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<String> registerFcmToken(FirebaseToken token) {
    // TODO: implement registerFcmToken
    throw UnimplementedError();
  }

}
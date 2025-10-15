import 'package:aspiro_trade/api/models/auth/auth.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';

abstract interface class AuthRepositoryI{
  Future<User> register(Register register);
  Future<User> login(Login login);
  Future<RefreshDto> refresh(Refresh refresh);
  Future<String> registerFcmToken(FirebaseToken token);
  Future<void> logout();
}
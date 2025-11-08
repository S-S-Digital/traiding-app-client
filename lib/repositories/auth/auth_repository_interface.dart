
import 'package:aspiro_trade/repositories/auth/auth.dart';

abstract interface class AuthRepositoryI{
  Future<User> register(Register register);
  Future<User> login(Login login);
  Future<String> refresh();
  Future<String> registerFcmToken(FirebaseToken token);
  Future<void> logout();
}

import 'package:aspiro_trade/repositories/auth/auth.dart';

abstract interface class AuthRepositoryI{
  Future<User> register(Register register);
  Future<User> login(Login login);
  Future<String> refresh();
  Future<void> registerFcmToken(FirebaseToken token);
  Future<void> logout();
  Future<User> getCurrentUser();
  Future<User> googleSignIn(GoogleAuth googleAuth);
  Future<User> appleSignIn(AppleAuth appleAuth);
}
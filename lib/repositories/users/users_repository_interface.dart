import 'package:aspiro_trade/repositories/users/users.dart';

abstract interface class UsersRepositoryI{
  Future<Users> getCurrentUser();
  Future<Limits> getLimits();
}
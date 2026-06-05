import 'package:aspiro_trade/repositories/users/users.dart';

abstract interface class UsersRepositoryI{
  Future<Users> getCurrentUser();
  Future<Limits> getLimits();
  Future<void> deleteAccount();

  /// Reads the account-level strategy mode (quality | turnover).
  Future<StrategyMode> getStrategyMode();

  /// Updates the account-level strategy mode; returns the new mode.
  Future<StrategyMode> setStrategyMode(String mode);
}
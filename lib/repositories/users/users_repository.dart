import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/users/users.dart';

class UsersRepository extends BaseRepository implements UsersRepositoryI {
  UsersRepository(super.talker, {required this.api});
  final AspiroTradeApi api;

  @override
  Future<Users> getCurrentUser() => safeApiCall(() async {
    final response = await api.getCurrentUser();

    return response.toEntity();
  });

  @override
  Future<Limits> getLimits() => safeApiCall(() async {
    final response = await api.getLimits();

    return response.toEntity();
  });
}

import 'package:realm/realm.dart';

part 'user_local.realm.dart';

@RealmModel()
class _UserLocal {
  @PrimaryKey()
  late String id;
  late String email;
  late String phone;

  late String accessToken;
  late String refreshToken;

}
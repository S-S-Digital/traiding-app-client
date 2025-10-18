import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class AppConfig {
  AppConfig({
    required this.preferences,
    required this.talker,
    required this.apiUrl,
    required this.api,
    required this.realm,
    required this.tokenStorage
  });

  final SharedPreferences preferences;
  final Talker talker;
  final String apiUrl;
  final AspiroTradeApi api;
  final Realm realm;
  final TokenStorage tokenStorage;
}

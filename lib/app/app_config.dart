import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class AppConfig {
  AppConfig({required this.preferences, required this.talker, required this.apiUrl});

  final SharedPreferences preferences;
  final Talker talker;
  final String apiUrl;

}

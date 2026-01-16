import 'package:shared_preferences/shared_preferences.dart';

class PreferencesInitializer {
  static SharedPreferences? _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    final prefs = _instance;
    if (prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return prefs;
  }
}

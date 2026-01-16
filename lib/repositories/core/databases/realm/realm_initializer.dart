import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:realm/realm.dart';

class RealmInitializer{
  static Realm? _instance;

  static Future<void> init() async {
    final config = Configuration.local(
      realmSchemas, 
      shouldDeleteIfMigrationNeeded: true,
    );

    _instance = Realm(config);
  }

  static Realm get instance {
    if (_instance == null) {
      throw Exception('Realm not initialized. Call init() first.');
    }
    return _instance!;
  }
}
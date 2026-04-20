import 'package:aspiro_trade/api/aspiro_trade_api.dart';
import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/app/aspiro_trade_app.dart';
import 'package:aspiro_trade/firebase_options.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAuth = FirebaseAuth.instanceFor(app: app);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3001',
  );
  if (kReleaseMode && !apiUrl.startsWith('https://')) {
    throw StateError(
      'API_URL must be HTTPS in release builds. '
      'Pass --dart-define=API_URL=https://... Got: $apiUrl',
    );
  }
  assert(
    apiUrl.startsWith('https://') || kDebugMode,
    'API_URL must be HTTPS outside debug. Got: $apiUrl',
  );
  await RealmInitializer.init();
  BlocInitializer.init();

  final tokenStorage = TokenStorage();
  final realm = RealmInitializer.instance;


  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final firebaseMessaging = FirebaseMessaging.instance;

  final api = AspiroTradeApi.create(
    apiUrl: apiUrl,
    talker: talker,
    getTokens: tokenStorage.getTokens,
    saveTokens: (String access, String refresh) =>
        tokenStorage.saveTokens(access, refresh),
    onForceLogout: () async {
      await tokenStorage.clear();
      // Router will detect missing token and redirect to login
    },
  );

  final config = AppConfig(
    talker: talker,
    apiUrl: apiUrl,
    api: api,
    realm: realm,
    tokenStorage: tokenStorage,
    firebaseMessaging: firebaseMessaging,
    localNotificationsPlugin: flutterLocalNotificationsPlugin,
    firebaseAuth: firebaseAuth
  );


  // Pre-load saved language before building the app
  final savedLang = await const FlutterSecureStorage().read(key: 'app_language');
  if (savedLang == 'ru') {
    AppLocalizations.setLanguage(AppLanguage.ru);
  }

  runApp(AspiroTradeApp(config: config, initialLanguage: savedLang == 'ru' ? AppLanguage.ru : AppLanguage.en));
}

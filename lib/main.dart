import 'package:aspiro_trade/api/aspiro_trade_api.dart';
import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/app/aspiro_trade_app.dart';
import 'package:aspiro_trade/services/websocket_service.dart';
import 'package:aspiro_trade/services/notification_navigation_service.dart';
import 'package:aspiro_trade/firebase_options.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/services/widget_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';


/// Runs in a separate isolate when a push arrives with the app closed or
/// backgrounded. Pushes the signal into the iOS widget so it updates even if
/// the user never opens the app.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await WidgetService.init();
    if (message.data['type'] == 'trading_signal') {
      final entryPrice = double.tryParse(message.data['price'] ?? '') ?? 0;
      await WidgetService.pushSignal(
        symbol: message.data['symbol'] ?? '',
        direction: message.data['direction'] ?? 'BUY',
        entry: entryPrice,
        price: entryPrice,
        tp: double.tryParse(message.data['TP'] ?? '') ?? 0,
        sl: double.tryParse(message.data['SL'] ?? '') ?? 0,
      );
    }
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await WidgetService.init();

  final firebaseAuth = FirebaseAuth.instanceFor(app: app);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://tradeaspiro.ru',
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

  final webSocketService = WebSocketService(apiUrl: apiUrl, tokenStorage: tokenStorage);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final firebaseMessaging = FirebaseMessaging.instance;

  // Single router instance shared with the app so a mid-session force-logout
  // can actually navigate the user to Login (there is no AuthGuard on routes).
  final appRouter = AppRouter();

  // Give the notification-tap router the same shared instance so taps can
  // actually navigate (audit H1).
  NotificationNavigationService.instance.attachRouter(appRouter);

  final api = AspiroTradeApi.create(
    apiUrl: apiUrl,
    talker: talker,
    getTokens: tokenStorage.getTokens,
    saveTokens: (String access, String refresh) async {
      await tokenStorage.saveTokens(access, refresh);
      await WidgetService.pushAuth(accessToken: access, apiUrl: apiUrl);
      webSocketService.connect();
    },
    onForceLogout: () async {
      await tokenStorage.clear();
      await WidgetService.pushAuth(accessToken: null, apiUrl: apiUrl);
      webSocketService.disconnect();
      // Clearing tokens alone does NOT move the user off the current screen
      // (no AuthGuard), so explicitly reset the navigation stack to Login.
      // Guarded: navigation may not be mounted yet during very early startup.
      try {
        await appRouter.replaceAll([const LoginRoute()]);
      } catch (_) {}
    },
  );

  // Sync any already-saved token at startup so widget can auth on cold launch.
  final (existingAccess, _) = await tokenStorage.getTokens();
  await WidgetService.pushAuth(accessToken: existingAccess, apiUrl: apiUrl);

  if (existingAccess != null) {
    webSocketService.connect();
  }

  final config = AppConfig(
    talker: talker,
    apiUrl: apiUrl,
    api: api,
    realm: realm,
    tokenStorage: tokenStorage,
    firebaseMessaging: firebaseMessaging,
    localNotificationsPlugin: flutterLocalNotificationsPlugin,
    firebaseAuth: firebaseAuth,
    webSocketService: webSocketService,
  );


  // Pre-load saved language before building the app
  final savedLang = await const FlutterSecureStorage().read(key: 'app_language');
  if (savedLang == 'ru') {
    AppLocalizations.setLanguage(AppLanguage.ru);
  }

  runApp(AspiroTradeApp(
    config: config,
    appRouter: appRouter,
    initialLanguage: savedLang == 'ru' ? AppLanguage.ru : AppLanguage.en,
  ));
}

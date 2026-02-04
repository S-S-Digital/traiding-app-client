import 'package:aspiro_trade/api/aspiro_trade_api.dart';
import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/app/aspiro_trade_app.dart';
import 'package:aspiro_trade/firebase_options.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAuth = FirebaseAuth.instanceFor(app: app);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: ".env");

  final apiUrl = dotenv.env['API_URL'];
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
  );

  final config = AppConfig(
    talker: talker,
    apiUrl: apiUrl ?? '',
    api: api,
    realm: realm,
    tokenStorage: tokenStorage,
    firebaseMessaging: firebaseMessaging,
    localNotificationsPlugin: flutterLocalNotificationsPlugin,
    firebaseAuth: firebaseAuth
  );


  runApp(AspiroTradeApp(config: config));
}

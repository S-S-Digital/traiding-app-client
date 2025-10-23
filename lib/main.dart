import 'package:aspiro_trade/api/aspiro_trade_api.dart';
import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/app/aspiro_trade_app.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/tickers/realm/tickers_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: ".env");

  final apiUrl = dotenv.env['API_URL'];

  final preferences = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage();
  var realmConfig = Configuration.local([
    UserLocal.schema,
    TickersLocal.schema,
  ]);
  var realm = Realm(realmConfig);

  final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      useConsoleLogs: kDebugMode,
      useHistory: kDebugMode,
    ),
  );

  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      printEventFullData: true,
      printStateFullData: true,
    ),
  );

  final api = AspiroTradeApi.create(apiUrl: apiUrl, talker: talker);

  final config = AppConfig(
    preferences: preferences,
    talker: talker,
    apiUrl: apiUrl ?? '',
    api: api,
    realm: realm,
    tokenStorage: tokenStorage,
  );


  

  runApp(AspiroTradeApp(config: config));
}

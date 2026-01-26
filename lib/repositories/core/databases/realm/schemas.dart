import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';

final realmSchemas = [
  UserLocal.schema,
  TickersLocal.schema,
  AssetsLocal.schema,
  CandlesLocal.schema,
  // SubscriptionPlansLocal.schema,
  SignalsLocal.schema,
];

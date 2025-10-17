import 'package:realm/realm.dart';

part 'tickers_local.realm.dart';

@RealmModel()
class _TickersLocal {
  @PrimaryKey()
  late String id;

  late String userId;
  late String symbol;
  late String timeframe;
  late bool notifyBuy;
  late bool notifySell;
  late bool isActive;
  late DateTime addedAt;
}
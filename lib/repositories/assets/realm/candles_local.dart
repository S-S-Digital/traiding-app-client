import 'package:realm/realm.dart';

part 'candles_local.realm.dart';

@RealmModel()
class _CandlesLocal {
  @PrimaryKey()
  late String id;
    late int openTime;
  late String open;
  late String high;
  late String low;
  late String close;
  late String volume;
  late int closeTime;
  late String quoteAssetVolume;
  late String numberOfTrades;
  late String takerBuyBaseAssetVolume;
  late String takerBuyQuoteAssetVolume;
}
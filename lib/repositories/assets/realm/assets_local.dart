import 'package:realm/realm.dart';

part 'assets_local.realm.dart';

@RealmModel()
class _AssetsLocal {
  @PrimaryKey()
  late String id;
  late String symbol;
  late String name;
  late String baseAsset;
  late String quoteAsset;
  late String price;
  late String change24h;
  late String logoUrl;
}
import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';


abstract interface class AssetsRepositoryI {
  Future<List<Assets>> fetchAllAssets();
  Future<List<Assets>> fetchPopularAssets();
  Future<List<Assets>> searchAssets(String query);
  Future<Assets> fetchAssetsBySymbol(String symbol);
  Future<ValidateSymbolDto> validateSymbol(String symbol);
  Future<List<Candles>> fetchCandlesForSymbol(
    String symbol,
    String limit,
    String interval,
  );

  Stream<List<Assets>> watchAssets(
    List<String> symbols,
    Duration interval,
  );

  
}

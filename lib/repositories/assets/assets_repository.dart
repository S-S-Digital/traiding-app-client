import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:realm/realm.dart';

class AssetsRepository extends BaseRepository implements AssetsRepositoryI{
  AssetsRepository(super.talker,{required this.api, required this.realm});



  final AspiroTradeApi api;
  final Realm realm;

  @override
  Future<List<Assets>> fetchAllAssets() => safeApiCall(() async { 
    throw UnimplementedError();
  });

  @override
  Future<List<Candles>> fetchCandlesForSymbol(String symbol, String limit, String interval) {
    // TODO: implement fetchCandlesForSymbol
    throw UnimplementedError();
  }

  @override
  Future<List<Assets>> fetchPopularAssets() {
    // TODO: implement fetchPopularAssets
    throw UnimplementedError();
  }

  @override
  Future<List<Assets>> searchAssets(String query) {
    // TODO: implement searchAssets
    throw UnimplementedError();
  }

  @override
  Future<ValidateSymbolDto> validateSymbol(String symbol) {
    // TODO: implement validateSymbol
    throw UnimplementedError();
  }
}
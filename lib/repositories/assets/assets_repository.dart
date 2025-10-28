import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:realm/realm.dart';

class AssetsRepository extends BaseRepository implements AssetsRepositoryI {
  AssetsRepository(super.talker, {required this.api, required this.realm});

  final AspiroTradeApi api;
  final Realm realm;

  @override
  Future<List<Assets>> fetchAllAssets() => safeApiCall(() async {
    final response = await api.fetchAllAssets();
    final assets = response.map((e) => e.toEntity()).toList();
    realm.write(() {
      realm.deleteAll<AssetsLocal>();

      realm.addAll(response.map((e) => e.toLocal()), update: true);
    });

    return assets;
  });

  @override
  Future<List<Candles>> fetchCandlesForSymbol(
    String symbol,
    String limit,
    String interval,
  ) => safeApiCall(() async {
    final response = await api.fetchCandlesForSymbol(symbol, limit, interval);

    final candles = response.map((e) => e.toEntity()).toList();

    realm.write(() {
      realm.deleteAll<CandlesLocal>();

      realm.addAll(response.map((e) => e.toLocal()), update: true);
    });

    return candles;
  });

  @override
  Future<List<Assets>> fetchPopularAssets() => safeApiCall(() async {
    final response = await api.fetchPopularAssets();
    return response.map((e) => e.toEntity()).toList();
  });

  @override
  Future<List<Assets>> searchAssets(String query) => safeApiCall(() async {
    final response = await api.searchAssets(query);

    return response.map((e) => e.toEntity()).toList();
  });

  @override
  Future<ValidateSymbolDto> validateSymbol(String symbol) =>
      safeApiCall(() => api.validateSymbol(symbol));
}

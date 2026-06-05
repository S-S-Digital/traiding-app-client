import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:realm/realm.dart';

class AssetsRepository extends BaseRepository implements AssetsRepositoryI {
  AssetsRepository(super.talker, {required this.api, required this.realm});

  final AspiroTradeApi api;
  final Realm realm;

  /// In-flight de-duplication for [fetchAllAssets]. On app open, SignalsBloc and
  /// TickersBloc both request the full asset list within the same frame; without
  /// this they would fire two identical network calls and run `deleteAll` +
  /// re-add on Realm twice (thrash). Sharing the active Future collapses the
  /// burst into a single request. It only coalesces calls that overlap in time —
  /// once the request completes the field is cleared, so there is zero staleness
  /// risk and pull-to-refresh still gets fresh data.
  Future<List<Assets>>? _inFlightAllAssets;

  @override
  Future<List<Assets>> fetchAllAssets() {
    final pending = _inFlightAllAssets;
    if (pending != null) return pending;

    final future = safeApiCall(() async {
      final response = await api.fetchAllAssets();
      final assets = response.map((e) => e.toEntity()).toList();
      realm.write(() {
        realm.deleteAll<AssetsLocal>();

        realm.addAll(response.map((e) => e.toLocal()), update: true);
      });

      return assets;
    }).whenComplete(() => _inFlightAllAssets = null);

    _inFlightAllAssets = future;
    return future;
  }

  @override
  Future<List<Candles>> fetchCandlesForSymbol(
    String symbol,
    String limit,
    String interval,
  ) => safeApiCall(() async {
    final response = await api.fetchCandlesForSymbol(symbol, limit, interval);
    final candlesDto = response.candles;

    final candles = candlesDto.map((e) => e.toEntity()).toList();

    realm.write(() {
      realm.deleteAll<CandlesLocal>();

      realm.addAll(candlesDto.map((e) => e.toLocal()), update: true);
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

  @override
  Future<Assets> fetchAssetsBySymbol(String symbol) => safeApiCall(() async {
    final response = await api.fetchAssetsBySymbol(symbol);

    if (response.symbol == null || response.symbol!.isEmpty) {
      talker.debug('Бэкенд вернул ошибку для символа: $symbol');
      return Assets.empty(symbol);
    }

    // Сохраняем ассет в локальный кэш Realm для мгновенного отображения при перезапуске
    realm.write(() {
      realm.add(response.toLocal(), update: true);
    });

    return response.toEntity();
  });

  @override
  Future<Assets?> fetchLocalAssetsBySymbol(String symbol) async {
    try {
      final local = realm.query<AssetsLocal>('symbol == \$0', [symbol]).firstOrNull;
      return local?.toEntity();
    } catch (e, stack) {
      talker.error('Failed to fetch local assets for symbol $symbol', e, stack);
      return null;
    }
  }

  @override
  void clearLocalCache() {
    try {
      realm.write(() {
        realm.deleteAll<AssetsLocal>();
        realm.deleteAll<CandlesLocal>();
      });
    } catch (e, stack) {
      talker.error('Failed to clear local assets cache', e, stack);
    }
  }

  @override
  Stream<List<Assets>> watchAssets(
    List<String> symbols,
    Duration interval,
  ) async* {
    int consecutiveErrors = 0;
    const maxBackoffMultiplier = 6; // max ~2min with 20s base

    while (true) {
      try {
        // Batch requests: 3 at a time to avoid thundering herd
        final results = <Assets>[];
        for (var i = 0; i < symbols.length; i += 3) {
          final batch = symbols.sublist(
            i,
            i + 3 > symbols.length ? symbols.length : i + 3,
          );
          final batchResults = await Future.wait(
            batch.map((symbol) => fetchAssetsBySymbol(symbol)),
          );
          results.addAll(batchResults);
        }
        yield results;
        consecutiveErrors = 0; // Reset on success
      } catch (e, stack) {
        consecutiveErrors++;
        talker.error(
          "Polling error ($consecutiveErrors consecutive)",
          e,
          stack,
        );
      }

      // Exponential backoff: 20s, 40s, 80s... capped at ~2min
      final multiplier = consecutiveErrors.clamp(0, maxBackoffMultiplier);
      final delay = interval * (1 << multiplier);
      await Future.delayed(delay);
    }
  }
}

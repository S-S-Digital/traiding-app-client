

import 'package:aspiro_trade/repositories/tickers/tickers.dart';

abstract interface class TickersRepositoryI{
  Future<Tickers> addNewTicker(AddTicker ticker);
  Future<List<Tickers>> fetchAllTickers();
  Future<void> deleteTicker(String id);
  Future<void> updateTickerSignals(String id, AddTicker ticker);

  Future<List<Tickers>> fetchAllLocalTickers();

  /// Evicts the persisted (Realm) tickers cache. Used on a premium/subscription
  /// transition so stale gated content is not served from disk.
  void clearLocalCache();

}

import 'package:aspiro_trade/repositories/signals/signals.dart';

abstract interface class SignalsRepositoryI {
  Future<List<Signals>> fetchAllSignals(
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  );
  Future<List<Signals>> fetchSignalsByTickerId(
    String tickerId,
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  );


  Future<HistoryList> fetchHistory(
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  );

  Future<SignalStats> fetchStats({String? category});

  Future<List<Signals>> fetchLocalSignals();

  /// Evicts the persisted (Realm) signals cache. Used on a premium/subscription
  /// transition so stale gated content is not served from disk before a fresh
  /// fetch completes.
  void clearLocalCache();
}

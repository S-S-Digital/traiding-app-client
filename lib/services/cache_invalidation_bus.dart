import 'dart:async';

/// Global, app-wide cache-invalidation signal.
///
/// A single broadcast bus that decouples the *trigger* of a cache invalidation
/// (e.g. a premium/subscription status change, owned by ProfileCubit) from the
/// *consumers* that must react to it (SignalsBloc / TickersBloc / HistoryBloc).
///
/// Consumers listen to [onInvalidateMarketData] and force a fresh refetch. Because
/// the data repositories' `fetchAll*` methods do `deleteAll` + re-add on every
/// call, refetching automatically overwrites the stale Realm cache with fresh,
/// server-gated data. This handles BOTH premium directions:
///   * newly-premium  → refetch returns gated signals → user sees them at once
///   * cancelled       → refetch returns non-premium data → cached premium content wiped
///
/// Trigger side (owned by gating logic) simply calls:
///   CacheInvalidationBus.instance.invalidateMarketData();
class CacheInvalidationBus {
  CacheInvalidationBus._();

  static final CacheInvalidationBus instance = CacheInvalidationBus._();

  final _marketDataController = StreamController<void>.broadcast();

  /// Fires whenever user-scoped market data (signals/tickers/assets) must be
  /// considered stale and refetched — e.g. on a premium/subscription change.
  Stream<void> get onInvalidateMarketData => _marketDataController.stream;

  /// Signal that all cached market data is stale and should be refetched.
  /// Safe to call from anywhere (e.g. ProfileCubit on premium change).
  void invalidateMarketData() {
    if (!_marketDataController.isClosed) {
      _marketDataController.add(null);
    }
  }

  /// For tests / full app teardown only. The app uses a single long-lived
  /// instance, so this is normally never called in production.
  void dispose() {
    _marketDataController.close();
  }
}

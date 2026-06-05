import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:aspiro_trade/api/models/signals/signals_dto.dart';
import 'package:aspiro_trade/features/signals/models/combined_signal.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/services/widget_service.dart';
import 'package:aspiro_trade/services/websocket_service.dart';
import 'package:aspiro_trade/services/cache_invalidation_bus.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/core/logs/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'signals_event.dart';
part 'signals_state.dart';

class SignalsBloc extends Bloc<SignalsEvent, SignalsState> {
  SignalsBloc({
    required SignalsRepositoryI signalsRepository,
    required AssetsRepositoryI assetsRepository,
    required WebSocketService webSocketService,
  }) : _signalsRepository = signalsRepository,
       _assetsRepository = assetsRepository,
       _webSocketService = webSocketService,

       super(const SignalsState()) {
    on<Start>(_start);
    on<StopTimer>((event, emit) {
      _priceSubscription?.cancel();
      _signalSubscription?.cancel();
      _signalClosedSubscription?.cancel();
      _signalLiveUpdateSubscription?.cancel();
    });
    on<Update>(_update);
    on<OnWebSocketPriceUpdate>(_onPriceUpdate);
    on<OnWebSocketSignalUpdate>(_onSignalUpdate);
    on<OnWebSocketSignalClosed>(_onSignalClosed);
    on<OnWebSocketSignalLiveUpdate>(_onSignalLiveUpdate);
    on<ChangeFilter>((event, emit) {
      emit(state.copyWith(activeFilter: event.filter));
    });

    // Premium/subscription change → force a fresh refetch so gated content is
    // re-resolved against the server (newly-premium sees signals, cancelled
    // user stops seeing cached premium signals).
    _invalidationSubscription =
        CacheInvalidationBus.instance.onInvalidateMarketData.listen((_) {
      add(Update());
    });
  }
  final SignalsRepositoryI _signalsRepository;
  final AssetsRepositoryI _assetsRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _priceSubscription;
  StreamSubscription? _signalSubscription;
  StreamSubscription? _signalClosedSubscription;
  StreamSubscription? _signalLiveUpdateSubscription;
  StreamSubscription? _invalidationSubscription;

  /// Coalesces bursts of socket `new_signal` events into a single REST refetch.
  /// Without this, every incoming signal triggered a full fetchAllSignals +
  /// fetchAllAssets round-trip — a refetch storm under rapid signal delivery.
  Timer? _signalRefetchDebounce;
  static const _signalRefetchDebounceDelay = Duration(milliseconds: 1200);



  Future<void> _start(Start event, Emitter<SignalsState> emit) async {
    try {
      // 1. Мгновенная загрузка из локального Realm-кэша для мгновенного рендеринга (сигналы + ассеты)
      final localSignals = await _signalsRepository.fetchLocalSignals();
      final activeLocalSignals = localSignals.where((s) => s.status == 'active').toList();
      
      if (activeLocalSignals.isNotEmpty) {
        final uniqueSymbols = activeLocalSignals.map((s) => s.symbol).toSet().toList();
        final cachedAssetsList = await Future.wait(
          uniqueSymbols.map((sym) async {
            final local = await _assetsRepository.fetchLocalAssetsBySymbol(sym);
            return local ?? Assets.empty(sym);
          })
        );

        final cachedAssetsMap = {
          for (int i = 0; i < uniqueSymbols.length; i++) uniqueSymbols[i]: cachedAssetsList[i]
        };

        final cachedCombined = activeLocalSignals.map((signal) {
          final assets = cachedAssetsMap[signal.symbol];
          return CombinedSignal(
            signal: signal,
            assets: assets ?? Assets.empty(signal.symbol),
          );
        }).toList();

        // Эмиттим мгновенное состояние для отрисовки без задержек
        emit(state.copyWith(status: Status.loaded, signals: cachedCombined));
        _pushToWidget(cachedCombined);
      } else {
        if (state.signals.isEmpty) {
          emit(state.copyWith(status: Status.loading));
        }
      }

      // 2. Фоновый сетевой запрос для обновления до актуальных live-цен и свежих сигналов
      final signals = await _signalsRepository.fetchAllSignals(
        1,
        20,
        '',
        '',
        '',
        'active',
      );

      List<CombinedSignal> combinedSignals = [];

      if (signals.isNotEmpty) {
        // Оптимизация: загружаем все ассеты одним bulk-запросом вместо N параллельных запросов!
        List<Assets> freshAssetsList;
        try {
          freshAssetsList = await _assetsRepository.fetchAllAssets();
        } catch (e) {
          talker.error("Failed to fetch fresh assets bulk: $e");
          // Фолбэк на посимвольный кэш
          final uniqueSymbols = signals.map((s) => s.symbol).toSet().toList();
          freshAssetsList = await Future.wait(
            uniqueSymbols.map((sym) async {
              final local = await _assetsRepository.fetchLocalAssetsBySymbol(sym);
              return local ?? Assets.empty(sym);
            })
          );
        }

        final freshAssetsMap = {
          for (final asset in freshAssetsList) asset.symbol: asset
        };

        combinedSignals = signals.map((signal) {
          final assets = freshAssetsMap[signal.symbol];
          return CombinedSignal(
            signal: signal,
            assets: assets ?? Assets.empty(signal.symbol),
          );
        }).toList();
        combinedSignals = _mergeAndSort(combinedSignals);

        emit(state.copyWith(
            status: Status.loaded, signals: combinedSignals, clearError: true));
        _pushToWidget(combinedSignals);
      } else {
        // Production: show empty list, no mock signals
        if (kDebugMode) {
          combinedSignals = _getMockSignals();
        }
        emit(state.copyWith(
            status: Status.loaded, signals: combinedSignals, clearError: true));
        if (combinedSignals.isNotEmpty) _pushToWidget(combinedSignals);
      }

      // Подписываемся на веб-сокет цен
      _priceSubscription?.cancel();
      _priceSubscription = _webSocketService.priceUpdates.listen((update) {
        final symbol = update['symbol'] as String?;
        final price = update['price'];
        if (symbol != null && price != null) {
          final doublePrice = double.tryParse(price.toString()) ?? 0.0;
          add(OnWebSocketPriceUpdate(symbol: symbol, price: doublePrice));
        }
      });

      // Подписываемся на веб-сокет сигналов
      _signalSubscription?.cancel();
      _signalSubscription = _webSocketService.signalUpdates.listen((signalData) {
        add(OnWebSocketSignalUpdate(signalData: signalData));
      });

      // Закрытие сделки → мгновенно убираем из активного списка.
      _signalClosedSubscription?.cancel();
      _signalClosedSubscription =
          _webSocketService.signalClosedUpdates.listen((signalData) {
        add(OnWebSocketSignalClosed(signalData: signalData));
      });

      // Live-апдейт существующего сигнала → merge by id.
      _signalLiveUpdateSubscription?.cancel();
      _signalLiveUpdateSubscription =
          _webSocketService.signalLiveUpdates.listen((signalData) {
        add(OnWebSocketSignalLiveUpdate(signalData: signalData));
      });
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _onPriceUpdate(
    OnWebSocketPriceUpdate event,
    Emitter<SignalsState> emit,
  ) async {
    // Early-return optimization (#9): `price_update` is a GLOBAL broadcast, so we
    // get every symbol's ticks. Skip the whole list rebuild/emit when no ACTIVE
    // signal matches the symbol — no needless rebuilds, no battery drain.
    final hasMatch = state.signals.any(
      (c) => c.signal.symbol == event.symbol && !c.signal.isClosed,
    );
    if (!hasMatch) return;

    // CRITICAL (audit #2): do NOT recompute profit % on the client. The backend
    // computes profitPct off `feedEntryPrice` so live P/L starts at 0 with no
    // phantom offset; re-deriving it from `sig.price` (the TradingView coordinate)
    // produced a non-zero badge that flickered against the REST value. We update
    // ONLY the live current price (drives the slider dot); the % badge keeps the
    // server-authoritative value until the next REST refetch.
    final updatedSignals = state.signals.map((combined) {
      if (combined.signal.symbol == event.symbol && !combined.signal.isClosed) {
        final updatedSignal = combined.signal.copyWith(currentPrice: event.price);
        final updatedAsset = combined.assets.copyWith(price: event.price.toString());
        return CombinedSignal(signal: updatedSignal, assets: updatedAsset);
      }
      return combined;
    }).toList();

    emit(state.copyWith(signals: updatedSignals));
  }

  /// `signal_closed` — a trade closed server-side (TP/SL/reversal). Remove it
  /// from the ACTIVE list immediately so it stops animating/lingering (audit
  /// #1, #4). Falls back to a debounced refetch as a safety net.
  Future<void> _onSignalClosed(
    OnWebSocketSignalClosed event,
    Emitter<SignalsState> emit,
  ) async {
    final id = event.signalData['id']?.toString();
    if (id == null) return;
    final filtered =
        state.signals.where((c) => c.signal.id != id).toList();
    if (filtered.length != state.signals.length) {
      emit(state.copyWith(signals: filtered));
      _pushToWidget(filtered);
    }
  }

  /// `signal_update` — upsert-by-id of an existing signal. Merge the fresh
  /// server fields into the matching row (keeping its position); ignore if not
  /// currently held (a new signal arrives via `new_signal`).
  Future<void> _onSignalLiveUpdate(
    OnWebSocketSignalLiveUpdate event,
    Emitter<SignalsState> emit,
  ) async {
    try {
      final dto = SignalsDto.fromJson(event.signalData);
      final fresh = dto.toEntity();
      // If it just became closed, drop it from the active list.
      if (fresh.isClosed) {
        final filtered =
            state.signals.where((c) => c.signal.id != fresh.id).toList();
        if (filtered.length != state.signals.length) {
          emit(state.copyWith(signals: filtered));
          _pushToWidget(filtered);
        }
        return;
      }
      var found = false;
      final merged = state.signals.map((c) {
        if (c.signal.id == fresh.id) {
          found = true;
          return CombinedSignal(signal: fresh, assets: c.assets);
        }
        return c;
      }).toList();
      if (found) {
        emit(state.copyWith(signals: merged));
        _pushToWidget(merged);
      }
    } catch (e) {
      talker.error('[WS] Failed to parse signal_update payload: $e');
    }
  }

  Future<void> _onSignalUpdate(
    OnWebSocketSignalUpdate event,
    Emitter<SignalsState> emit,
  ) async {
    // Debounce: a burst of `new_signal` events collapses into ONE refetch once
    // the stream goes quiet for [_signalRefetchDebounceDelay]. Prevents the
    // refetch storm where each event fired a full fetchAllSignals + fetchAllAssets.
    talker.info("[WS] new_signal received — scheduling debounced REST refresh...");
    _signalRefetchDebounce?.cancel();
    _signalRefetchDebounce = Timer(_signalRefetchDebounceDelay, () {
      if (!isClosed) add(Update());
    });
  }

  Future<void> _update(Update event, Emitter<SignalsState> emit) async {
    try {
      final signals = await _signalsRepository.fetchAllSignals(
        1,
        20,
        '',
        '',
        '',
        'active',
      );

      List<CombinedSignal> combinedSignals = [];

      if (signals.isNotEmpty) {
        // Оптимизация: загружаем все ассеты одним bulk-запросом вместо N параллельных запросов!
        List<Assets> freshAssetsList;
        try {
          freshAssetsList = await _assetsRepository.fetchAllAssets();
        } catch (e) {
          talker.error("Failed to update fresh assets bulk: $e");
          final uniqueSymbols = signals.map((s) => s.symbol).toSet().toList();
          freshAssetsList = await Future.wait(
            uniqueSymbols.map((sym) async {
              final local = await _assetsRepository.fetchLocalAssetsBySymbol(sym);
              return local ?? Assets.empty(sym);
            })
          );
        }

        final freshAssetsMap = {
          for (final asset in freshAssetsList) asset.symbol: asset
        };

        combinedSignals = signals.map((signal) {
          final assets = freshAssetsMap[signal.symbol];
          return CombinedSignal(
            signal: signal,
            assets: assets ?? Assets.empty(signal.symbol),
          );
        }).toList();
        // Merge by id + stable sort (audit #3): a wholesale replace dropped the
        // freshest WS currentPrice and reordered rows on every refetch.
        combinedSignals = _mergeAndSort(combinedSignals);
      } else {
        // Production: empty list, mocks only in debug
        if (kDebugMode) {
          combinedSignals = _getMockSignals();
        }
      }
      emit(state.copyWith(signals: combinedSignals, clearError: true));
      _pushToWidget(combinedSignals);
    } catch (_) {
      // Silently ignore update errors to avoid flickering UI
    }
  }

  /// Merge a fresh server snapshot into the rows already on screen, keyed by
  /// `signal.id`, then apply a deterministic sort. This (a) preserves the most
  /// recent live `currentPrice` from WS ticks when the server snapshot lags
  /// (server sends 0/null when it has no feed at that instant), and (b) keeps a
  /// STABLE order (newest first) so rows never jump position between REST and WS
  /// updates. (audit #3)
  List<CombinedSignal> _mergeAndSort(List<CombinedSignal> fresh) {
    final prevById = {for (final c in state.signals) c.signal.id: c};
    final merged = fresh.map((c) {
      final prev = prevById[c.signal.id];
      final freshPrice = c.signal.currentPrice?.toDouble() ?? 0;
      final prevPrice = prev?.signal.currentPrice?.toDouble() ?? 0;
      // Keep the live price if the server snapshot has none but we already had one.
      if (freshPrice == 0 && prevPrice != 0) {
        return CombinedSignal(
          signal: c.signal.copyWith(currentPrice: prev!.signal.currentPrice),
          assets: c.assets,
        );
      }
      return c;
    }).toList();
    merged.sort((a, b) => b.signal.createdAt.compareTo(a.signal.createdAt));
    return merged;
  }

  List<CombinedSignal> _getMockSignals() {
    final random = Random();
    
    // Debug-only mock prices
    final mockBtcPrice = (69150.0 + (random.nextDouble() * 80 - 40)).clamp(68500.0, 71800.0);
    final mockEthPrice = (3485.0 + (random.nextDouble() * 6 - 3)).clamp(3300.0, 3680.0);

    final btcProfitPct = ((mockBtcPrice - 68420.0) / 68420.0) * 100;
    final ethProfitPct = ((3540.0 - mockEthPrice) / 3540.0) * 100;

    return [
      CombinedSignal(
        signal: Signals(
          id: 'mock-btc',
          tickerId: 'mock-btc-ticker',
          symbol: 'BTCUSDT',
          timeframe: '1h',
          direction: 'BUY',
          price: 68420.0,
          entryBarTime: DateTime.now().subtract(const Duration(hours: 2)),
          takeProfit: 72000.0,
          stopLoss: 66500.0,
          prevMove: 1.5,
          stochK: 75.0,
          stochD: 72.0,
          macd: 250.0,
          macdSignal: 220.0,
          macdHistogram: 30.0,
          ema50: 68100.0,
          ema200: 67200.0,
          atr: 450.0,
          volume: 15200.0,
          volumeSma: 14800.0,
          pivotHigh: 69500.0,
          pivotLow: 66200.0,
          status: 'active',
          closePrice: 0.0,
          closeReason: '',
          closedAt: DateTime.fromMillisecondsSinceEpoch(0),
          profitLoss: mockBtcPrice - 68420.0,
          profitLossPct: btcProfitPct,
          webhookPayload: '',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now(),
          currentPrice: mockBtcPrice,
          progressPct: 20.8,
          profitPct: btcProfitPct,
          profitUsd: mockBtcPrice - 68420.0,
          signalStatus: 'in_profit',
          indicators: null,
          ticker: null,
        ),
        assets: Assets(
          symbol: 'BTCUSDT',
          name: 'Bitcoin',
          baseAsset: 'BTC',
          quoteAsset: 'USDT',
          price: mockBtcPrice.toStringAsFixed(2),
          change24h: '2.45',
          logoUrl: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
          volume24h: '28000000000',
          high24h: '69800',
          low24h: '67500',
          priceChangePercent: '2.45',
        ),
      ),
      CombinedSignal(
        signal: Signals(
          id: 'mock-eth',
          tickerId: 'mock-eth-ticker',
          symbol: 'ETHUSDT',
          timeframe: '15m',
          direction: 'SELL',
          price: 3540.0,
          entryBarTime: DateTime.now().subtract(const Duration(minutes: 45)),
          takeProfit: 3200.0,
          stopLoss: 3700.0,
          prevMove: -2.1,
          stochK: 22.0,
          stochD: 25.0,
          macd: -15.0,
          macdSignal: -12.0,
          macdHistogram: -3.0,
          ema50: 3550.0,
          ema200: 3580.0,
          atr: 25.0,
          volume: 45000.0,
          volumeSma: 42000.0,
          pivotHigh: 3620.0,
          pivotLow: 3450.0,
          status: 'active',
          closePrice: 0.0,
          closeReason: '',
          closedAt: DateTime.fromMillisecondsSinceEpoch(0),
          profitLoss: 3540.0 - mockEthPrice,
          profitLossPct: ethProfitPct,
          webhookPayload: '',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          updatedAt: DateTime.now(),
          currentPrice: mockEthPrice,
          progressPct: 15.5,
          profitPct: ethProfitPct,
          profitUsd: 3540.0 - mockEthPrice,
          signalStatus: 'in_profit',
          indicators: null,
          ticker: null,
        ),
        assets: Assets(
          symbol: 'ETHUSDT',
          name: 'Ethereum',
          baseAsset: 'ETH',
          quoteAsset: 'USDT',
          price: mockEthPrice.toStringAsFixed(2),
          change24h: '-1.85',
          logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
          volume24h: '15000000000',
          high24h: '3610',
          low24h: '3450',
          priceChangePercent: '-1.85',
        ),
      ),
    ];
  }

  /// Publish the freshest signal + real recent-history into the iOS widget.
  void _pushToWidget(List<CombinedSignal> combined) {
    if (combined.isEmpty) return;
    final latest = combined.first.signal;
    WidgetService.pushSignal(
      symbol: latest.symbol,
      direction: latest.direction,
      entry: latest.price.toDouble(),
      price: (latest.currentPrice ?? latest.price).toDouble(),
      tp: (latest.takeProfit ?? 0).toDouble(),
      sl: (latest.stopLoss ?? 0).toDouble(),
    );
    // Overwrite the recent list with the real backend history, so the widget
    // shows actual past signals instead of just what we've accumulated.
    WidgetService.pushRecentSignals(
      combined.map((c) => (
            symbol: c.signal.symbol,
            direction: c.signal.direction,
            price: (c.signal.currentPrice ?? c.signal.price).toDouble(),
            ts: c.signal.createdAt,
          )).toList(),
    );
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    _signalSubscription?.cancel();
    _signalClosedSubscription?.cancel();
    _signalLiveUpdateSubscription?.cancel();
    _invalidationSubscription?.cancel();
    _signalRefetchDebounce?.cancel();
    return super.close();
  }
}

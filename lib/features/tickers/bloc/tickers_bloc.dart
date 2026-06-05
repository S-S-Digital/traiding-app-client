import 'dart:async';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart' hide Tickers;
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:aspiro_trade/services/websocket_service.dart';
import 'package:aspiro_trade/services/cache_invalidation_bus.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tickers_event.dart';
part 'tickers_state.dart';

class TickersBloc extends Bloc<TickersEvent, TickersState> {
  TickersBloc({
    required TickersRepositoryI tickersRepository,
    required AssetsRepositoryI assetsRepository,
    required SignalsRepositoryI signalsRepository,
    required WebSocketService webSocketService,
  }) : _tickersRepository = tickersRepository,
       _assetsRepository = assetsRepository,
       _signalsRepository = signalsRepository,
       _webSocketService = webSocketService,
       super(const TickersState()) {
    on<Start>(_onStart);
    on<Refresh>(_onRefresh);
    on<DeleteTicker>(_onDeleteTicker);
    on<UpdateAsset>(_onUpdateAsset);
    on<UpdatePrice>(_onUpdatePrice);
    on<StopTimer>(_onStopPolling);

    // Premium/subscription change → refetch tickers + their gated signals so the
    // watchlist reflects the user's current entitlement.
    _invalidationSubscription =
        CacheInvalidationBus.instance.onInvalidateMarketData.listen((_) {
      add(Refresh());
    });
  }

  final TickersRepositoryI _tickersRepository;
  final AssetsRepositoryI _assetsRepository;
  final SignalsRepositoryI _signalsRepository;
  final WebSocketService _webSocketService;

  StreamSubscription? _priceSubscription;
  // Legacy подписка для обратной совместимости
  StreamSubscription<List<Assets>>? _assetsSubscription;
  StreamSubscription? _invalidationSubscription;

  Future<void> _onStart(Start event, Emitter<TickersState> emit) async {
    try {
      // Показываем кэш из Realm мгновенно, пока грузится сеть
      if (state.tickers.isEmpty) {
        final localTickers = await _tickersRepository.fetchAllLocalTickers();
        if (localTickers.isNotEmpty) {
          final cachedCombined = await Future.wait(
            localTickers.map((t) async {
              final localAsset = await _assetsRepository.fetchLocalAssetsBySymbol(t.symbol);
              return CombinedTicker(
                assets: localAsset ?? Assets.empty(t.symbol),
                tickers: t,
              );
            }),
          );
          emit(state.copyWith(tickers: cachedCombined, status: Status.loading));
        } else {
          emit(state.copyWith(status: Status.loading));
        }
      } else {
        // Уже есть данные — не показываем спиннер, просто обновляем в фоне
      }

      // Делаем три bulk-запроса параллельно в сети за один проход!
      final results = await Future.wait([
        _tickersRepository.fetchAllTickers(),
        _assetsRepository.fetchAllAssets(),
        _signalsRepository.fetchAllSignals(1, 100, '', '', '', 'active'),
      ]);

      final List<Tickers> tickers = (results[0] as List).cast<Tickers>();
      final List<Assets> assetsList = (results[1] as List).cast<Assets>();
      final List<Signals> signalsList = (results[2] as List).cast<Signals>();

      final assetsMap = {for (final asset in assetsList) asset.symbol: asset};

      // Группируем сигналы по tickerId для O(1) поиска
      final signalsMap = <String, List<Signals>>{};
      for (final sig in signalsList) {
        if (sig.tickerId != null) {
          signalsMap.putIfAbsent(sig.tickerId!, () => []).add(sig);
        }
      }

      final combinedTickers = tickers.map((Tickers t) {
        final asset = assetsMap[t.symbol] ?? Assets.empty(t.symbol);
        final tickerSignals = signalsMap[t.id] ?? [];
        return CombinedTicker(
          assets: asset,
          tickers: t,
          signals: tickerSignals.isEmpty ? null : tickerSignals.first,
        );
      }).toList();

      emit(state.copyWith(tickers: combinedTickers, status: Status.loaded));

      // Подписываемся на WebSocket обновления цен (вместо HTTP polling)
      _startPriceSubscription();
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  /// Подписка на WebSocket-поток обновления цен
  void _startPriceSubscription() {
    _priceSubscription?.cancel();
    _priceSubscription = _webSocketService.priceUpdates.listen((update) {
      final symbol = update['symbol'] as String?;
      final price = update['price'];
      if (symbol != null && price != null) {
        add(UpdatePrice(symbol: symbol, price: price.toString()));
      }
    });
  }

  /// Обработка новых данных из стрима
  Future<void> _onUpdateAsset(
    UpdateAsset event,
    Emitter<TickersState> emit,
  ) async {
    final currentTickers = state.tickers;

    final updatedList = currentTickers.map((ticker) {
      // Ищем обновленный актив в списке пришедшем из события
      final matchingAsset = event.newAssets.firstWhere(
        (a) => a.symbol == ticker.tickers.symbol,
        orElse: () => ticker.assets,
      );

      return ticker.copyWith(assets: matchingAsset);
    }).toList();

    // Эмиттим состояние только если данные реально изменились
    // (благодаря Equatable в CombinedTicker)
    if (updatedList != state.tickers) {
      emit(state.copyWith(tickers: updatedList));
    }
  }

  /// Обновление цены одного тикера через WebSocket
  Future<void> _onUpdatePrice(
    UpdatePrice event,
    Emitter<TickersState> emit,
  ) async {
    final currentTickers = state.tickers;
    // Проверяем, есть ли тикер с таким символом
    final hasSymbol = currentTickers.any((t) => t.tickers.symbol == event.symbol);
    if (!hasSymbol) return;

    final updatedList = currentTickers.map((ticker) {
      if (ticker.tickers.symbol == event.symbol) {
        return ticker.copyWith(
          assets: ticker.assets.copyWith(price: event.price),
        );
      }
      return ticker;
    }).toList();

    if (updatedList != state.tickers) {
      emit(state.copyWith(tickers: updatedList));
    }
  }

  Future<void> _onDeleteTicker(
    DeleteTicker event,
    Emitter<TickersState> emit,
  ) async {
    try {
      await _tickersRepository.deleteTicker(event.id);

      final updatedTickers = state.tickers
          .where((t) => t.tickers.id != event.id)
          .toList();

      emit(state.copyWith(tickers: updatedTickers));
      // WebSocket подписка обновится автоматически — она глобальная
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _onRefresh(Refresh event, Emitter<TickersState> emit) async {
    _priceSubscription?.cancel();
    _assetsSubscription?.cancel();
    await _onStart(Start(), emit);
  }

  void _onStopPolling(StopTimer event, Emitter<TickersState> emit) {
    _priceSubscription?.cancel();
    _assetsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    _assetsSubscription?.cancel();
    _invalidationSubscription?.cancel();
    return super.close();
  }
}

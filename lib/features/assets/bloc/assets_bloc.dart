import 'dart:async';

import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/services/widget_service.dart';
import 'package:aspiro_trade/services/websocket_service.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'assets_event.dart';
part 'assets_state.dart';

class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  AssetsBloc({
    required AssetsRepositoryI assetsRepository,
    required WebSocketService webSocketService,
  })  : _assetsRepository = assetsRepository,
        _webSocketService = webSocketService,
        super(const AssetsState()) {
    on<Start>(_start);
    on<SearchAsset>(_search);
    on<UpdateAsset>(_updateAsset);
    on<UpdatePrice>(_updatePrice);
    on<StopTimer>((event, emit) {
      _priceSubscription?.cancel();
    });
  }

  final AssetsRepositoryI _assetsRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _priceSubscription;

  Future<void> _start(Start event, Emitter<AssetsState> emit) async {
    try {
      if (state.assets.isEmpty) {
        emit(state.copyWith(status: Status.loading));
      }
      // Non-crypto is disabled backend-side (TradingView removed) → hide it so
      // users don't watch tickers that produce no signals (Task #5).
      final popularAssets = (await _assetsRepository.fetchPopularAssets())
          .where((a) => isCryptoSymbol(a.symbol))
          .toList();

      emit(state.copyWith(status: Status.loaded, assets: popularAssets));
      _pushWatchlistToWidget(popularAssets);

      _priceSubscription?.cancel();
      _priceSubscription = _webSocketService.priceUpdates.listen((update) {
        final symbol = update['symbol'] as String?;
        final price = update['price'];
        if (symbol != null && price != null) {
          add(UpdatePrice(symbol: symbol, price: price.toString()));
        }
      });
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _updatePrice(
    UpdatePrice event,
    Emitter<AssetsState> emit,
  ) async {
    final updatedAssets = state.assets.map((asset) {
      if (asset.symbol == event.symbol) {
        return asset.copyWith(price: event.price);
      }
      return asset;
    }).toList();

    emit(state.copyWith(assets: updatedAssets));
  }

  Future<void> _updateAsset(
    UpdateAsset event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      // Запрашиваем весь список популярных активов одним быстрым пакетным запросом
      final updatedAssets = (await _assetsRepository.fetchPopularAssets())
          .where((a) => isCryptoSymbol(a.symbol))
          .toList();

      emit(state.copyWith(assets: updatedAssets));
      _pushWatchlistToWidget(updatedAssets);
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  // Priority order for the home-widget watchlist. Anything not listed keeps
  // its original relative order after the priority block.
  static const _widgetPriority = [
    'BTCUSDT',
    'ETHUSDT',
    'SOLUSDT',
    'BNBUSDT',
    'XRPUSDT',
    'ADAUSDT',
    'DOGEUSDT',
  ];

  void _pushWatchlistToWidget(List<Assets> assets) {
    if (assets.isEmpty) return;
    final sorted = [...assets]..sort((a, b) {
        final ia = _widgetPriority.indexOf(a.symbol);
        final ib = _widgetPriority.indexOf(b.symbol);
        if (ia == -1 && ib == -1) return 0;
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia - ib;
      });
    final items = sorted.take(6).map((a) {
      final price = double.tryParse(a.price) ?? 0;
      final change = double.tryParse(a.priceChangePercent) ?? 0;
      return (symbol: a.symbol, price: price, change24h: change);
    }).toList();
    WidgetService.pushWatchlist(items);
  }

  Future<void> _search(SearchAsset event, Emitter<AssetsState> emit) async {
    try {
      emit(state.copyWith(status: Status.loading));

      final assets = (await _assetsRepository.searchAssets(event.symbol))
          .where((a) => isCryptoSymbol(a.symbol))
          .toList();

      emit(state.copyWith(status: Status.loaded, assets: assets));
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/services/websocket_service.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'asset_details_event.dart';
part 'asset_details_state.dart';

class AssetDetailsBloc extends Bloc<AssetDetailsEvent, AssetDetailsState> {
  AssetDetailsBloc({
    required AssetsRepositoryI assetsRepository,
    required WebSocketService webSocketService,
  })  : _assetsRepository = assetsRepository,
        _webSocketService = webSocketService,
        super(AssetDetailsState(assets: Assets.empty())) {
    on<Start>(_start);
    on<SelectTimeframe>(_setTimeframe);
    on<UpdateAsset>(_updateAsset);
    on<UpdatePrice>(_updatePrice);
    on<StopTimer>((event, emit) {
      _priceSubscription?.cancel();
    });
  }
  final AssetsRepositoryI _assetsRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _priceSubscription;

  Future<void> _start(Start event, Emitter<AssetDetailsState> emit) async {
    emit(state.copyWith(status: Status.loading));
    try {
      // Параллельные запросы
      final results = await Future.wait([
        _assetsRepository.fetchAssetsBySymbol(event.symbol),
        _assetsRepository.fetchCandlesForSymbol(event.symbol, '500', '1h'),
      ]);

      final assets = results[0] as Assets;

      final candles = results[1] as List<Candles>;

      emit(
        state.copyWith(candles: candles, assets: assets, status: Status.loaded),
      );

      _priceSubscription?.cancel();
      _priceSubscription = _webSocketService.priceUpdates
          .where((update) => update['symbol'] == event.symbol)
          .listen((update) {
        final price = update['price'];
        if (price != null) {
          add(UpdatePrice(price: price.toString()));
        }
      });
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _updatePrice(
    UpdatePrice event,
    Emitter<AssetDetailsState> emit,
  ) async {
    emit(state.copyWith(
      assets: state.assets.copyWith(price: event.price),
    ));
  }

  Future<void> _updateAsset(
    UpdateAsset event,
    Emitter<AssetDetailsState> emit,
  ) async {
    try {
      final newAsset = await _assetsRepository.fetchAssetsBySymbol(
        state.assets.symbol,
      );

      emit(state.copyWith(assets: newAsset));
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _setTimeframe(
    SelectTimeframe event,
    Emitter<AssetDetailsState> emit,
  ) async {
    try {
      final candles = await _assetsRepository.fetchCandlesForSymbol(
        event.symbol,
        '500',
        event.timeframe.value,
      );

      emit(
        state.copyWith(candles: candles, selectedTimeframe: event.timeframe),
      );
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

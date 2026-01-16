import 'dart:async';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'asset_details_event.dart';
part 'asset_details_state.dart';

class AssetDetailsBloc extends Bloc<AssetDetailsEvent, AssetDetailsState> {
  AssetDetailsBloc({required AssetsRepositoryI assetsRepository})
    : _assetsRepository = assetsRepository,

      super(AssetDetailsInitial()) {
    on<Start>(_start);
    on<SelectTimeframe>(_setTimeframe);
    on<UpdateAsset>(_updateAsset);
    on<StopTimer>((event, emit) {
      timer?.cancel();
      
    });
  }
  Timer? timer;
  final AssetsRepositoryI _assetsRepository;

  Future<void> _start(Start event, Emitter<AssetDetailsState> emit) async {
    emit(AssetDetailsLoading());
    try {
      // Параллельные запросы
      final results = await Future.wait([
        _assetsRepository.fetchAssetsBySymbol(event.symbol),
        _assetsRepository.fetchCandlesForSymbol(event.symbol, '500', '1h'),
      ]);

      final assets = results[0] as Assets;
      

      // talker.debug(assets.toString());
      final candles = results[1] as List<Candles>;
      // talker.debug(event.symbol);

      // talker.debug(assets.price);

      emit(AssetDetailsLoaded(candles: candles, assets: assets));

      // Запускаем таймер для обновления
      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 10), (_) {
          add(UpdateAsset());
        });
      }
    } on AppException catch (error) {
      emit(AssetDetailsFailure(error: error));
    }
  }

  Future<void> _updateAsset(
    UpdateAsset event,
    Emitter<AssetDetailsState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is AssetDetailsLoaded) {
        final newAsset = await _assetsRepository.fetchAssetsBySymbol(
          currentState.assets.symbol,
        );

        emit(currentState.copyWith(assets: newAsset));
      }
    } on AppException catch (error) {
      emit(AssetDetailsFailure(error: error));
    }
  }

  Future<void> _setTimeframe(
    SelectTimeframe event,
    Emitter<AssetDetailsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AssetDetailsLoaded) {
        final candles = await _assetsRepository.fetchCandlesForSymbol(
          event.symbol,
          '500',
          event.timeframe.value,
        );

        emit(
          currentState.copyWith(
            candles: candles,
            selectedTimeframe: event.timeframe,
          ),
        );
      }
    } on AppException catch (error) {
      emit(AssetDetailsFailure(error: error));
    }
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}

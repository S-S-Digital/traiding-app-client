import 'dart:async';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'asset_details_event.dart';
part 'asset_details_state.dart';

class AssetDetailsBloc extends Bloc<AssetDetailsEvent, AssetDetailsState> {
  AssetDetailsBloc({required AssetsRepositoryI assetsRepository})
    : _assetsRepository = assetsRepository,

      super(AssetDetailsState(assets: Assets.empty())) {
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

      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 10), (_) {
          add(UpdateAsset());
        });
      }
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
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
    timer?.cancel();
    return super.close();
  }
}

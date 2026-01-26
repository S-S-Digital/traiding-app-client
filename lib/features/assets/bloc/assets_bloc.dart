import 'dart:async';

import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'assets_event.dart';
part 'assets_state.dart';

class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  AssetsBloc({required AssetsRepositoryI assetsRepository})
    : _assetsRepository = assetsRepository,
      super(const AssetsState()) {
    on<Start>(_start);
    on<SearchAsset>(_search);
    on<UpdateAsset>(_updateAsset);
    on<StopTimer>((event, emit) {
      timer?.cancel();
    });
  }
  final AssetsRepositoryI _assetsRepository;
  Timer? timer;

  Future<void> _start(Start event, Emitter<AssetsState> emit) async {
    try {
      emit(state.copyWith(status: Status.loading));
      final popularAssets = await _assetsRepository.fetchPopularAssets();

      emit(state.copyWith(status: Status.loaded, assets: popularAssets));
      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 20), (_) {
          add(UpdateAsset());
        });
      }
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _updateAsset(
    UpdateAsset event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      // Асинхронно обновляем все assets
      final updatedAssets = await Future.wait(
        state.assets.map((asset) async {
          final newAsset = await _assetsRepository.fetchAssetsBySymbol(
            asset.symbol,
          );

          return asset.copyWith(
            symbol: newAsset.symbol,
            name: newAsset.name,
            baseAsset: newAsset.baseAsset,
            quoteAsset: newAsset.quoteAsset,
            price: newAsset.price,
            change24h: newAsset.change24h,
            logoUrl: newAsset.logoUrl,
            volume24h: newAsset.volume24h,
            high24h: newAsset.high24h,
            low24h: newAsset.low24h,
            priceChangePercent: newAsset.priceChangePercent,
          );
        }),
      );

      emit(state.copyWith(assets: updatedAssets));
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _search(SearchAsset event, Emitter<AssetsState> emit) async {
    try {
      emit(state.copyWith(status: Status.loading));

      final assets = await _assetsRepository.searchAssets(event.symbol);

      emit(state.copyWith(status: Status.loaded, assets: assets));
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

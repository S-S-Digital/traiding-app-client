import 'package:aspiro_trade/main.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'asset_details_event.dart';
part 'asset_details_state.dart';

class AssetDetailsBloc extends Bloc<AssetDetailsEvent, AssetDetailsState> {
  AssetDetailsBloc({
    required AssetsRepositoryI assetsRepository,
    required TickersRepositoryI tickersRepository,
  }) : _assetsRepository = assetsRepository,
        _tickersRepository = tickersRepository,
       super(AssetDetailsInitial()) {
        on<Start>(_start);
        on<SelectTimeframe>(_setTimeframe);
       }

  final AssetsRepositoryI _assetsRepository;
  final TickersRepositoryI _tickersRepository;


  Future<void> _start(Start event, Emitter<AssetDetailsState> emit)async{
    emit(AssetDetailsLoading());
    try{
      final candles = await _assetsRepository.fetchCandlesForSymbol(event.symbol, '500', '1m');
      emit(AssetDetailsLoaded(candles: candles));
    }
    on AppException catch(error){
      emit(AssetDetailsFailure(error: error));
    }
  }

  Future<void> _setTimeframe(SelectTimeframe event, Emitter<AssetDetailsState> emit)async{
    try{
      emit(AssetDetailsLoading());
      talker.info(event.timeframe.title);
      final candles = await _assetsRepository.fetchCandlesForSymbol(event.symbol, '500', event.timeframe.value);
      emit(AssetDetailsLoaded(candles: candles, selectedTimeframe: event.timeframe));
    }
    on AppException catch(error){
      emit(AssetDetailsFailure(error: error));
    }
    
  }


}

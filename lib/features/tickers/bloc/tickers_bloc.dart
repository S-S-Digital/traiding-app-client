import 'dart:async';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tickers_event.dart';
part 'tickers_state.dart';

class TickersBloc extends Bloc<TickersEvent, TickersState> {
  TickersBloc({
    required TickersRepositoryI tickersRepository,
    required AssetsRepositoryI assetsRepository,
    required SignalsRepositoryI signalsRepository
  }) : _tickersRepository = tickersRepository,
       _assetsRepository = assetsRepository,
       _signalsRepository = signalsRepository,
      
       super(TickersInitial()) {
    on<Start>(_start);
    on<DeleteTicker>(_deleteTicker);
    on<Refresh>(_refresh);
    on<UpdateAsset>(_updateAsset);
    on<StopTimer>((event, emit) {
      timer?.cancel();
    });
  }
  Timer? timer;

  final TickersRepositoryI _tickersRepository;
  final AssetsRepositoryI _assetsRepository;
  final SignalsRepositoryI _signalsRepository; 

  Future<void> _start(Start event, Emitter<TickersState> emit) async {
    try {
      emit(TickersLoading());
      

      List<CombinedTicker> combinedTicker = [];

      var tickers = await _tickersRepository.fetchAllTickers();

      

      for (final i in tickers) {
        
        final asset = await _assetsRepository.fetchAssetsBySymbol(i.symbol);
        final signal = await _signalsRepository.fetchSignalsByTickerId(i.id, 1, 20, i.symbol, i.timeframe, '', '');
        

        combinedTicker.add(
          CombinedTicker(assets: asset, tickers: i, signals: signal.isEmpty? null: signal.first ),
        );
      }

      emit(TickersLoaded(tickers: combinedTicker));
      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 15), (_) {
          add(UpdateAsset());
        });
      }
    } on AppException catch (error) {
      talker.error(error);
      emit(TickersFailure(error: error));
    } catch (error) {
      talker.debug(error.toString());
      emit(TickersFailure(error: error));
    }
  }

  Future<void> _updateAsset(
    UpdateAsset event,
    Emitter<TickersState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is TickersLoaded) {
      
        final updatedTickers = await Future.wait(
          currentState.tickers.map((t) async {
            final newAsset = await _assetsRepository.fetchAssetsBySymbol(
              t.assets.symbol,
            );

            return t.copyWith(assets: newAsset);
          }),
        );

        emit(currentState.copyWith(tickers: updatedTickers));
      }
    } on AppException catch (error) {
      emit(TickersFailure(error: error));
    }
  }

  Future<void> _deleteTicker(
    DeleteTicker event,
    Emitter<TickersState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is TickersLoaded) {
        await _tickersRepository.deleteTicker(event.id);

        // создаём новый список, чтобы не мутировать старый
        final updatedTickers = List.of(currentState.tickers);

        updatedTickers.removeWhere((ticker) => ticker.tickers.id == event.id);

        emit(currentState.copyWith(tickers: updatedTickers));
      }
    } on AppException catch (error) {
      emit(TickersFailure(error: error));
    }
  }

  Future<void> _refresh(Refresh event, Emitter<TickersState> emit) async {
    try {
      emit(TickersLoading());
      List<CombinedTicker> combinedTicker = [];

      var tickers = await _tickersRepository.fetchAllTickers();
      for (final i in tickers) {
        final asset = await _assetsRepository.fetchAssetsBySymbol(i.symbol);
        
        combinedTicker.add(
          CombinedTicker(assets: asset, tickers: i),
        );
      }

      emit(TickersLoaded(tickers: combinedTicker));
    } on AppException catch (error) {
      talker.error(error);
      emit(TickersFailure(error: error));
    }
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}

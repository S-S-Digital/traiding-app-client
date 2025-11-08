import 'package:aspiro_trade/features/tickers/models/combined_ticker.dart';
import 'package:aspiro_trade/main.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tickers_event.dart';
part 'tickers_state.dart';

class TickersBloc extends Bloc<TickersEvent, TickersState> {
  TickersBloc({
    required TickersRepositoryI tickersRepository,
    required AssetsRepositoryI assetsRepository,
    required AuthRepositoryI authRepository
  }) : _tickersRepository = tickersRepository,
       _assetsRepository = assetsRepository,
       _authRepository = authRepository,
       super(TickersInitial()) {
    on<Start>(_start);
  }

  final TickersRepositoryI _tickersRepository;
  final AssetsRepositoryI _assetsRepository;
  final AuthRepositoryI _authRepository;

  Future<void> _start(Start event, Emitter<TickersState> emit) async {
    try {
      emit(TickersLoading());
      List<CombinedTicker> combinedTicker = [];
      await _authRepository.refresh();
      var tickers = await _tickersRepository.fetchAllTickers();

      for (var i in tickers) {
        // await _tickersRepository.deleteTicker(i.id);
        final asset = await _assetsRepository.searchAssets(i.symbol);
        final candle = await _assetsRepository.fetchCandlesForSymbol(
          i.symbol,
          '500',
          '1h',
        );
        combinedTicker.add(
          CombinedTicker(assets: asset.first, candles: candle, tickers: i),
        );
      }

      emit(TickersLoaded(tickers: combinedTicker));
    } on AppException catch (error) {
      talker.error(error);
      emit(TickersFailure(error: error));
    }
  }
}

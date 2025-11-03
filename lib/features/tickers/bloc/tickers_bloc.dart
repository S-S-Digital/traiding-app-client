import 'package:aspiro_trade/main.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/assets/assets_repository.dart';
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
  }) : _tickersRepository = tickersRepository,
       _assetsRepository = assetsRepository,
       super(TickersInitial()) {
    on<Start>(_start);
  }

  final TickersRepositoryI _tickersRepository;
  final AssetsRepositoryI _assetsRepository;

  Future<void> _start(Start event, Emitter<TickersState> emit) async {
    try {
      final tickers = await _tickersRepository.fetchAllTickers();
      emit(TickersLoaded(tickers: tickers));
    } on AppException catch (error) {
      talker.error(error);
      emit(TickersFailure(error: error));
    }
  }

 
}

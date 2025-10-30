import 'package:aspiro_trade/main.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tickers_event.dart';
part 'tickers_state.dart';

class TickersBloc extends Bloc<TickersEvent, TickersState> {
  TickersBloc({required TickersRepositoryI tickersRepository})
    : _tickersRepository = tickersRepository,
      super(TickersInitial()) {
    on<Start>(_start);
  }

  final TickersRepositoryI _tickersRepository;

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

import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/exceptions/exceptions.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_tickers_event.dart';
part 'add_tickers_state.dart';

class AddTickersBloc extends Bloc<AddTickersEvent, AddTickersState> {
  AddTickersBloc({
    required AssetsRepositoryI assetsRepository,
    required TickersRepositoryI tickersRepository,
  }) : _assetsRepository = assetsRepository,
       _tickersRepository = tickersRepository,
       super(AddTickersInitial()) {
    on<Start>(_start);
    on<SelectOption>((event, emit) {
      final currentState = state;
      if (currentState is AddTickersLoaded) {
        emit(currentState.copyWith(selectedOption: event.option));
      }
    });
    on<SelectTimeframe>((event, emit) {
      final currentState = state;
      if (currentState is AddTickersLoaded) {
        emit(currentState.copyWith(selectedTimeframe: event.timeframe));
      }
    });
  }

  final AssetsRepositoryI _assetsRepository;
  final TickersRepositoryI _tickersRepository;

  Future<void> _start(Start event, Emitter<AddTickersState> emit) async {
    try {
      emit(AddTickersLoading());

      await Future.delayed(Duration(milliseconds: 200));

      final validate = await _assetsRepository.validateSymbol(event.symbol);

      emit(AddTickersLoaded(isValid: validate.isValid));
    } on AppException catch (error) {
      emit(AddTickersFailure(error: error));
    } catch (error) {
      emit(AddTickersFailure(error: error));
    }
  }
}

import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_tickers_event.dart';
part 'add_tickers_state.dart';

class AddTickersBloc extends Bloc<AddTickersEvent, AddTickersState> {
  AddTickersBloc({
    required AssetsRepositoryI assetsRepository,
    required TickersRepositoryI tickersRepository,
    required NotificationsRepositoryI notificationsRepository,
  }) : _assetsRepository = assetsRepository,
       _tickersRepository = tickersRepository,
       _notificationsRepository = notificationsRepository,
       super(AddTickersInitial()) {
    on<Start>(_start);
    on<AddNewTicker>(_addNewTicker);
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
  final NotificationsRepositoryI _notificationsRepository;

  Future<void> _start(Start event, Emitter<AddTickersState> emit) async {
    try {
      emit(AddTickersLoading());

      

      final validate = await _assetsRepository.validateSymbol(event.symbol);

      emit(AddTickersLoaded(isValid: validate.isValid));
    } catch (error) {
      emit(AddTickersFailure(error: error));
    }
  }

  Future<void> _addNewTicker(
    AddNewTicker event,
    Emitter<AddTickersState> emit,
  ) async {
    try {
      emit(AddTickersLoading());
     await _tickersRepository.addNewTicker(
        AddTicker(
          symbol: event.symbol,
          timeframe: event.timeframe,
          notifyBuy: event.notifyBuy,
          notifySell: event.notifySell,
        ),
      );

      await _notificationsRepository.showLocalNotification(Notification(title: 'Тикер добавлен', message: 'Тикер ${event.symbol} успешно добавлен в наблюдение.'));
      

      emit(Close());
    }
    catch (error) {
      emit(AddTickersFailure(error: error));
    }
  }
}

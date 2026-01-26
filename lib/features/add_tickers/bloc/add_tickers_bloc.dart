import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:aspiro_trade/utils/utils.dart';

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
       super(const AddTickersState()) {
    on<Start>(_start);
    on<AddNewTicker>(_addNewTicker);
    on<SelectOption>((event, emit) {
      emit(state.copyWith(selectedOption: event.option));
    });
    on<SelectTimeframe>((event, emit) {
      emit(state.copyWith(selectedTimeframe: event.timeframe));
    });
  }

  final AssetsRepositoryI _assetsRepository;
  final TickersRepositoryI _tickersRepository;
  final NotificationsRepositoryI _notificationsRepository;

  Future<void> _start(Start event, Emitter<AddTickersState> emit) async {
    try {
      emit(state.copyWith(status: Status.loading));

      final validate = await _assetsRepository.validateSymbol(event.symbol);

      emit(
        state.copyWith(
          status: validate.isValid ? Status.submit : Status.loaded,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _addNewTicker(
    AddNewTicker event,
    Emitter<AddTickersState> emit,
  ) async {
    try {
      emit(state.copyWith(status: Status.loading));
      await _tickersRepository.addNewTicker(
        AddTicker(
          symbol: event.symbol,
          timeframe: event.timeframe,
          notifyBuy: event.notifyBuy,
          notifySell: event.notifySell,
        ),
      );

      await _notificationsRepository.showLocalNotification(
        Notification(
          title: 'Тикер добавлен',
          message: 'Тикер ${event.symbol} успешно добавлен в наблюдение.',
        ),
      );

      emit(state.copyWith(status: Status.success));
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }
}

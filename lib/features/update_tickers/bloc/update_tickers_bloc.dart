import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'update_tickers_event.dart';
part 'update_tickers_state.dart';

class UpdateTickersBloc extends Bloc<UpdateTickersEvent, UpdateTickersState> {
  UpdateTickersBloc({
    required AssetsRepositoryI assetsRepository,
    required TickersRepositoryI tickersRepository,
  }) : _assetsRepository = assetsRepository,
       _tickersRepository = tickersRepository,
       super(UpdateTickersInitial()) {
    on<Start>(_start);
    on<UpdateTicker>(_update);
    on<SelectOption>((event, emit) {
      final currentState = state;
      if (currentState is UpdateTickersLoaded) {
        emit(currentState.copyWith(selectedOption: event.option));
      }
    });
    on<SelectTimeframe>((event, emit) {
      final currentState = state;
      if (currentState is UpdateTickersLoaded) {
        emit(currentState.copyWith(selectedTimeframe: event.timeframe));
      }
    });
  }

  final AssetsRepositoryI _assetsRepository;
  final TickersRepositoryI _tickersRepository;
  final List<Options> options = [
    Options(
      title: 'Покупка и продажа',
      subtitle: 'уведомления о всех типах сигналов',
      notifyBuy: true,
      notifySell: true,
    ),
    Options(
      title: 'Только покупка',
      subtitle: 'Уведомления только о сигналах покупки',
      notifyBuy: true,
      notifySell: false,
    ),
    Options(
      title: 'Только продажа',
      subtitle: 'Уведомления только о сигналах продажи',
      notifyBuy: false,
      notifySell: true,
    ),
  ];
  final List<Timeframes> timeframeOptions = [
    Timeframes(title: '15 минут', value: '15m'),
    Timeframes(title: '1 час', value: '1h'),
    Timeframes(title: '1 день', value: '1d'),
    Timeframes(title: '1 неделя', value: '1w'),
    Timeframes(title: '1 месяц', value: '1M'),
  ];

  Options _getOption(bool notifyBuy, bool notifySell) {
    return options.firstWhere(
      (o) => o.notifyBuy == notifyBuy && o.notifySell == notifySell,
      orElse: () => options[0], // fallback на "Покупка и продажа"
    );
  }

  Timeframes _getTimeframe(String value) {
    return timeframeOptions.firstWhere(
      (t) => t.value == value,
      orElse: () => timeframeOptions[0], // fallback на первый элемент
    );
  }

  Future<void> _start(Start event, Emitter<UpdateTickersState> emit) async {
    emit(UpdateTickersLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final validate = await _assetsRepository.validateSymbol(
        event.tickers.tickers.symbol,
      );

      final option = _getOption(
        event.tickers.tickers.notifyBuy,
        event.tickers.tickers.notifySell,
      );

      final selectedTimeframe = _getTimeframe(event.tickers.tickers.timeframe);

      emit(
        UpdateTickersLoaded(
          isValid: validate.isValid,
          selectedOption: option,
          selectedTimeframe: selectedTimeframe,
          timeframes: timeframeOptions,
          options: options,
        ),
      );
    } on AppException catch (error) {
      emit(UpdateTickersFailure(error: error));
    } catch (error) {
      emit(UpdateTickersFailure(error: error));
    }
  }

  Future<void> _update(
    UpdateTicker event,
    Emitter<UpdateTickersState> emit,
  ) async {
    try {
      await _tickersRepository.updateTickerSignals(
        event.id,
        AddTicker(
          symbol: event.symbol,
          timeframe: event.timeframe,
          notifyBuy: event.notifyBuy,
          notifySell: event.notifySell,
        ),
      );
      emit(Close());
    } on AppException catch (error) {
      emit(UpdateTickersFailure(error: error));
    } catch (error) {
      emit(UpdateTickersFailure(error: error));
    }
  }
}

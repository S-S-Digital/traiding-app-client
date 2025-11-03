part of 'add_tickers_bloc.dart';

sealed class AddTickersEvent extends Equatable {
  const AddTickersEvent();

  @override
  List<Object> get props => [];
}

class Start extends AddTickersEvent {
  const Start({required this.symbol});
  final String symbol;
  @override
  List<Object> get props => super.props..add(symbol);
}

class AddNewTicker extends AddTickersEvent {
  const AddNewTicker({
    required this.symbol,
    required this.timeframe,
    required this.notifyBuy,
    required this.notifySell,
  });

  final String symbol;
  final String timeframe;
  final bool notifyBuy;
  final bool notifySell;

  @override
  List<Object> get props =>
      super.props..addAll([symbol, timeframe, notifyBuy, notifySell]);
}

final class SelectOption extends AddTickersEvent {
  const SelectOption({required this.option});
  final String option;

  @override
  List<Object> get props => super.props..add(option);
}


final class SelectTimeframe extends AddTickersEvent {
  const SelectTimeframe({required this.timeframe});
  final String timeframe;

  @override
  List<Object> get props => super.props..add(timeframe);
}
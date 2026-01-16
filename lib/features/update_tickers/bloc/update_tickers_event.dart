part of 'update_tickers_bloc.dart';

sealed class UpdateTickersEvent extends Equatable {
  const UpdateTickersEvent();

  @override
  List<Object> get props => [];
}

class Start extends UpdateTickersEvent {
  const Start({required this.tickers});
  final CombinedTicker tickers;

  @override
  List<Object> get props => super.props..add(tickers);
}



class UpdateTicker extends UpdateTickersEvent {
  const UpdateTicker({
    required this.id,
    required this.symbol,
    required this.timeframe,
    required this.notifyBuy,
    required this.notifySell,
  });
  final String id;
  final String symbol;
  final String timeframe;
  final bool notifyBuy;
  final bool notifySell;

  @override
  List<Object> get props =>
      super.props..addAll([id,symbol, timeframe, notifyBuy, notifySell]);
}

final class SelectOption extends UpdateTickersEvent {
  const SelectOption({required this.option});
  final Options option;

  @override
  List<Object> get props => super.props..add(option);
}


final class SelectTimeframe extends UpdateTickersEvent {
  const SelectTimeframe({required this.timeframe});
  final Timeframes timeframe;

  @override
  List<Object> get props => super.props..add(timeframe);
}
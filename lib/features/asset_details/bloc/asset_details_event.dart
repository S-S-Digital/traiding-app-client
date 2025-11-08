part of 'asset_details_bloc.dart';

sealed class AssetDetailsEvent extends Equatable {
  const AssetDetailsEvent();

  @override
  List<Object> get props => [];
}

class Start extends AssetDetailsEvent {
  const Start({required this.symbol});
  final String symbol;

  @override
  List<Object> get props => super.props..add(symbol);
}

class AddNewTicker extends AssetDetailsEvent {

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


final class SelectTimeframe extends AssetDetailsEvent {
  const SelectTimeframe({required this.timeframe, required this.symbol});
  final Timeframes timeframe;
  final String symbol;

  @override
  List<Object> get props => super.props..add(timeframe);
}
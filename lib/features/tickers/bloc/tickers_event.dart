part of 'tickers_bloc.dart';

sealed class TickersEvent extends Equatable {
  const TickersEvent();

  @override
  List<Object> get props => [];
}

final class Start extends TickersEvent {}

class ValidateTicker extends TickersEvent {
  final String symbol;

  const ValidateTicker({required this.symbol});

  @override
  List<Object> get props => super.props..add(symbol);
}

part of 'signals_bloc.dart';

sealed class SignalsEvent extends Equatable {
  const SignalsEvent();

  @override
  List<Object> get props => [];
}


class Start extends SignalsEvent{}


class ChangeFilter extends SignalsEvent {
  final String filter;
  const ChangeFilter(this.filter);

  @override
  List<Object> get props => super.props..add(filter);
}

class StopTimer extends SignalsEvent{}

class Update extends SignalsEvent{}

final class OnWebSocketPriceUpdate extends SignalsEvent {
  const OnWebSocketPriceUpdate({required this.symbol, required this.price});
  final String symbol;
  final double price;

  @override
  List<Object> get props => [symbol, price];
}

final class OnWebSocketSignalUpdate extends SignalsEvent {
  const OnWebSocketSignalUpdate({required this.signalData});
  final Map<String, dynamic> signalData;

  @override
  List<Object> get props => [signalData];
}

/// `signal_closed` WS event — a trade closed server-side.
final class OnWebSocketSignalClosed extends SignalsEvent {
  const OnWebSocketSignalClosed({required this.signalData});
  final Map<String, dynamic> signalData;

  @override
  List<Object> get props => [signalData];
}

/// `signal_update` WS event — live upsert of an existing signal.
final class OnWebSocketSignalLiveUpdate extends SignalsEvent {
  const OnWebSocketSignalLiveUpdate({required this.signalData});
  final Map<String, dynamic> signalData;

  @override
  List<Object> get props => [signalData];
}
// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tickers_bloc.dart';

sealed class TickersState extends Equatable {
  const TickersState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class TickersInitial extends TickersState {}

final class TickersLoading extends TickersState {}

class TickersLoaded extends TickersState {
  const TickersLoaded({required this.tickers});
  final List<CombinedTicker> tickers;

  TickersLoaded copyWith({List<CombinedTicker>? tickers}) {
    return TickersLoaded(tickers: tickers ?? this.tickers);
  }

  @override
  List<Object> get props => super.props..addAll([tickers]);
}

class TickersFailure extends TickersState {
  TickersFailure({required this.error}) : timestamp = DateTime.now();

  final Object error;
  final DateTime timestamp;

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..add(timestamp);
}



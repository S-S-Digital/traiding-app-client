part of 'tickers_bloc.dart';

sealed class TickersState extends Equatable {
  const TickersState();
  
  @override
  List<Object> get props => [];
}

final class TickersInitial extends TickersState {}

part of 'tickers_bloc.dart';

sealed class TickersEvent extends Equatable {
  const TickersEvent();

  @override
  List<Object?> get props => [];
}

final class Start extends TickersEvent {}

final class Refresh extends TickersEvent {}

final class StopTimer extends TickersEvent {}

class ValidateTicker extends TickersEvent {
  final String symbol;
  const ValidateTicker({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

class DeleteTicker extends TickersEvent {
  final String id;
  const DeleteTicker({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Событие обновления, которое теперь несет в себе новые данные
final class UpdateAsset extends TickersEvent {
  final List<Assets> newAssets;
  const UpdateAsset({required this.newAssets});

  @override
  List<Object?> get props => [newAssets];
}
part of 'tickers_bloc.dart';



class TickersState extends Equatable {
  const TickersState({
    this.status = Status.initial,
    this.tickers = const [],
    this.error,
  });

  final Status status;
  final List<CombinedTicker> tickers;
  final Object? error;

  TickersState copyWith({
    Status? status,
    List<CombinedTicker>? tickers,
    Object? error,
  }) {
    return TickersState(
      status: status ?? this.status,
      tickers: tickers ?? this.tickers,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, tickers, error];
}
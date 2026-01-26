
part of 'signals_bloc.dart';

class SignalsState extends Equatable {
  const SignalsState({
    this.status = Status.initial,
    this.signals = const [],
    this.activeFilter = '',
    this.error,
  });

  final Status status;
  final List<CombinedSignal> signals;
  final String activeFilter;
  final Object? error;

  SignalsState copyWith({
    Status? status,
    List<CombinedSignal>? signals,
    String? activeFilter,
    Object? error,
  }) {
    return SignalsState(
      status: status ?? this.status,
      signals: signals ?? this.signals,
      activeFilter: activeFilter ?? this.activeFilter,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, signals, activeFilter, error];
}

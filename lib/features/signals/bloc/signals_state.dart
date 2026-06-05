
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
    // Sticky-error fix (audit #7): `error ?? this.error` could NEVER clear a
    // once-set error (you can't pass null through copyWith), so a later success
    // kept the stale error in props and could re-surface a duplicate dialog.
    // Pass `clearError: true` to reset error to null on a successful load.
    bool clearError = false,
  }) {
    return SignalsState(
      status: status ?? this.status,
      signals: signals ?? this.signals,
      activeFilter: activeFilter ?? this.activeFilter,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, signals, activeFilter, error];
}

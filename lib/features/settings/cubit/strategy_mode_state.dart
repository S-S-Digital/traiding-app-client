part of 'strategy_mode_cubit.dart';

sealed class StrategyModeState extends Equatable {
  const StrategyModeState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class StrategyModeInitial extends StrategyModeState {}

final class StrategyModeLoading extends StrategyModeState {}

final class StrategyModeLoaded extends StrategyModeState {
  const StrategyModeLoaded({
    required this.mode,
    this.saving = false,
    this.justSaved = false,
  });

  final StrategyMode mode;
  final bool saving;
  final bool justSaved;

  @override
  List<Object> get props => [mode.current, mode.available, saving, justSaved];
}

final class StrategyModeFailure extends StrategyModeState {
  StrategyModeFailure({required this.error}) : timestamp = DateTime.now();
  final Object error;
  final DateTime timestamp;

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => [error, timestamp];
}

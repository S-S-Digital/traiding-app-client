// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'signals_bloc.dart';

sealed class SignalsState extends Equatable {
  const SignalsState();
  bool get isBuildable => true;

  @override
  List<Object> get props => [];
}

final class SignalsInitial extends SignalsState {}

final class SignalsLoading extends SignalsState {}

class SignalsLoaded extends SignalsState {
  const SignalsLoaded({required this.signals, this.activeFilter = 'Все'});

  SignalsLoaded copyWith({
    List<CombinedSignal>? signals,
    String? activeFilter,
  }) {
    return SignalsLoaded(
      signals: signals ?? this.signals,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  final List<CombinedSignal> signals;
  final String activeFilter;

  @override
  List<Object> get props => super.props..add([signals, activeFilter]);
}

class SignalsFailure extends SignalsState {
  SignalsFailure({required this.error}) : timestamp = DateTime.now();
  final Object error;
  final DateTime timestamp;

  @override
  List<Object> get props => [timestamp];

  @override
  bool get isBuildable => false;
}

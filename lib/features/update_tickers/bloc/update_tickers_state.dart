// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'update_tickers_bloc.dart';

sealed class UpdateTickersState extends Equatable {
  const UpdateTickersState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class UpdateTickersInitial extends UpdateTickersState {}

final class UpdateTickersLoading extends UpdateTickersState {}

class UpdateTickersLoaded extends UpdateTickersState {
  const UpdateTickersLoaded({
    required this.isValid,
    required this.selectedOption,
    required this.selectedTimeframe,
    required this.options,
    required this.timeframes,
  });
  final bool isValid;
  final Options selectedOption;
  final Timeframes selectedTimeframe;
  final List<Options> options;
  final List<Timeframes> timeframes;

  @override
  List<Object> get props => super.props
    ..add([isValid, selectedOption, selectedTimeframe, timeframes, options]);

  UpdateTickersLoaded copyWith({
    bool? isValid,
    Options? selectedOption,
    Timeframes? selectedTimeframe,
    List<Options>? options,
    List<Timeframes>? timeframes,
  }) {
    return UpdateTickersLoaded(
      isValid: isValid ?? this.isValid,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      options: options ?? this.options,
      timeframes: timeframes ?? this.timeframes,
    );
  }
}

class UpdateTickersFailure extends UpdateTickersState {
  UpdateTickersFailure({required this.error}) : timestamp = DateTime.now();

  final Object error;
  final DateTime timestamp;

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}

class Close extends UpdateTickersState {
  @override
  bool get isBuildable => false;
}

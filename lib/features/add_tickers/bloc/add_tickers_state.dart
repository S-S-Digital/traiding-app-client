part of 'add_tickers_bloc.dart';

sealed class AddTickersState extends Equatable {
  const AddTickersState();

  @override
  List<Object> get props => [];
}

final class AddTickersInitial extends AddTickersState {}

final class AddTickersLoading extends AddTickersState {}

class AddTickersLoaded extends AddTickersState {
  const AddTickersLoaded({
    required this.isValid,
    this.selectedOption,
    this.selectedTimeframe,
  });
  final bool isValid;
  final String? selectedOption;
  final String? selectedTimeframe;

  AddTickersLoaded copyWith({
    bool? isValid,
    String? selectedOption,
    String? selectedTimeframe,
  }) {
    return AddTickersLoaded(
      isValid: isValid ?? this.isValid,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
    );
  }

  @override
  List<Object> get props =>
      super.props..add([isValid, selectedOption, selectedTimeframe]);
}

class AddTickersFailure extends AddTickersState {
  AddTickersFailure({required this.error}) : timestamp = DateTime.now();

  final Object error;
  final DateTime timestamp;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}

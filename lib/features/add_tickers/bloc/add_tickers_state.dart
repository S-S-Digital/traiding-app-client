part of 'add_tickers_bloc.dart';

class AddTickersState extends Equatable {
  const AddTickersState({
    this.status = Status.initial,
    this.selectedOption,
    this.selectedTimeframe,
    this.error,
  });

  final Status status;
  final Options? selectedOption;
  final Timeframes? selectedTimeframe;
  final Object? error;

  AddTickersState copyWith({
    Status? status,
    Options? selectedOption,
    Timeframes? selectedTimeframe,
    Object? error,
  }) {
    return AddTickersState(
      status: status ?? this.status,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, selectedOption, selectedTimeframe, error];
}

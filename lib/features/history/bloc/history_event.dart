part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}


class Start extends HistoryEvent{}

class Update extends HistoryEvent{

}

class StopTimer extends HistoryEvent{}

class ChangePeriod extends HistoryEvent {
  final String period;
  const ChangePeriod(this.period);

  @override
  List<Object> get props => [period];
}
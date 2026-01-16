part of 'signals_bloc.dart';

sealed class SignalsEvent extends Equatable {
  const SignalsEvent();

  @override
  List<Object> get props => [];
}


class Start extends SignalsEvent{}


class ChangeFilter extends SignalsEvent {
  final String filter;
  const ChangeFilter(this.filter);

  @override
  List<Object> get props => super.props..add(filter);
}

class StopTimer extends SignalsEvent{}

class Update extends SignalsEvent{}
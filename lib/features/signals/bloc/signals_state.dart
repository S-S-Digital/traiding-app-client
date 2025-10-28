part of 'signals_bloc.dart';

sealed class SignalsState extends Equatable {
  const SignalsState();
  
  @override
  List<Object> get props => [];
}

final class SignalsInitial extends SignalsState {}

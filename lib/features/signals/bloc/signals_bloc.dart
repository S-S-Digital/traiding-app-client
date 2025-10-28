import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'signals_event.dart';
part 'signals_state.dart';

class SignalsBloc extends Bloc<SignalsEvent, SignalsState> {
  SignalsBloc() : super(SignalsInitial()) {
    on<SignalsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
  // final SignalsRepositoryI _signalsRepository;
}

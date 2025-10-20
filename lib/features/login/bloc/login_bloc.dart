import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepositoryI authRepository})
    : _authRepository = authRepository,
      super(LoginInitial()) {
    on<LoginEvent>((event, emit) {});
  }

  final AuthRepositoryI _authRepository;

  
}

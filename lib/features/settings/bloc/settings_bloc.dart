import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AuthRepositoryI authRepository,
    required UsersRepositoryI usersRepository,
  }) : _authRepository = authRepository,
       _usersRepository = usersRepository,

       super(SettingsInitial()) {
    on<Start>(_start);
    on<Exit>(_exit);
  }
  final AuthRepositoryI _authRepository;
  final UsersRepositoryI _usersRepository;

  Future<void> _start(Start event, Emitter<SettingsState> emit) async {
    try {
      final users = await _usersRepository.getCurrentUser();

      emit(SettingsLoaded(users: users));
    } on AppException catch (error) {
      talker.info(error.toString());
      emit(SettingsFailure(error: error));
    } catch (error) {
      talker.info(error.toString());
      emit(SettingsFailure(error: error));
    }
  }

  Future<void> _exit(Exit event, Emitter<SettingsState> emit) async {
    try {
      await _authRepository.logout();
      emit(Close());
    } on AppException catch (error) {
      emit(SettingsFailure(error: error));
    } catch (error) {
      emit(SettingsFailure(error: error));
    }
  }
}

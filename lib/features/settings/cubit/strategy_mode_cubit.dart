import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'strategy_mode_state.dart';

class StrategyModeCubit extends Cubit<StrategyModeState> {
  StrategyModeCubit({required UsersRepositoryI usersRepository})
      : _usersRepository = usersRepository,
        super(StrategyModeInitial());

  final UsersRepositoryI _usersRepository;

  Future<void> load() async {
    emit(StrategyModeLoading());
    try {
      final mode = await _usersRepository.getStrategyMode();
      emit(StrategyModeLoaded(mode: mode));
    } catch (e) {
      emit(StrategyModeFailure(error: e));
    }
  }

  Future<void> setMode(String value) async {
    final current = state;
    if (current is StrategyModeLoaded) {
      if (current.mode.current == value || current.saving) return;
      // Optimistic UI: reflect the choice immediately, mark saving.
      emit(StrategyModeLoaded(
        mode: StrategyMode(current: value, available: current.mode.available),
        saving: true,
      ));
      try {
        final updated = await _usersRepository.setStrategyMode(value);
        emit(StrategyModeLoaded(mode: updated, justSaved: true));
      } catch (e) {
        // Revert to the previous mode on failure.
        emit(StrategyModeLoaded(mode: current.mode));
        emit(StrategyModeFailure(error: e));
      }
    }
  }
}

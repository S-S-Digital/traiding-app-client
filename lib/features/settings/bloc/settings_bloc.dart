import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AuthRepositoryI authRepository,
    required UsersRepositoryI usersRepository,
    required SignalsRepositoryI signalsRepository,
  }) : _authRepository = authRepository,
       _usersRepository = usersRepository,
       _signalsRepository = signalsRepository,

       super(SettingsInitial()) {
    on<Start>(_start);
    on<Exit>(_exit);
    on<ToggleStatsCategory>(_toggleStatsCategory);
  }
  final AuthRepositoryI _authRepository;
  final UsersRepositoryI _usersRepository;
  final SignalsRepositoryI _signalsRepository;

  Future<void> _start(Start event, Emitter<SettingsState> emit) async {
    try {
      final info = await PackageInfo.fromPlatform();

      final version = info.version;
      final buildNumber = info.buildNumber;
      
      final users = await _usersRepository.getCurrentUser();

      // Emit loaded state immediately with empty stats so profile renders instantly!
      emit(SettingsLoaded(
        users: users,
        appVersion: version,
        build: buildNumber,
        allStats: SignalStats.empty,
        cryptoStats: SignalStats.empty,
        nonCryptoStats: SignalStats.empty,
      ));

      // Load all 3 stats sets in parallel in the background.
      // IMPORTANT: stats are premium-gated on the backend (403 for free users).
      // A stats failure must NOT wipe the already-emitted SettingsLoaded —
      // otherwise the whole profile collapses (name → "Пользователь", email
      // empty, всё 0.0%) and a raw "Upgrade to Premium" snackbar appears.
      // Free users keep the loaded profile with empty (zero) stats; the paywall
      // screens handle the upsell, not a red error banner.
      try {
        final statsResults = await Future.wait([
          _signalsRepository.fetchStats(),
          _signalsRepository.fetchStats(category: 'crypto'),
          _signalsRepository.fetchStats(category: 'non_crypto'),
        ]);

        emit(SettingsLoaded(
          users: users,
          appVersion: version,
          build: buildNumber,
          allStats: statsResults[0],
          cryptoStats: statsResults[1],
          nonCryptoStats: statsResults[2],
        ));
      } catch (statsError) {
        // Keep the loaded profile (name/email intact) with empty stats.
        talker.info('Stats fetch skipped (likely premium-gated): $statsError');
      }
    } on AppException catch (error) {
      talker.info(error.toString());
      emit(SettingsFailure(error: error));
    } catch (error) {
      talker.info(error.toString());
      emit(SettingsFailure(error: error));
    }
  }

  void _toggleStatsCategory(ToggleStatsCategory event, Emitter<SettingsState> emit) {
    final current = state;
    if (current is SettingsLoaded) {
      final next = switch (current.currentCategory) {
        StatsCategory.all => StatsCategory.crypto,
        StatsCategory.crypto => StatsCategory.nonCrypto,
        StatsCategory.nonCrypto => StatsCategory.all,
      };
      emit(current.copyWith(currentCategory: next));
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

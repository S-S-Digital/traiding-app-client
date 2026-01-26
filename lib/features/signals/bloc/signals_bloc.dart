import 'dart:async';
import 'package:aspiro_trade/features/signals/models/combined_signal.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'signals_event.dart';
part 'signals_state.dart';

class SignalsBloc extends Bloc<SignalsEvent, SignalsState> {
  SignalsBloc({
    required SignalsRepositoryI signalsRepository,
    required AssetsRepositoryI assetsRepository,
  }) : _signalsRepository = signalsRepository,
       _assetsRepository = assetsRepository,

       super(const SignalsState()) {
    on<Start>(_start);
    on<StopTimer>((event, emit) => timer?.cancel());
    on<Update>(_update);
    on<ChangeFilter>((event, emit) {
      emit(state.copyWith(activeFilter: event.filter));
    });
  }
  Timer? timer;
  final SignalsRepositoryI _signalsRepository;
  final AssetsRepositoryI _assetsRepository;

  Future<void> _start(Start event, Emitter<SignalsState> emit) async {
    try {
      emit(state.copyWith(status: Status.loading));

      final signals = await _signalsRepository.fetchAllSignals(
        1,
        20,
        '',
        '',
        '',
        '',
      );

      List<CombinedSignal> combinedSignals = [];

      if (signals.isNotEmpty) {
        // создаём список future для всех запросов assets
        final futures = signals.map((signal) async {
          final assets = await _assetsRepository.fetchAssetsBySymbol(
            signal.symbol,
          );
          return CombinedSignal(signal: signal, assets: assets);
        }).toList();

        // ждём все запросы параллельно
        combinedSignals = await Future.wait(futures);
      }
      emit(state.copyWith(status: Status.loaded, signals: combinedSignals));

      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 15), (_) {
          add(Update());
        });
      }
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _update(Update event, Emitter<SignalsState> emit) async {
    try {
      final signals = await _signalsRepository.fetchAllSignals(
        1,
        20,
        '',
        '',
        '',
        '',
      );

      List<CombinedSignal> combinedSignals = [];

      if (signals.isNotEmpty) {
        // создаём список future для всех запросов assets
        final futures = signals.map((signal) async {
          final assets = await _assetsRepository.fetchAssetsBySymbol(
            signal.symbol,
          );
          return CombinedSignal(signal: signal, assets: assets);
        }).toList();

        // ждём все запросы параллельно
        combinedSignals = await Future.wait(futures);
      }
      emit(state.copyWith( signals: combinedSignals));
    } catch (error) {
      emit(state.copyWith( status: Status.failure));
    }
  }
}

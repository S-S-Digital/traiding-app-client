import 'dart:async';
import 'package:aspiro_trade/features/signals/models/combined_signal.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/exceptions/app_exception.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
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

       super(SignalsInitial()) {
    on<Start>(_start);
    on<StopTimer>((event, emit) => timer?.cancel());
    on<Update>(_update);
    on<ChangeFilter>((event, emit) {
      final currentState = state;
      if (currentState is SignalsLoaded) {
        emit(currentState.copyWith(activeFilter: event.filter));
      }
    });
  }
  Timer? timer;
  final SignalsRepositoryI _signalsRepository;
  final AssetsRepositoryI _assetsRepository;

  Future<void> _start(Start event, Emitter<SignalsState> emit) async {
    try {
      emit(SignalsLoading());

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
      emit(SignalsLoaded(signals: combinedSignals));

      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 15), (_) {
          add(Update());
        });
      }
    } on AppException catch (error) {
      emit(SignalsFailure(error: error));
    } catch (error) {
      emit(SignalsFailure(error: error));
    }
  }

  Future<void> _update(Update event, Emitter<SignalsState> emit) async {
    try {
      final currentState = state;
      if (currentState is! SignalsLoaded) return;
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
      emit(SignalsLoaded(signals: combinedSignals));
    } catch (error) {
      emit(SignalsFailure(error: error));
    }
  }
}

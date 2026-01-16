import 'dart:async';

import 'package:aspiro_trade/features/history/models/combined_history.dart';
import 'package:aspiro_trade/features/history/models/history_statistics.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required SignalsRepositoryI signalsRepository,
    required AssetsRepositoryI assetsRepository,
  }) : _signalsRepository = signalsRepository,
       _assetsRepository = assetsRepository,
       super(HistoryInitial()) {
    on<Start>(_start);
    on<StopTimer>((event, emit) => timer?.cancel());
    on<Update>(_update);
  }
  Timer? timer;
  final SignalsRepositoryI _signalsRepository;
  final AssetsRepositoryI _assetsRepository;

  Future<void> _start(Start event, Emitter<HistoryState> emit) async {
    try {
      emit(HistoryLoading());

      final historyList = await _signalsRepository.fetchHistory(
        1,
        20,
        '',
        '',
        '',
        '',
      );

      // Формируем статистику
      final List<HistoryStatistics> stats = [
        HistoryStatistics(
          title: 'Всего сделок',
          value: historyList.stats.totalSignals.toString(),
          color: Colors.white,
        ),
        HistoryStatistics(
          title: 'Успешных',
          value:
              '${historyList.stats.successfulSignals} (${historyList.stats.winRate}%)',
          color: historyList.stats.winRate > 0
              ? AppColors.darkAccentGreen
              : AppColors.darkAccentRed,
        ),
        HistoryStatistics(
          title: 'Результат',
          value: '${historyList.stats.totalProfit}%',
          color: historyList.stats.totalProfit > 0
              ? AppColors.darkAccentGreen
              : AppColors.darkAccentRed,
        ),
      ];

      List<CombinedHistory> histories = [];

      if (historyList.histories.isNotEmpty) {
        // создаём список future для всех запросов assets
        final futures = historyList.histories.map((history) async {
          final assets = await _assetsRepository.fetchAssetsBySymbol(
            history.symbol,
          );
          return CombinedHistory(assets: assets, history: history);
        }).toList();

        // ждём все запросы параллельно
        histories = await Future.wait(futures);
      }

      emit(HistoryLoaded(histories: histories, stats: stats));
      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 15), (_) {
          add(Update());
        });
      }
    } on AppException catch (error) {
      emit(HistoryFailure(error: error));
    } catch (error) {
      emit(HistoryFailure(error: error));
    }
  }

  Future<void> _update(Update event, Emitter<HistoryState> emit) async {
    try {
      final currentState = state;
      if (currentState is! HistoryLoaded) return;

      final historyList = await _signalsRepository.fetchHistory(
        1,
        20,
        '',
        '',
        '',
        '',
      );
      final List<HistoryStatistics> stats = [
        HistoryStatistics(
          title: 'Всего сделок',
          value: historyList.stats.totalSignals.toString(),
          color: Colors.white,
        ),
        HistoryStatistics(
          title: 'Успешных',
          value:
              '${historyList.stats.successfulSignals} (${historyList.stats.winRate}%)',
          color: historyList.stats.winRate > 0
              ? AppColors.darkAccentGreen
              : AppColors.darkAccentRed,
        ),
        HistoryStatistics(
          title: 'Результат',
          value: '${historyList.stats.totalProfit}%',
          color: historyList.stats.totalProfit > 0
              ? AppColors.darkAccentGreen
              : AppColors.darkAccentRed,
        ),
      ];

      List<CombinedHistory> histories = [];

      if (historyList.histories.isNotEmpty) {
        // создаём список future для всех запросов assets
        final futures = historyList.histories.map((history) async {
          final assets = await _assetsRepository.fetchAssetsBySymbol(
            history.symbol,
          );
          return CombinedHistory(assets: assets, history: history);
        }).toList();

        // ждём все запросы параллельно
        histories = await Future.wait(futures);
      }
      emit(currentState.copyWith(histories: histories, stats: stats));
    } catch (error) {
      emit(HistoryFailure(error: error));
    }
  }
}

import 'dart:async';
import 'package:aspiro_trade/features/history/models/combined_history.dart';
import 'package:aspiro_trade/features/history/models/history_statistics.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
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
       super(const HistoryState()) {
    on<Start>(_start);
    on<StopTimer>((event, emit) => timer?.cancel());
    on<Update>(_update);
    on<ChangePeriod>((event, emit) {
      emit(state.copyWith(activePeriod: event.period));
      // Recompute stats with new period
      _emitFilteredStats(emit);
    });
  }
  Timer? timer;
  final SignalsRepositoryI _signalsRepository;
  final AssetsRepositoryI _assetsRepository;

  // All histories (unfiltered) for client-side stats computation
  List<CombinedHistory> _allHistories = [];

  void _emitFilteredStats(Emitter<HistoryState> emit) {
    final filtered = _filterByPeriod(_allHistories, state.activePeriod);
    final stats = _computeStats(filtered);
    emit(state.copyWith(stats: stats));
  }

  List<CombinedHistory> _filterByPeriod(List<CombinedHistory> all, String period) {
    if (period == 'All') return all;
    final now = DateTime.now();
    final cutoff = switch (period) {
      '24h' => now.subtract(const Duration(hours: 24)),
      '7d' => now.subtract(const Duration(days: 7)),
      _ => DateTime.fromMillisecondsSinceEpoch(0),
    };
    return all.where((h) => h.history.closedAt.isAfter(cutoff)).toList();
  }

  List<HistoryStatistics> _computeStats(List<CombinedHistory> histories) {
    final total = histories.length;
    final successful = histories.where((h) =>
      h.history.status.toLowerCase().contains('won') ||
      h.history.status.toLowerCase().contains('tp') ||
      h.history.resultPct > 0
    ).length;
    final winRate = total > 0 ? (successful / total * 100).round() : 0;
    final totalProfit = histories.fold<double>(0, (sum, h) => sum + h.history.resultPct.toDouble());
    final roundedProfit = (totalProfit * 100).round() / 100;

    return [
      HistoryStatistics(
        title: AppLocalizations.totalTrades,
        value: total.toString(),
        color: Colors.white,
      ),
      HistoryStatistics(
        title: AppLocalizations.successful,
        value: '$successful ($winRate%)',
        color: winRate > 0
            ? AppColors.darkAccentGreen
            : winRate == 0
                ? Colors.white
                : AppColors.darkAccentRed,
      ),
      HistoryStatistics(
        title: AppLocalizations.result,
        value: '${roundedProfit > 0 ? '+' : ''}$roundedProfit%',
        color: roundedProfit > 0
            ? AppColors.darkAccentGreen
            : roundedProfit == 0
                ? Colors.white
                : AppColors.darkAccentRed,
      ),
    ];
  }

  Future<void> _start(Start event, Emitter<HistoryState> emit) async {
    try {
      emit(state.copyWith(status: Status.loading));

      final historyList = await _signalsRepository.fetchHistory(
        1,
        100,
        '',
        '',
        '',
        '',
      );

      List<CombinedHistory> histories = [];

      if (historyList.histories.isNotEmpty) {
        final cachedAssets = <String, dynamic>{};
        final futures = historyList.histories.map((history) async {
          try {
            final assets = cachedAssets[history.symbol] ??
                await _assetsRepository.fetchAssetsBySymbol(history.symbol);
            cachedAssets[history.symbol] = assets;
            return CombinedHistory(assets: assets, history: history);
          } catch (_) {
            // If asset fetch fails, still show history with null assets
            return CombinedHistory(assets: null, history: history);
          }
        }).toList();

        histories = await Future.wait(futures);
      }

      _allHistories = histories;
      final filtered = _filterByPeriod(histories, state.activePeriod);
      final stats = _computeStats(filtered);

      emit(
        state.copyWith(
          status: Status.loaded,
          histories: histories,
          stats: stats,
        ),
      );
      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 15), (_) {
          add(Update());
        });
      }
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    } catch (_) {
      emit(state.copyWith(status: Status.failure));
    }
  }

  Future<void> _update(Update event, Emitter<HistoryState> emit) async {
    try {
      final historyList = await _signalsRepository.fetchHistory(
        1,
        100,
        '',
        '',
        '',
        '',
      );

      List<CombinedHistory> histories = [];

      if (historyList.histories.isNotEmpty) {
        final cachedAssets = {
          for (final cs in state.histories) cs.history.symbol: cs.assets,
        };
        final futures = historyList.histories.map((history) async {
          final assets = cachedAssets[history.symbol] ??
              await _assetsRepository.fetchAssetsBySymbol(history.symbol);
          return CombinedHistory(assets: assets, history: history);
        }).toList();

        histories = await Future.wait(futures);
      }

      _allHistories = histories;
      final filtered = _filterByPeriod(histories, state.activePeriod);
      final stats = _computeStats(filtered);

      emit(state.copyWith(histories: histories, stats: stats));
    } catch (_) {
      // Silently ignore update errors
    }
  }
}

import 'dart:async';
import 'package:aspiro_trade/features/history/models/combined_history.dart';
import 'package:aspiro_trade/features/history/models/history_statistics.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/services/cache_invalidation_bus.dart';
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
  }) : _signalsRepository = signalsRepository,
       super(const HistoryState()) {
    on<Start>(_start);
    on<StopTimer>((event, emit) {});
    on<Update>(_update);
    on<ChangePeriod>((event, emit) {
      emit(state.copyWith(activePeriod: event.period));
      // Recompute stats with new period
      _emitFilteredStats(emit);
    });

    // Premium/subscription change → refetch closed-trade history so gated
    // content stays consistent with the user's current entitlement.
    _invalidationSubscription =
        CacheInvalidationBus.instance.onInvalidateMarketData.listen((_) {
      add(Update());
    });
  }
  final SignalsRepositoryI _signalsRepository;
  StreamSubscription? _invalidationSubscription;

  // All histories (unfiltered) for client-side stats computation
  List<CombinedHistory> _allHistories = [];

  // Restoring the original exact helper structure
  void _emitFilteredStats(Emitter<HistoryState> emit) {
    final filtered = _filterByPeriod(_allHistories, state.activePeriod);
    final stats = _computeStats(filtered);
    emit(state.copyWith(stats: stats));
  }

  List<CombinedHistory> _filterByPeriod(List<CombinedHistory> all, String period) {
    if (period == 'All') return all;
    final now = DateTime.now();
    if (period == 'Today') {
      final today = DateTime(now.year, now.month, now.day);
      return all.where((h) {
        final d = h.history.closedAt;
        return DateTime(d.year, d.month, d.day) == today;
      }).toList();
    }
    final cutoff = switch (period) {
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
      if (state.histories.isEmpty) {
        emit(state.copyWith(status: Status.loading));
      }

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
        histories = historyList.histories.map((history) {
          return CombinedHistory(assets: null, history: history);
        }).toList();
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
        histories = historyList.histories.map((history) {
          return CombinedHistory(assets: null, history: history);
        }).toList();
      }

      _allHistories = histories;
      final filtered = _filterByPeriod(histories, state.activePeriod);
      final stats = _computeStats(filtered);

      emit(state.copyWith(histories: histories, stats: stats));
    } catch (_) {
      // Silently ignore update errors
    }
  }

  @override
  Future<void> close() {
    _invalidationSubscription?.cancel();
    return super.close();
  }
}

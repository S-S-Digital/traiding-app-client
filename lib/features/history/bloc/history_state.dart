
part of 'history_bloc.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.status = Status.initial,
    this.histories = const [],
    this.stats = const [],
    this.backendStats,
    this.activePeriod = 'Today',
    this.error,
  });
  bool get isBuildable => true;
  final Status status;
  final List<CombinedHistory> histories;
  final List<HistoryStatistics> stats;
  // Server-authoritative aggregate (all closed signals, not just the loaded
  // page). Single source of truth for the all-time win-rate / total %.
  final Stats? backendStats;
  final String activePeriod;
  final Object? error;

  HistoryState copyWith({
    Status? status,
    List<CombinedHistory>? histories,
    List<HistoryStatistics>? stats,
    Stats? backendStats,
    String? activePeriod,
    Object? error,
  }) {
    return HistoryState(
      status: status ?? this.status,
      histories: histories ?? this.histories,
      stats: stats ?? this.stats,
      backendStats: backendStats ?? this.backendStats,
      activePeriod: activePeriod ?? this.activePeriod,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, histories, stats, backendStats, activePeriod, error];
}

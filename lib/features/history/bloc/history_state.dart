
part of 'history_bloc.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.status = Status.initial,
    this.histories = const [],
    this.stats = const [],
    this.activePeriod = '24h',
    this.error,
  });
  bool get isBuildable => true;
  final Status status;
  final List<CombinedHistory> histories;
  final List<HistoryStatistics> stats;
  final String activePeriod;
  final Object? error;

  HistoryState copyWith({
    Status? status,
    List<CombinedHistory>? histories,
    List<HistoryStatistics>? stats,
    String? activePeriod,
    Object? error,
  }) {
    return HistoryState(
      status: status ?? this.status,
      histories: histories ?? this.histories,
      stats: stats ?? this.stats,
      activePeriod: activePeriod ?? this.activePeriod,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, histories, stats, activePeriod, error];
}

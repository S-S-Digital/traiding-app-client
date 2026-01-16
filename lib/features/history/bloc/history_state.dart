// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'history_bloc.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded({required this.histories, required this.stats});
  
  HistoryLoaded copyWith({List<CombinedHistory>? histories, List<HistoryStatistics>? stats}) {
    return HistoryLoaded(
      histories: histories ?? this.histories,
      stats: stats ?? this.stats,
    );
  }

  final List<CombinedHistory> histories;
  final List<HistoryStatistics> stats;

  @override
  List<Object> get props => super.props..add([histories, stats]);
}

class HistoryFailure extends HistoryState {
  final Object error;
  final DateTime timestamp;

  HistoryFailure({required this.error}) : timestamp = DateTime.now();

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}

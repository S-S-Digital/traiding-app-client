part of 'asset_analytics_cubit.dart';

sealed class AssetAnalyticsState extends Equatable {
  const AssetAnalyticsState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class AssetAnalyticsInitial extends AssetAnalyticsState {}

final class AssetAnalyticsLoading extends AssetAnalyticsState {}

final class AssetAnalyticsLoaded extends AssetAnalyticsState {
  final AssetAnalyticsFeed feed;
  const AssetAnalyticsLoaded({required this.feed});

  @override
  List<Object> get props => [feed.date ?? '', feed.isLocked, feed.assets.length];
}

final class AssetAnalyticsFailure extends AssetAnalyticsState {
  final Object error;
  final DateTime timestamp;
  AssetAnalyticsFailure({required this.error}) : timestamp = DateTime.now();

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => [error, timestamp];
}

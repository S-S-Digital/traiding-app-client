import 'package:aspiro_trade/repositories/analytics/domain/asset_analytics.dart';

abstract interface class AnalyticsRepositoryI {
  /// Today's premium per-asset analytics. Non-subscribers get a locked teaser
  /// envelope (handled server-side); never throws a 403.
  Future<AssetAnalyticsFeed> fetchTodayAnalytics();
}

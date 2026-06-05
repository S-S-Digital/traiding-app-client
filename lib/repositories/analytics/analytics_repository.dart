import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/analytics/analytics_repository_interface.dart';
import 'package:aspiro_trade/repositories/analytics/domain/asset_analytics.dart';
import 'package:aspiro_trade/repositories/base/base.dart';

class AnalyticsRepository extends BaseRepository implements AnalyticsRepositoryI {
  AnalyticsRepository(super.talker, {required this.api});

  final AspiroTradeApi api;

  @override
  Future<AssetAnalyticsFeed> fetchTodayAnalytics() => safeApiCall(() async {
        final dto = await api.fetchTodayAnalytics();
        return dto.toEntity();
      });
}

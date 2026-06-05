import 'package:aspiro_trade/repositories/analytics/analytics.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'asset_analytics_state.dart';

class AssetAnalyticsCubit extends Cubit<AssetAnalyticsState> {
  AssetAnalyticsCubit({required this.analyticsRepository})
      : super(AssetAnalyticsInitial());

  final AnalyticsRepositoryI analyticsRepository;

  Future<void> fetch() async {
    emit(AssetAnalyticsLoading());
    try {
      final feed = await analyticsRepository.fetchTodayAnalytics();
      emit(AssetAnalyticsLoaded(feed: feed));
    } catch (e) {
      emit(AssetAnalyticsFailure(error: e));
    }
  }
}

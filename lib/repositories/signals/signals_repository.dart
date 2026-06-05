import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:realm/realm.dart';

class SignalsRepository extends BaseRepository implements SignalsRepositoryI {
  SignalsRepository(super.talker, {required this.api, required this.realm});

  final AspiroTradeApi api;
  final Realm realm;

  @override
  Future<List<Signals>> fetchAllSignals(
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  ) => safeApiCall(() async {
    final response = await api.fetchAllSignals(
      page,
      limit,
      symbol,
      timeframe,
      direction,
      status,
    );

    final signals = response.data.map((signal) => signal.toEntity()).toList();

    realm.write(() {
      realm.deleteAll<SignalsLocal>();

      realm.addAll(
        response.data.map((signal) => signal.toLocal()).toList(),
        update: true,
      );
    });
    return signals;
  });

  @override
  Future<List<Signals>> fetchSignalsByTickerId(
    String tickerId,
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  ) => safeApiCall(() async {
    final response = await api.fetchSignalsByTickerId(
      tickerId,
      page,
      limit,
      symbol,
      timeframe,
      direction,
      status,
    );

    realm.write(() {
      realm.addAll(
        response.data.map((signal) => signal.toLocal()).toList(),
        update: true,
      );
    });

    return response.data.map((signal)=> signal.toEntity()).toList();
  });

  @override
  Future<HistoryList> fetchHistory(
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  ) => safeApiCall(() async {
    final response = await api.fetchHistory(
      page,
      limit,
      symbol,
      timeframe,
      direction,
      status,
    );

    return response.toEntity();
  });

  @override
  Future<SignalStats> fetchStats({String? category}) => safeApiCall(() async {
    final response = await api.fetchSignalStats(category: category);
    return response.toEntity();
  });

  @override
  Future<List<Signals>> fetchLocalSignals() async {
    try {
      final locals = realm.all<SignalsLocal>();
      return locals.map((local) => local.toEntity()).toList();
    } catch (e, stack) {
      talker.error('Failed to fetch local signals from Realm', e, stack);
      return [];
    }
  }

  @override
  void clearLocalCache() {
    try {
      realm.write(() => realm.deleteAll<SignalsLocal>());
    } catch (e, stack) {
      talker.error('Failed to clear local signals cache', e, stack);
    }
  }
}

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

    // realm.write(() {
    //   realm.deleteAll<SignalsLocal>();

    //   realm.addAll(
    //     response.data.map((signal) => signal.toLocal()).toList(),
    //     update: true,
    //   );
    // });
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

    // realm.write(() {
    //   realm.addAll(
    //     response.data.map((signal) => signal.toLocal()).toList(),
    //     update: true,
    //   );
    // });

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
}

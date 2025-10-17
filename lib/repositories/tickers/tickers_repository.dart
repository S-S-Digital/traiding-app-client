import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:realm/realm.dart';

class TickersRepository extends BaseRepository implements TickersRepositoryI {
  final AspiroTradeApi api;
  final Realm realm;

  TickersRepository(super.talker, {required this.api, required this.realm});

  @override
  Future<Tickers> addNewTicker(AddTicker ticker) => safeApiCall(() async {
    final tickerDto = await api.addNewTicker(ticker);

    realm.write(() {
      realm.add(tickerDto.toLocal(), update: true);
    });

    return tickerDto.toEntity();
  });

  @override
  Future<void> deleteTicker(String id) => safeApiCall(() async {
    final result = await api.deleteTicker(id);

    if (result.count > 0) {
      final ticker = realm.find<TickersLocal>(id);

      if (ticker != null) {
        realm.write(() {
          realm.delete<TickersLocal>(ticker);
        });
      }
    }
  });

  @override
  Future<List<Tickers>> fetchAllTickers() => safeApiCall(() async {
    List<Tickers> tickers = [];
    final tickersDto = await api.fetchAllTickers();

    realm.write(() {
      realm.deleteAll<TickersLocal>();

      for (var ticker in tickersDto) {
        realm.add(ticker.toLocal(), update: true);
      }
    });

    for (var ticker in tickersDto) {
      tickers.add(ticker.toEntity());
    }
    return tickers;
  });

  @override
  Future<void> updateTickerSignals(String id) =>
      safeApiCall(() => api.updateTickerSignals(id));

  @override
  Future<List<Tickers>> fetchAllLocalTickers() async {
    try {
      final tickersLocal = realm.all<TickersLocal>().toList();
      final tickers = tickersLocal.map((e) => e.toEntity()).toList();
      return tickers;
    } catch (e, stack) {
      talker.error('Failed to fetch local tickers', e, stack);
      throw UnknownException(e.toString());
    }
  }
}



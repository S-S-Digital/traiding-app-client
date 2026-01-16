
import 'package:aspiro_trade/repositories/signals/signals.dart';

abstract interface class SignalsRepositoryI {
  Future<List<Signals>> fetchAllSignals(
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  );
  Future<List<Signals>> fetchSignalsByTickerId(
    String tickerId,
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  );


  Future<HistoryList> fetchHistory(
    int page,
    int limit,
    String symbol,
    String timeframe,
    String direction,
    String status,
  );
}

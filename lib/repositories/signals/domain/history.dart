import 'package:aspiro_trade/ui/localization/app_localizations.dart';

class History {
  History({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.timeframe,
    required this.status,
    required this.entry,
    required this.exit,
    required this.takeProfit,
    required this.stopLoss,
    required this.resultPct,
    required this.resultUsd,
    required this.duration,
    required this.createdAt,
    required this.closedAt,
  });

  final String id;
  final String symbol;
  final String direction;
  final String timeframe;
  final String status;
  final num entry;
  final num exit;
  final num? takeProfit;
  final num? stopLoss;
  final num resultPct;
  final num resultUsd;
  final String? duration;
  final DateTime createdAt;
  final DateTime closedAt;

  // Lowercase before matching — the backend now uppercases direction to
  // 'BUY'/'SELL' and may send mixed-case status, so a raw `.contains('buy')`
  // would silently fall through to the SELL branch.
  String formatStatus(String value) =>
      value.toLowerCase().contains('closed')
          ? AppLocalizations.closed
          : AppLocalizations.open;

  String formatDirection(String value) =>
      value.toLowerCase().contains('buy')
          ? AppLocalizations.filterBuy
          : AppLocalizations.filterSell;

   String formatTimeframe(String timeframe) {
    switch (timeframe) {
      case '15m':
        return AppLocalizations.isRu ? '15 минут' : '15 min';
      case '1h':
        return AppLocalizations.isRu ? '1 час' : '1 hour';
      case '1d':
        return AppLocalizations.isRu ? '1 день' : '1 day';
      case '1w':
        return AppLocalizations.isRu ? '1 неделя' : '1 week';
      case '1M':
        return AppLocalizations.isRu ? '1 месяц' : '1 month';
      default:
        return timeframe; 
    }
  }
}

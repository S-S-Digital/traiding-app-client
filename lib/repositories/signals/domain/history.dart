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
  final num takeProfit;
  final num stopLoss;
  final num resultPct;
  final num resultUsd;
  final String duration;
  final DateTime createdAt;
  final DateTime closedAt;

  String formatStatus(String value) =>
      value.contains('closed') ? 'Закрыт' : 'Открыт';

  String formatDirection(String value) =>
      value.contains('buy') ? 'Покупка' : 'Продажа';



   String formatTimeframe(String timeframe) {
    switch (timeframe) {
      case '15m':
        return '15 минут';
      case '1h':
        return '1 час';
      case '1d':
        return '1 день';
      case '1w':
        return '1 неделя';
      case '1M':
        return '1 месяц';
      default:
        return timeframe; 
    }
  }
}

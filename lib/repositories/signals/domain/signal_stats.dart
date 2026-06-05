class SignalStats {
  const SignalStats({
    required this.total,
    required this.totalBuy,
    required this.totalSell,
    required this.active,
    required this.closed,
    required this.profitable,
    required this.unprofitable,
    required this.winRate,
    required this.totalProfitLoss,
    required this.totalProfitLossPct,
    required this.avgProfitLossPct,
  });

  final num total;
  final num totalBuy;
  final num totalSell;
  final num active;
  final num closed;
  final num profitable;
  final num unprofitable;
  final num winRate;
  final num totalProfitLoss;
  final num totalProfitLossPct;
  final num avgProfitLossPct;

  static const empty = SignalStats(
    total: 0,
    totalBuy: 0,
    totalSell: 0,
    active: 0,
    closed: 0,
    profitable: 0,
    unprofitable: 0,
    winRate: 0,
    totalProfitLoss: 0,
    totalProfitLossPct: 0,
    avgProfitLossPct: 0,
  );
}

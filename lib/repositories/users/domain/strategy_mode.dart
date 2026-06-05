/// Account-level strategy mode (backend Task #4).
/// `quality` = only the validated high-conviction stream (default).
/// `turnover` = superset (all tiers) — more signals, opt-in.
class StrategyMode {
  const StrategyMode({required this.current, required this.available});

  final String current;
  final List<String> available;

  bool get isQuality => current == 'quality';
  bool get isTurnover => current == 'turnover';

  static const qualityKey = 'quality';
  static const turnoverKey = 'turnover';
}

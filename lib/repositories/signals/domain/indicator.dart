class Indicator {
    Indicator({
    required this.atr,
    required this.macd,
    required this.ema50,
    required this.ema200,
    required this.volume,
    required this.stochD,
    required this.stochK,
    required this.volumeSma,
    required this.macdSignal,
    required this.macdHistogram,
  });


    factory Indicator.empty() => Indicator(
    atr: 0,
    macd: 0,
    ema50: 0,
    ema200: 0,
    volume: 0,
    stochD: 0,
    stochK: 0,
    volumeSma: 0,
    macdSignal: 0,
    macdHistogram: 0,
  );


  final double atr;
  final double macd;
  final double ema50;
  final double ema200;
  final num volume;
  final double stochD;
  final double stochK;
  final num volumeSma;
  final double macdSignal;
  final num macdHistogram;


}

/// Single source of truth for "is this a crypto pair?".
///
/// Mirrors the backend `isCrypto()` regex (`/USDT$|USDC$|BTC$|ETH$|BNB$/`).
/// Non-crypto (stocks/forex/commodities) generation was removed backend-side
/// (TradingView webhook deleted), so the client hides/【disables】 non-crypto
/// tickers — they would produce no signals and have no accurate live feed.
bool isCryptoSymbol(String symbol) {
  final s = symbol.toUpperCase();
  return s.endsWith('USDT') ||
      s.endsWith('USDC') ||
      s.endsWith('BTC') ||
      s.endsWith('ETH') ||
      s.endsWith('BNB');
}

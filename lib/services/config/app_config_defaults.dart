import 'package:aspiro_trade/api/models/app_config/app_config_dto.dart';

/// The baked, crypto-only default config.
///
/// This is the offline / first-run / total-failure fallback. It MUST reproduce
/// today's hardcoded behavior byte-for-byte: the 7 crypto pairs, both strategy
/// modes with the exact PDF numbers + 13-point equity curves the app shipped
/// with, and analytics/digest/crypto-payments on. If the network is never
/// reachable, the app looks exactly like it does today.
///
/// `minAppVersion` is intentionally `0.0.0` here so the offline fallback never
/// nags an update it can't verify — the real threshold only ever arrives from
/// the server.
class AppConfigDefaults {
  AppConfigDefaults._();

  static AppConfigDto build() => const AppConfigDto(
        meta: ConfigMetaDto(
          configVersion: 0,
          minAppVersion: '0.0.0',
          refreshSec: 900,
          generatedAt: null,
        ),
        markets: [
          MarketDto(
              id: 'crypto',
              name: 'Крипта',
              enabled: true,
              order: 1,
              icon: 'currency_bitcoin',
              liveData: true),
        ],
        assets: [
          AssetConfigDto(symbol: 'BTCUSDT', market: 'crypto', display: 'BTC', priceDecimals: null, enabled: true, order: 1, session: '24/7', icon: null),
          AssetConfigDto(symbol: 'ETHUSDT', market: 'crypto', display: 'ETH', priceDecimals: null, enabled: true, order: 2, session: '24/7', icon: null),
          AssetConfigDto(symbol: 'BNBUSDT', market: 'crypto', display: 'BNB', priceDecimals: null, enabled: true, order: 3, session: '24/7', icon: null),
          AssetConfigDto(symbol: 'SOLUSDT', market: 'crypto', display: 'SOL', priceDecimals: null, enabled: true, order: 4, session: '24/7', icon: null),
          AssetConfigDto(symbol: 'XRPUSDT', market: 'crypto', display: 'XRP', priceDecimals: null, enabled: true, order: 5, session: '24/7', icon: null),
          AssetConfigDto(symbol: 'DOGEUSDT', market: 'crypto', display: 'DOGE', priceDecimals: null, enabled: true, order: 6, session: '24/7', icon: null),
          AssetConfigDto(symbol: 'TONUSDT', market: 'crypto', display: 'TON', priceDecimals: null, enabled: true, order: 7, session: '24/7', icon: null),
        ],
        strategies: [
          StrategyConfigDto(
            id: 'quality',
            name: 'Качество',
            description: null,
            timeframe: '15m',
            enabled: true,
            isDefault: true,
            markets: ['crypto'],
            order: 1,
            stats: StrategyStatsDto(
              tradesPerMonth: 34,
              tradesPer90d: 102,
              winRatePct: 60.8,
              profitFactor: 1.55,
              maxDrawdownPct: 4.9,
              returnPct: 24.0,
              equity: [
                1000, 1030, 1080, 1060, 1100, 1130, 1120, 1150, 1160, 1185,
                1205, 1225, 1240,
              ],
            ),
          ),
          StrategyConfigDto(
            id: 'turnover',
            name: 'Оборот',
            description: null,
            timeframe: '15m',
            enabled: true,
            isDefault: false,
            markets: ['crypto'],
            order: 2,
            stats: StrategyStatsDto(
              tradesPerMonth: 71,
              tradesPer90d: 212,
              winRatePct: 57.5,
              profitFactor: 1.36,
              maxDrawdownPct: 8.7,
              returnPct: 36.3,
              equity: [
                1000, 1040, 1010, 1080, 1130, 1100, 1160, 1210, 1180, 1255,
                1310, 1345, 1363,
              ],
            ),
          ),
        ],
        features: {
          'analytics': true,
          'digest': true,
          'nonCryptoSignals': false,
          'cryptoPayments': true,
        },
      );
}

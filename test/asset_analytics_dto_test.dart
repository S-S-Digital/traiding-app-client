import 'package:aspiro_trade/api/models/analytics/asset_analytics_dto.dart';
import 'package:aspiro_trade/api/models/users/strategy_mode_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetAnalyticsFeedDto.fromJson', () {
    test('parses a premium (unlocked) asset with nested levels/scenarios', () {
      final feed = AssetAnalyticsFeedDto.fromJson({
        'date': '2026-06-05',
        'isLocked': false,
        'assets': [
          {
            'asset': 'BTCUSDT',
            'price': 67000,
            'trend': 'UP',
            'regime': 'RANGE',
            'adx': 18.2,
            'atrPct': 0.9,
            'levels': {
              'support': [66000, 65200],
              'resistance': [68000],
              'ema50': 66800,
              'ema200': 65000,
              'change24hPct': 1.4,
            },
            'narrative': 'BTC консолидируется...',
            'scenarios': [
              {'type': 'bounce', 'condition': 'удержание 66k', 'target': '68k'}
            ],
            'sentiment': 'BULLISH',
            'signalsLikely': true,
            'isLocked': false,
          }
        ],
      }).toEntity();

      expect(feed.isLocked, isFalse);
      expect(feed.assets, hasLength(1));
      final a = feed.forSymbol('btcusdt');
      expect(a, isNotNull);
      expect(a!.trend, 'UP');
      expect(a.regime, 'RANGE');
      expect(a.levels!.support, [66000, 65200]);
      expect(a.levels!.resistance, [68000]);
      expect(a.scenarios.single.type, 'bounce');
      expect(a.signalsLikely, isTrue);
      expect(a.isLocked, isFalse);
    });

    test('parses a locked teaser (nulled direction fields)', () {
      final feed = AssetAnalyticsFeedDto.fromJson({
        'date': '2026-06-05',
        'isLocked': true,
        'assets': [
          {
            'asset': 'BTCUSDT',
            'price': 67000,
            'trend': null,
            'regime': null,
            'levels': null,
            'narrative': '🔒 Премиум',
            'scenarios': [],
            'sentiment': null,
            'signalsLikely': null,
            'isLocked': true,
          }
        ],
      }).toEntity();

      expect(feed.isLocked, isTrue);
      final a = feed.forSymbol('BTCUSDT')!;
      expect(a.isLocked, isTrue);
      expect(a.trend, isNull);
      expect(a.levels, isNull);
      expect(a.scenarios, isEmpty);
    });

    test('tolerates missing/empty assets', () {
      final feed = AssetAnalyticsFeedDto.fromJson({'date': null}).toEntity();
      expect(feed.date, isNull);
      expect(feed.assets, isEmpty);
      expect(feed.forSymbol('BTCUSDT'), isNull);
    });
  });

  group('StrategyModeDto.fromJson', () {
    test('parses mode + available list', () {
      final dto = StrategyModeDto.fromJson({
        'strategyMode': 'turnover',
        'availableModes': ['quality', 'turnover'],
      });
      expect(dto.strategyMode, 'turnover');
      expect(dto.availableModes, ['quality', 'turnover']);
    });

    test('falls back to quality + default modes when absent', () {
      final dto = StrategyModeDto.fromJson({});
      expect(dto.strategyMode, 'quality');
      expect(dto.availableModes, ['quality', 'turnover']);
    });

    test('UpdateStrategyMode serializes', () {
      expect(const UpdateStrategyMode(strategyMode: 'quality').toJson(),
          {'strategyMode': 'quality'});
    });
  });
}

import 'package:aspiro_trade/api/models/history/history_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryDto.fromJson', () {
    Map<String, dynamic> base() => {
          'id': 's1',
          'symbol': 'DOGEUSDT',
          'direction': 'BUY',
          'timeframe': '15m',
          'status': 'closed',
          'entry': 0.16234,
          'exit': 0.16871,
          'takeProfit': 0.17,
          'stopLoss': 0.16,
          'resultPct': 3.92,
          'resultUsd': 39.2,
          'duration': '2ч 13м',
          'createdAt': '2026-06-05T10:00:00.000Z',
          'closedAt': '2026-06-05T12:13:00.000Z',
        };

    test('parses a normal closed row', () {
      final dto = HistoryDto.fromJson(base());
      expect(dto.duration, '2ч 13м');
      expect(dto.entry, 0.16234);
    });

    test('null duration deserializes without throwing (C3 regression)', () {
      // Backend sends duration:null when createdAt/closedAt are missing.
      // Previously cast `as String` → _TypeError crashed the whole list parse.
      final json = base()..['duration'] = null;
      late HistoryDto dto;
      expect(() => dto = HistoryDto.fromJson(json), returnsNormally);
      expect(dto.duration, isNull);
    });

    test('null takeProfit/stopLoss tolerated', () {
      final json = base()
        ..['takeProfit'] = null
        ..['stopLoss'] = null;
      final dto = HistoryDto.fromJson(json);
      expect(dto.takeProfit, isNull);
      expect(dto.stopLoss, isNull);
    });
  });
}

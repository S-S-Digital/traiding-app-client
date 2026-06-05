import 'package:aspiro_trade/utils/methods/crypto_symbol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isCryptoSymbol', () {
    test('accepts crypto quote suffixes', () {
      expect(isCryptoSymbol('BTCUSDT'), isTrue);
      expect(isCryptoSymbol('ethusdc'), isTrue);
      expect(isCryptoSymbol('SOLBTC'), isTrue);
      expect(isCryptoSymbol('XRPETH'), isTrue);
      expect(isCryptoSymbol('FOOBNB'), isTrue);
    });

    test('rejects non-crypto tickers (now disabled backend-side)', () {
      expect(isCryptoSymbol('AAPL'), isFalse);
      expect(isCryptoSymbol('USO'), isFalse);
      expect(isCryptoSymbol('EURUSD'), isFalse);
      expect(isCryptoSymbol(''), isFalse);
    });
  });
}

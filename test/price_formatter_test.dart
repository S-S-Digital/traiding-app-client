import 'package:aspiro_trade/utils/methods/price_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceFormatter.decimalsFor', () {
    test('large prices use 2 decimals', () {
      expect(PriceFormatter.decimalsFor(69000), 2);
      expect(PriceFormatter.decimalsFor(1234.5), 2);
    });

    test('sub-dollar coins get more precision', () {
      expect(PriceFormatter.decimalsFor(0.16), 4); // DOGE
      expect(PriceFormatter.decimalsFor(0.05), 5);
      expect(PriceFormatter.decimalsFor(0.0008), 6);
      expect(PriceFormatter.decimalsFor(0.00000012), 8);
    });
  });

  group('PriceFormatter.price', () {
    test('keeps sub-dollar coins readable (regression: was \$0.00)', () {
      // The old toStringAsFixed(2) collapsed these to 0.00 / identical values.
      expect(PriceFormatter.price(0.16432), '0.1643');
      expect(PriceFormatter.price(0.0008123), '0.000812');
      expect(PriceFormatter.price(0.16432).contains('0.00'), isFalse);
    });

    test('groups thousands and supports a symbol', () {
      expect(PriceFormatter.price(69000.12), '69,000.12');
      expect(PriceFormatter.price(69000.12, withSymbol: true), '\$69,000.12');
    });

    test('null / non-finite → em dash', () {
      expect(PriceFormatter.price(null), '—');
      expect(PriceFormatter.price(double.infinity), '—');
    });
  });

  group('PriceFormatter.percent', () {
    test('signed, 2 decimals', () {
      expect(PriceFormatter.percent(1.234), '+1.23%');
      expect(PriceFormatter.percent(-0.5), '-0.50%');
      expect(PriceFormatter.percent(0), '0.00%');
    });
  });
}

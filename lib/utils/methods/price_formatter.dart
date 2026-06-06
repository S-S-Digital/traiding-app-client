import 'package:intl/intl.dart';

/// Magnitude-aware price/percent formatting.
///
/// Prod pairs span four orders of magnitude (BTC ≈ $69 000, DOGE ≈ $0.16,
/// sub-penny coins). Hard-coding `toStringAsFixed(2)` collapsed sub-dollar
/// coins to `$0.00` / identical SL·Entry·TP. This picks the number of decimals
/// from the price magnitude so every asset stays readable (audit signals #5,
/// MEDIUM M9/M10).
class PriceFormatter {
  PriceFormatter._();

  /// Decimal places appropriate for a given price magnitude.
  static int decimalsFor(num? value) {
    final p = (value ?? 0).abs();
    if (p == 0) return 2;
    if (p >= 1000) return 2; // 69 000.12
    if (p >= 10) return 2; //      64.05, 575.06
    if (p >= 1) return 4; //        1.1042 (XRP), 5.0350 (TON) — TP/SL ~0.3-0.7%
    //                              moves live in the 3rd-4th decimal; 2dp
    //                              collapsed Entry=Exit (e.g. $1.10 → $1.10).
    if (p >= 0.1) return 4; //    0.1634
    if (p >= 0.01) return 5; //   0.05123
    if (p >= 0.0001) return 6; // 0.000812
    return 8; //                  0.00000012
  }

  /// Formats a price with thousands grouping. Decimal places come from
  /// [decimals] when provided (the server-driven `priceDecimals` override),
  /// otherwise from the magnitude-aware [decimalsFor] (today's behavior — so
  /// passing `null` is a no-op for every existing coin).
  /// Returns the em dash for null/non-finite values.
  static String price(num? value, {bool withSymbol = false, int? decimals}) {
    if (value == null || !value.toDouble().isFinite) return '—';
    final d = (decimals != null && decimals >= 0) ? decimals : decimalsFor(value);
    final pattern = d == 0 ? '#,##0' : '#,##0.${'0' * d}';
    final formatted = NumberFormat(pattern, 'en_US').format(value);
    return withSymbol ? '\$$formatted' : formatted;
  }

  /// Signed percent, 2 decimals, locale-neutral (e.g. `+1.23%`, `-0.45%`).
  static String percent(num? value) {
    final v = (value ?? 0).toDouble();
    if (!v.isFinite) return '0%';
    final sign = v > 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(2)}%';
  }
}

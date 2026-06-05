import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Thin wrapper around `home_widget` for our iOS widget extension.
///
/// Keys written to the shared `UserDefaults(suiteName: group.com.aspiro.trade)`:
///
/// ```
///   signal_symbol          String
///   signal_direction       String   "BUY" | "SELL"
///   signal_price           Double
///   signal_tp              Double
///   signal_sl              Double
///   signal_ts              Double   unix seconds
///   watchlist_json         String   JSON [{symbol,price,change24h}, ...]
///   recent_signals_json    String   JSON [{symbol,direction,price,ts}, ...]
///   user_is_premium        Bool
///   user_premium_until     Double   unix seconds
/// ```
class WidgetService {
  static const _appGroupId = 'group.com.aspiro.trade';
  static const _iosWidgetName = 'AspiroSignalWidget';

  static const _kMaxRecent = 5;

  static DateTime? _lastReloadTime;
  static Timer? _throttleTimer;
  static bool _hasPendingReload = false;
  static const _throttleDuration = Duration(seconds: 15);
  static String? _pendingWatchlistJson;

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  // ── Latest signal (also auto-updates recent list) ────────────
  static Future<void> pushSignal({
    required String symbol,
    required String direction,
    required double entry,
    required double price,
    required double tp,
    required double sl,
  }) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch / 1000;
      final dir = direction.toUpperCase();

      await HomeWidget.saveWidgetData<String>('signal_symbol', symbol);
      await HomeWidget.saveWidgetData<String>('signal_direction', dir);
      await HomeWidget.saveWidgetData<double>('signal_entry', entry);
      await HomeWidget.saveWidgetData<double>('signal_price', price);
      await HomeWidget.saveWidgetData<double>('signal_tp', tp);
      await HomeWidget.saveWidgetData<double>('signal_sl', sl);
      await HomeWidget.saveWidgetData<double>('signal_ts', ts);

      // Upsert into recent-signals list: remove any prior entry for the
      // same symbol+direction, then prepend the latest data. This makes
      // SignalsBloc.Update ticks idempotent (no duplicates) yet still
      // surfaces a genuinely new symbol or direction change at the top.
      final List<Map<String, dynamic>> recent =
          await _readList('recent_signals_json');
      final key = '${symbol}_$dir';
      recent.removeWhere(
        (r) => '${r['symbol']}_${r['direction']}' == key,
      );
      recent.insert(0, {
        'symbol': symbol,
        'direction': dir,
        'price': price,
        'ts': ts,
      });
      final trimmed = recent.take(_kMaxRecent).toList();
      await HomeWidget.saveWidgetData<String>(
        'recent_signals_json',
        jsonEncode(trimmed),
      );

      await _reload();
      if (kDebugMode) {
        debugPrint('[Widget] pushSignal ok — $dir $symbol @ $price');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Widget] pushSignal FAILED: $e');
    }
  }

  // ── Full recent-signals snapshot (overwrite accumulated list) ─
  static Future<void> pushRecentSignals(
    List<({String symbol, String direction, double price, DateTime ts})> items,
  ) async {
    try {
      final list = items.take(_kMaxRecent).map((x) => {
            'symbol': x.symbol,
            'direction': x.direction.toUpperCase(),
            'price': x.price,
            'ts': x.ts.millisecondsSinceEpoch / 1000,
          }).toList();
      await HomeWidget.saveWidgetData<String>(
        'recent_signals_json',
        jsonEncode(list),
      );
      await _reload();
    } catch (e) {
      if (kDebugMode) debugPrint('[Widget] pushRecentSignals FAILED: $e');
    }
  }

  // ── Watchlist snapshot ───────────────────────────────────────
  static Future<void> pushWatchlist(
    List<({String symbol, double price, double change24h})> items,
  ) async {
    try {
      final list = items
          .take(6)
          .map((x) => {
                'symbol': x.symbol,
                'price': x.price,
                'change24h': x.change24h,
              })
          .toList();
      _pendingWatchlistJson = jsonEncode(list);
      await _reload();
    } catch (e) {
      if (kDebugMode) debugPrint('[Widget] pushWatchlist FAILED: $e');
    }
  }

  // ── Premium status ───────────────────────────────────────────
  static Future<void> pushPremiumStatus({
    required bool isPremium,
    DateTime? premiumUntil,
  }) async {
    try {
      await HomeWidget.saveWidgetData<bool>('user_is_premium', isPremium);
      await HomeWidget.saveWidgetData<double>(
        'user_premium_until',
        premiumUntil == null ? 0 : premiumUntil.millisecondsSinceEpoch / 1000,
      );
      await _reload();
    } catch (e) {
      if (kDebugMode) debugPrint('WidgetService.pushPremiumStatus failed: $e');
    }
  }

  // ── Auth handoff for autonomous widget fetches ───────────────
  // The iOS widget extension reads these from the shared App Group and
  // calls GET {apiUrl}/widget/snapshot with Bearer <token> from Swift.
  static Future<void> pushAuth({
    required String? accessToken,
    required String apiUrl,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'api_url',
        apiUrl,
      );
      await HomeWidget.saveWidgetData<String>(
        'access_token',
        accessToken ?? '',
      );
      await _reload();
    } catch (e) {
      if (kDebugMode) debugPrint('[Widget] pushAuth FAILED: $e');
    }
  }

  // ── Internals ────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _readList(String key) async {
    try {
      final String? s = await HomeWidget.getWidgetData<String>(key);
      if (s == null || s.isEmpty) return <Map<String, dynamic>>[];
      final decoded = jsonDecode(s);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> _reload() async {
    final now = DateTime.now();
    if (_lastReloadTime == null || now.difference(_lastReloadTime!) >= _throttleDuration) {
      _lastReloadTime = now;
      _hasPendingReload = false;
      _throttleTimer?.cancel();
      _throttleTimer = null;
      try {
        if (_pendingWatchlistJson != null) {
          await HomeWidget.saveWidgetData<String>('watchlist_json', _pendingWatchlistJson!);
          _pendingWatchlistJson = null;
          if (kDebugMode) {
            debugPrint('[Widget] pushWatchlist (throttled) saved to UserDefaults');
          }
        }
        await HomeWidget.updateWidget(name: _iosWidgetName, iOSName: _iosWidgetName);
      } catch (_) {}
    } else {
      if (!_hasPendingReload) {
        _hasPendingReload = true;
        _throttleTimer?.cancel();
        _throttleTimer = Timer(
          _throttleDuration - now.difference(_lastReloadTime!),
          () async {
            _lastReloadTime = DateTime.now();
            _hasPendingReload = false;
            try {
              if (_pendingWatchlistJson != null) {
                await HomeWidget.saveWidgetData<String>('watchlist_json', _pendingWatchlistJson!);
                _pendingWatchlistJson = null;
                if (kDebugMode) {
                  debugPrint('[Widget] pushWatchlist (throttled) saved to UserDefaults');
                }
              }
              await HomeWidget.updateWidget(name: _iosWidgetName, iOSName: _iosWidgetName);
            } catch (_) {}
          },
        );
      }
    }
  }
}

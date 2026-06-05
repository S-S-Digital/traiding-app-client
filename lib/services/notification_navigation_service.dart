import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Routes notification taps to the relevant in-app screen (audit H1).
///
/// The installed app previously did NOTHING on a notification tap — the
/// `onMessageOpenedApp` / `getInitialMessage` handlers were empty, so the whole
/// point of a "trading_signal" push (take the user to the asset) was lost.
///
/// This singleton holds the shared [AppRouter] (the same instance `main` builds
/// so it can actually navigate) and is driven from the FCM handlers. Push data
/// shape (from the notifications worker): `{type, symbol, direction, price,
/// TP, SL}`.
class NotificationNavigationService {
  NotificationNavigationService._();
  static final NotificationNavigationService instance =
      NotificationNavigationService._();

  AppRouter? _router;

  /// Wire the shared router (call once from `main`).
  void attachRouter(AppRouter router) => _router = router;

  /// Navigate based on a tapped/opened notification. Safe to call with null
  /// (cold-start `getInitialMessage` may return null) and before the navigator
  /// is mounted (guarded).
  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    final data = message.data;
    if (data['type'] != 'trading_signal') return;

    final router = _router;
    if (router == null) return;

    final symbol = (data['symbol'] ?? '').toString();
    try {
      if (symbol.isNotEmpty) {
        // Open the asset's detail screen; its bloc fetches live data by symbol,
        // so an empty Assets shell carrying just the symbol is enough.
        await router.push(AssetDetailsRoute(assets: Assets.empty(symbol)));
      }
    } catch (_) {
      // Navigator not ready yet (very early cold start) — ignore.
    }
  }
}

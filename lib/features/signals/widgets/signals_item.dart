import 'dart:math';
import 'package:aspiro_trade/features/signals/models/models.dart';
import 'package:aspiro_trade/services/config/app_config_cubit.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/methods/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignalsItem extends StatelessWidget {
  const SignalsItem({super.key, required this.signal});

  final CombinedSignal signal;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'at_tp':
      case 'in_profit':
        return AppColors.up;
      case 'at_sl':
      case 'in_loss':
        return AppColors.down;
      case 'unknown':
      default:
        return AppColors.textTertiary;
    }
  }

  // Crypto = live data via WebSocket (exchange-accurate). Non-crypto = no live
  // feed → static Entry/SL/TP only. Mirrors backend regex /USDT$|USDC$|BTC$|ETH$|BNB$/.
  static bool _isCrypto(String symbol) {
    final s = symbol.toUpperCase();
    return s.endsWith('USDT') ||
        s.endsWith('USDC') ||
        s.endsWith('BTC') ||
        s.endsWith('ETH') ||
        s.endsWith('BNB');
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.signal.direction.toLowerCase() == 'buy';
    final config = context.watch<AppConfigCubit>().state.config;
    // Live-vs-static is server-driven: a symbol shows the live price slider iff
    // its market has a live feed (`market.liveData`). Falls back to the legacy
    // `_isCrypto` regex when config hasn't resolved the symbol yet, so Phase 0
    // stays byte-identical (crypto live as today, non-crypto static as today).
    final isCrypto = config.liveDataFor(signal.signal.symbol) ??
        _isCrypto(signal.signal.symbol);
    // Server-driven decimals override (null ⇒ magnitude-aware fallback, today's
    // behavior). Read from app-config for this symbol.
    final priceDecimals =
        config.assetFor(signal.signal.symbol)?.priceDecimals;
    final profitPct = signal.signal.profitPct?.toDouble() ?? 0;
    final isProfit = profitPct >= 0;
    final isClosed = signal.signal.isClosed;

    final sl = signal.signal.stopLoss?.toDouble();
    final tp = signal.signal.takeProfit?.toDouble();
    final current = signal.signal.currentPrice?.toDouble();
    final entry = signal.signal.price.toDouble();

    // Visual ranges: Left is always Stop Loss, Right is always Take Profit
    final hasRange = sl != null && tp != null;
    
    // Progress calculation for slider.
    //
    // NOTE: we deliberately do NOT use the backend `progressPct` here. The
    // slider plots the live price on a full SL↔TP track (0 = SL, 1 = TP), but
    // backend `progressPct` measures entry→TP only and clamps loss-side moves
    // to 0 — so it can't place the dot below entry toward SL and would break
    // the loss-side visualization. The local SL↔TP ratio is direction-safe
    // (`.abs()` works for BUY and SELL) and clamped, so it stays the source of
    // truth for the dot. (audit M3 — keep local clamp.)
    double entryRatio = 0.3;
    double currentRatio = 0.5;
    if (hasRange) {
      final totalDiff = (tp - sl).abs();
      if (totalDiff > 0) {
        entryRatio = ((entry - sl).abs() / totalDiff).clamp(0.0, 1.0);
        currentRatio = current != null
            ? ((current - sl).abs() / totalDiff).clamp(0.0, 1.0)
            : entryRatio;
      }
    }

    final statusColor = _statusColor(signal.signal.signalStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left direction color stripe (BUY: Green, SELL: Red)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBuy
                        ? [AppColors.up, AppColors.up.withOpacity(0.3)]
                        : [AppColors.down, AppColors.down.withOpacity(0.3)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header (Coin logo, Pair, Timeframe, Direction, P&L) ──
                  Row(
                    children: [
                      // Circular coin avatar with sleek border glow
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Image.network(
                            signal.assets.logoUrl,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.elevated,
                              alignment: Alignment.center,
                              child: Text(
                                signal.signal.symbol.isNotEmpty ? signal.signal.symbol[0] : '?',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Pair and tags
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              signal.signal.symbol,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _DirectionPill(isBuy: isBuy),
                                const SizedBox(width: 6),
                                _TimeframePill(timeframe: signal.signal.timeframe),
                                const SizedBox(width: 6),
                                if (isClosed)
                                  _StatusPill(label: AppLocalizations.statusClosed, color: statusColor)
                                else
                                  Text(
                                    // .toLocal() so the entry chip shows the user's
                                    // wall-clock time, not the backend UTC hour (audit #6).
                                    TimeOfDay.fromDateTime(signal.signal.entryBarTime.toLocal()).format(context),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // P&L Badge with glow — CRYPTO ONLY.
                      // Non-crypto (stocks/forex/commodities) has no accurate live
                      // feed (app feed ≠ TradingView entry coords) → live % is bogus,
                      // so we hide it entirely. Non-crypto shows only Entry/SL/TP.
                      if (isCrypto)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isProfit ? AppColors.up.withOpacity(0.08) : AppColors.down.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isProfit ? AppColors.up.withOpacity(0.2) : AppColors.down.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              size: 14,
                              color: isProfit ? AppColors.up : AppColors.down,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              PriceFormatter.percent(profitPct),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isProfit ? AppColors.up : AppColors.down,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Visual Interactive Progress Slider (SL → Entry → Current → TP) ──
                  // CRYPTO ONLY. Non-crypto has no live feed → no slider (it was the
                  // thing visually breaking: stale/wrong current price drove the dot).
                  if (isCrypto && hasRange) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SL ${PriceFormatter.price(sl, decimals: priceDecimals)}', style: const TextStyle(fontSize: 10, color: AppColors.down, fontWeight: FontWeight.w600)),
                          Text('TP ${PriceFormatter.price(tp, decimals: priceDecimals)}', style: const TextStyle(fontSize: 10, color: AppColors.up, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final entryPosition = entryRatio * width;
                        final currentPosition = currentRatio * width;

                        return SizedBox(
                          height: 16,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            children: [
                              // Background track
                              Container(
                                width: width,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.elevated,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // Active segment (Entry to Current)
                              Positioned(
                                left: min(entryPosition, currentPosition),
                                width: max((entryPosition - currentPosition).abs(), 1.0),
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isProfit ? AppColors.up : AppColors.down,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isProfit ? AppColors.up : AppColors.down).withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Entry Anchor Node
                              Positioned(
                                left: entryPosition - 2,
                                child: Tooltip(
                                  message: '${AppLocalizations.entryLabel}: ${PriceFormatter.price(entry, decimals: priceDecimals)}',
                                  child: Container(
                                    width: 4,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Current price floating slider dot
                              Positioned(
                                left: currentPosition - 5,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isProfit ? AppColors.brandLight : AppColors.down,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isProfit ? AppColors.brandLight : AppColors.down).withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ] else if (isCrypto) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SL —', style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                          Text('TP —', style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Details visual grid ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.elevated.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: isCrypto
                        ? Row(
                            children: [
                              _GridCell(label: AppLocalizations.entryLabel, value: PriceFormatter.price(entry, withSymbol: true, decimals: priceDecimals), valueColor: AppColors.textPrimary),
                              Container(width: 1, height: 24, color: AppColors.border.withOpacity(0.5)),
                              _GridCell(
                                label: isClosed ? AppLocalizations.closeLabel : AppLocalizations.currentLabel,
                                value: current != null ? PriceFormatter.price(current, withSymbol: true, decimals: priceDecimals) : '—',
                                valueColor: current != null
                                    ? (isClosed
                                        ? AppColors.textPrimary
                                        : (isProfit ? AppColors.brandLight : AppColors.down))
                                    : AppColors.textPrimary,
                              ),
                            ],
                          )
                        // Non-crypto: only Entry / SL / TP — no live Current, no %, no slider.
                        : Row(
                            children: [
                              _GridCell(label: AppLocalizations.entryLabel, value: PriceFormatter.price(entry, withSymbol: true, decimals: priceDecimals), valueColor: AppColors.textPrimary),
                              Container(width: 1, height: 24, color: AppColors.border.withOpacity(0.5)),
                              _GridCell(label: 'SL', value: sl != null ? PriceFormatter.price(sl, withSymbol: true, decimals: priceDecimals) : '—', valueColor: AppColors.down),
                              Container(width: 1, height: 24, color: AppColors.border.withOpacity(0.5)),
                              _GridCell(label: 'TP', value: tp != null ? PriceFormatter.price(tp, withSymbol: true, decimals: priceDecimals) : '—', valueColor: AppColors.up),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionPill extends StatelessWidget {
  const _DirectionPill({required this.isBuy});
  final bool isBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isBuy ? AppColors.up.withOpacity(0.08) : AppColors.down.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isBuy ? AppColors.up.withOpacity(0.2) : AppColors.down.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isBuy ? AppColors.up : AppColors.down,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isBuy ? AppColors.up.withOpacity(0.6) : AppColors.down.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isBuy ? AppLocalizations.directionLong : AppLocalizations.directionShort,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isBuy ? AppColors.up : AppColors.down,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeframePill extends StatelessWidget {
  const _TimeframePill({required this.timeframe});
  final String timeframe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.elevated.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        timeframe.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.label, required this.value, required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

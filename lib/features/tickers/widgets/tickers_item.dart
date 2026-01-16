import 'dart:io' show Platform;

import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/widgets/widgets.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TickersItem extends StatelessWidget {
  const TickersItem({
    super.key,
    required this.tickers,
    required this.onSwipe,
    required this.onEdit,
  });
  final CombinedTicker tickers;
  final VoidCallback onSwipe;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool hasBuy =
        tickers.tickers.notifyBuy &&
        tickers.signals != null &&
        tickers.signals!.direction.contains('buy');

    final bool hasSell =
        tickers.tickers.notifySell &&
        tickers.signals != null &&
        tickers.signals!.direction.contains('sell');
    return Dismissible(
      key: ValueKey(tickers.tickers.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        onSwipe.call();

        return false;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025,
          vertical: size.height * 0.01,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CryptoListTile(
                      imagePath: tickers.assets.logoUrl,
                      title: tickers.tickers.symbol,
                      subtitle: tickers.assets.name,
                      size: CryptoListTileSize.large,
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Platform.isIOS
                          ? CupertinoIcons.pencil
                          : Icons.edit_outlined,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    tickers.assets.formatPriceLogic(tickers.assets.price),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: tickers.assets.priceChangePercent[0] == '-'
                          ? theme.colorScheme.error.withValues(alpha: 0.2)
                          : theme.colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '(${tickers.assets.formatPriceLogic(tickers.assets.priceChangePercent)}%)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tickers.assets.change24h[0] == '-'
                            ? theme.colorScheme.error
                            : theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    'Таймфрейм: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    tickers.tickers.formatTimeframe,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (!hasBuy && !hasSell)
                const SignalIndicator(status: SignalStatus.none)
              else ...[
                if (hasBuy) const SignalIndicator(status: SignalStatus.buy),
                if (hasSell) const SignalIndicator(status: SignalStatus.sell),
              ],
              const SizedBox(height: 5),

              // SignalChart(
              //   height: 120,
              //   candles: tickers.candles,
              //   color: tickers.tickers.notifyBuy
              //       ? theme.colorScheme.secondary
              //       : theme.colorScheme.error,
              // ),
              // const Divider(),

              // Table(
              //   // border: TableBorder.symmetric(
              //   //   inside: BorderSide(width: 0.2, color: Colors.grey),
              //   // ),
              //   columnWidths: const {
              //     0: FlexColumnWidth(0.8),
              //     1: FlexColumnWidth(0.8),
              //     2: FlexColumnWidth(0.8),
              //   },

              //   children: [
              //     TableRow(
              //       children: [
              //         Center(
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 3),
              //             child: Text(
              //               '24ч Макс',
              //               style: theme.textTheme.bodyMedium?.copyWith(
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ),
              //         ),
              //         Center(
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 3),
              //             child: Text(
              //               '24ч Мин',
              //               style: theme.textTheme.bodyMedium?.copyWith(
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ),
              //         ),
              //         Center(
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 3),
              //             child: Text(
              //               'Объём',
              //               style: theme.textTheme.bodyMedium?.copyWith(
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),

              //     TableRow(
              //       children: [
              //         Center(
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 3),
              //             child: Text(
              //               '\$${tickers.assets.formatPriceLogic(tickers.assets.high24h)}',
              //               style: theme.textTheme.bodyMedium?.copyWith(
              //                 color: theme.colorScheme.onPrimary,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //         ),
              //         Center(
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 3),
              //             child: Text(
              //               '\$${tickers.assets.formatPriceLogic(tickers.assets.low24h)}',
              //               style: theme.textTheme.bodyMedium?.copyWith(
              //                 color: theme.colorScheme.onPrimary,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //         ),
              //         Center(
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 3),
              //             child: Text(
              //               '\$${tickers.assets.formatPriceLogic(tickers.assets.volume24h)}',
              //               style: theme.textTheme.bodyMedium?.copyWith(
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

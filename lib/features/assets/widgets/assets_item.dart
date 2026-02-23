import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AssetsItem extends StatelessWidget {
  const AssetsItem({
    super.key,
    required this.asset,
    required this.onTap,
    required this.openDrawer,
  });

  final Assets asset;
  final VoidCallback onTap;
  final VoidCallback openDrawer;

  @override
  Widget build(BuildContext context) {
    final isUp = asset.change24h.isNotEmpty && !asset.change24h.startsWith('-');
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Icon ──
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.elevated,
              ),
              child: ClipOval(
                child: Image.network(
                  asset.logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      asset.baseAsset.isNotEmpty ? asset.baseAsset[0] : '?',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    asset.baseAsset,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Price + change ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  asset.price.isNotEmpty
                      ? '\$${asset.formatPriceLogic(asset.price)}'
                      : '—',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (asset.priceChangePercent.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUp
                          ? AppColors.up.withValues(alpha: 0.12)
                          : AppColors.down.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isUp ? '+' : ''}${asset.formatPriceLogic(asset.priceChangePercent)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUp ? AppColors.up : AppColors.down,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),

            // ── Add button ──
            GestureDetector(
              onTap: openDrawer,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, size: 16, color: AppColors.brand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

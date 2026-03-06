import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

enum CryptoListTileSize { small, medium, large }

class CryptoListTile extends StatelessWidget {
  const CryptoListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.size = CryptoListTileSize.medium,
    this.price,
    this.change,
    this.isPositive,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String subtitle;
  final String? imagePath;
  final CryptoListTileSize size;
  final String? price;
  final String? change;
  final bool? isPositive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  double get _iconSize {
    switch (size) {
      case CryptoListTileSize.large:
        return 40;
      case CryptoListTileSize.medium:
        return 32;
      case CryptoListTileSize.small:
        return 28;
    }
  }

  double get _titleFontSize {
    switch (size) {
      case CryptoListTileSize.large:
        return 16;
      case CryptoListTileSize.medium:
        return 14;
      case CryptoListTileSize.small:
        return 13;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          // Crypto icon
          Container(
            width: _iconSize,
            height: _iconSize,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(_iconSize / 2),
            ),
            child: imagePath != null && imagePath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(_iconSize / 2),
                    child: Image.network(
                      imagePath!,
                      width: _iconSize,
                      height: _iconSize,
                      fit: BoxFit.cover,
                      cacheWidth: (_iconSize * 2).toInt(),
                      cacheHeight: (_iconSize * 2).toInt(),
                      errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                    ),
                  )
                : _buildFallbackIcon(),
          ),
          const SizedBox(width: 12),
          // Name & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: _titleFontSize - 2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Price & change (optional)
          if (price != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (change != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ?? true)
                          ? AppColors.brand.withValues(alpha: 0.12)
                          : AppColors.down.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      change!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (isPositive ?? true)
                            ? AppColors.brand
                            : AppColors.down,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Text(
        title.isNotEmpty ? title[0] : '?',
        style: TextStyle(
          fontSize: _iconSize * 0.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

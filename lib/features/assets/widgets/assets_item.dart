import 'dart:io';

import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:flutter/cupertino.dart';
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height * 0.08,
            maxHeight: size.height * 0.4,
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,

            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      asset.logoUrl,
                      height: size.height * 0.06,

                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          // Изображение загрузилось полностью
                          return child;
                        }

                        return SizedBox(
                          height: size.height * 0.06,
                          child: Center(
                            child: Platform.isIOS
                                ? const CupertinoActivityIndicator() // Нативная "ромашка" iOS
                                : CircularProgressIndicator(
                                    // Нативное кольцо Android
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                          ),
                        );
                      },
                      // Если ошибка загрузки
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Platform.isIOS
                              ? CupertinoIcons.photo
                              : Icons.broken_image_outlined,
                          size: 40,
                          color: Colors.grey.withValues(alpha: 0.5),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              asset.symbol,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              asset.baseAsset,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        asset.price.isNotEmpty
                            ? Text(
                                '\$${asset.formatPriceLogic(asset.price)}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Text('Нет данных'),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    asset.priceChangePercent.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(2),

                            decoration: BoxDecoration(
                              color: asset.priceChangePercent[0] == '-'
                                  ? theme.colorScheme.error.withValues(
                                      alpha: 0.18,
                                    )
                                  : theme.colorScheme.secondary.withValues(
                                      alpha: 0.18,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${asset.formatPercent}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: asset.priceChangePercent[0] == '-'
                                    ? theme.colorScheme.error.withValues(
                                        alpha: 0.7,
                                      )
                                    : theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: openDrawer,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.primary,
                        ),
                        minimumSize: const WidgetStatePropertyAll(Size(50, 50)),
                      ),

                      child: Icon(
                        Platform.isIOS ? CupertinoIcons.add : Icons.add,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

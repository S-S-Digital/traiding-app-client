import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum CryptoListTileSize { small, medium, large }

class CryptoListTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final CryptoListTileSize size;

  const CryptoListTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.size = CryptoListTileSize.medium,
  });

  double get _imageSize {
    switch (size) {
      case CryptoListTileSize.small:
        return 24;
      case CryptoListTileSize.medium:
        return 32;
      case CryptoListTileSize.large:
        return 48;
    }
  }

  double get _fontSize {
    switch (size) {
      case CryptoListTileSize.small:
        return 14;
      case CryptoListTileSize.medium:
        return 16;
      case CryptoListTileSize.large:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.network(
        imagePath,
        height: _imageSize,
        width: _imageSize,
        // Настраиваем подгонку изображения, чтобы оно не искажалось
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            height: _imageSize,
            width: _imageSize,
            child: Icon(
              Platform.isIOS
                  ? CupertinoIcons.photo
                  : Icons.broken_image_outlined,

              size: _imageSize * 0.8,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          );
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: _fontSize,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(fontSize: _fontSize - 2),
      ),
    );
  }
}

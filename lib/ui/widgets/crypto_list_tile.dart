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
      leading: Image.asset(
        imagePath,
        width: _imageSize,
        height: _imageSize,
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
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: _fontSize - 2,
        ),
      ),
    );
  }
}

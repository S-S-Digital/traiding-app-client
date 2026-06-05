import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
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
    final priceValue = double.tryParse(tickers.assets.price) ?? 0;
    final hasPrice = priceValue > 0;
    final changePercent = double.tryParse(tickers.assets.priceChangePercent) ?? 0;
    final isNegative = changePercent < 0;

    return Dismissible(
      key: ValueKey(tickers.tickers.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.down.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
        ),
      ),
      confirmDismiss: (direction) async {
        onSwipe.call();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              splashColor: AppColors.brand.withOpacity(0.05),
              highlightColor: AppColors.brand.withOpacity(0.02),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: Image.network(
                          tickers.assets.logoUrl,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          cacheWidth: 84,
                          cacheHeight: 84,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              tickers.tickers.symbol.isNotEmpty ? tickers.tickers.symbol[0] : '?',
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + symbol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tickers.assets.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tickers.tickers.symbol,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.elevated,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border.withOpacity(0.5), width: 0.5),
                                ),
                                child: Text(
                                  tickers.tickers.timeframe.toUpperCase(),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                ),
                              ),
                              // Signal indicator
                              if (tickers.signals != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: tickers.signals!.direction.contains('buy') ? AppColors.up : AppColors.down,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (tickers.signals!.direction.contains('buy') ? AppColors.up : AppColors.down).withOpacity(0.6),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Sparkline mini-graph (Center)
                    if (hasPrice) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: MiniSparkline(
                          isPositive: !isNegative,
                          width: 54,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Price + change
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasPrice ? tickers.assets.formatPriceLogic(tickers.assets.price) : '—',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        if (hasPrice) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isNegative ? AppColors.down.withOpacity(0.08) : AppColors.up.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isNegative ? AppColors.down.withOpacity(0.2) : AppColors.up.withOpacity(0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isNegative ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                                  size: 11,
                                  color: isNegative ? AppColors.down : AppColors.up,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${isNegative ? '' : '+'}${tickers.assets.formatPriceLogic(tickers.assets.priceChangePercent)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isNegative ? AppColors.down : AppColors.up,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MiniSparkline extends StatelessWidget {
  const MiniSparkline({
    super.key,
    required this.isPositive,
    required this.width,
    required this.height,
  });

  final bool isPositive;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.up : AppColors.down;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(isPositive: isPositive, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final bool isPositive;
  final Color color;

  _SparklinePainter({required this.isPositive, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Create a beautiful static wave
    final points = isPositive
        ? [
            Offset(0, size.height * 0.75),
            Offset(size.width * 0.25, size.height * 0.45),
            Offset(size.width * 0.5, size.height * 0.65),
            Offset(size.width * 0.75, size.height * 0.3),
            Offset(size.width, size.height * 0.15),
          ]
        : [
            Offset(0, size.height * 0.2),
            Offset(size.width * 0.25, size.height * 0.5),
            Offset(size.width * 0.5, size.height * 0.3),
            Offset(size.width * 0.75, size.height * 0.65),
            Offset(size.width, size.height * 0.8),
          ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < points.length - 1; i++) {
      final xc = (points[i].dx + points[i + 1].dx) / 2;
      final yc = (points[i].dy + points[i + 1].dy) / 2;
      path.quadraticBezierTo(points[i].dx, points[i].dy, xc, yc);
    }
    path.lineTo(points.last.dx, points.last.dy);

    // Subtle area gradient underneath the path
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.12),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.isPositive != isPositive || oldDelegate.color != color;
}


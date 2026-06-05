import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
import 'package:aspiro_trade/features/analytics/view/asset_analytics_section.dart';
import 'package:aspiro_trade/features/asset_details/bloc/asset_details_bloc.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart'
    as assets_bloc;
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({super.key, required this.assets});
  final Assets assets;

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  @override
  void initState() {
    context.read<AssetDetailsBloc>().add(
      Start(symbol: widget.assets.symbol.toString()),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              widget.assets.symbol,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: false,
            pinned: true,
            surfaceTintColor: Colors.transparent,
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                context.read<AssetDetailsBloc>().add(StopTimer());
                context.read<assets_bloc.AssetsBloc>().add(assets_bloc.Start());
                AutoRouter.of(context).back();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocConsumer<AssetDetailsBloc, AssetDetailsState>(
              listener: (context, state) {
                if (state.status == Status.failure) {
                  if (state.error is AppException) {
                    final error = state.error as AppException;
                    context.handleException(error, context);
                  }
                }
              },
              buildWhen: (previous, current) => current.status.isBuildable,
              builder: (context, state) {
                if (state.status == Status.loading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: PlatformProgressIndicator()),
                  );
                }
                if (state.status != Status.initial) {
                  return _AssetBody(
                    assets: state.assets,
                    originalAssets: widget.assets,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Premium per-asset AI analytics (backend Task #3). Crypto-only — the
          // analytics job covers the 7 prod pairs; non-crypto is being disabled.
          if (_isCryptoSymbol(widget.assets.symbol))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: AssetAnalyticsSection(symbol: widget.assets.symbol),
              ),
            ),
        ],
      ),
    );
  }

  static bool _isCryptoSymbol(String symbol) {
    final s = symbol.toUpperCase();
    return s.endsWith('USDT') ||
        s.endsWith('USDC') ||
        s.endsWith('BTC') ||
        s.endsWith('ETH') ||
        s.endsWith('BNB');
  }
}

class _AssetBody extends StatelessWidget {
  const _AssetBody({required this.assets, required this.originalAssets});
  final Assets assets;
  final Assets originalAssets;

  @override
  Widget build(BuildContext context) {
    final isUp = !assets.change24h.startsWith('-');
    return Column(
      children: [
        const SizedBox(height: 10),
        // ── Icon + Name ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.elevated,
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    assets.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        assets.baseAsset.isNotEmpty
                            ? assets.baseAsset[0]
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assets.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    assets.baseAsset,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // ── Price centered ──
        Text(
          assets.price.isEmpty
              ? AppLocalizations.noData
              : '\$${assets.formatPriceLogic(assets.price)}',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.8,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        if (assets.price.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${isUp ? '+' : ''}\$${assets.formatPriceLogic(assets.change24h)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUp ? AppColors.up : AppColors.down,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isUp ? AppColors.up.withOpacity(0.08) : AppColors.down.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUp ? AppColors.up.withOpacity(0.2) : AppColors.down.withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${isUp ? '+' : ''}${assets.formatPriceLogic(assets.priceChangePercent)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUp ? AppColors.up : AppColors.down,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 32),

        // ── Market Stats ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MARKET STATS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              _StatRow(
                label: 'Volume 24h',
                value: '\$${assets.formatPriceLogic(assets.volume24h)}',
              ),
              Container(height: 0.8, color: AppColors.border.withOpacity(0.2)),
              _StatRow(
                label: '24h High',
                value: '\$${assets.formatPriceLogic(assets.high24h)}',
                valueColor: AppColors.up,
              ),
              Container(height: 0.8, color: AppColors.border.withOpacity(0.2)),
              _StatRow(
                label: '24h Low',
                value: '\$${assets.formatPriceLogic(assets.low24h)}',
                valueColor: AppColors.down,
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // ── Add ticker button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brand, AppColors.brandLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.card,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => AddTickersScreen(assets: originalAssets),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.addTicker,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

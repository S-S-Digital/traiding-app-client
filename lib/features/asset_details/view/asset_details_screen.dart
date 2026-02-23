import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
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
        ],
      ),
    );
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
        // ── Icon + Name ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border, width: 1),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assets.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    assets.baseAsset,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Price centered ──
        Text(
          assets.price.isEmpty
              ? 'Нет данных'
              : '\$${assets.formatPriceLogic(assets.price)}',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        if (assets.price.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${isUp ? '+' : ''}\$${assets.formatPriceLogic(assets.change24h)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isUp ? AppColors.up : AppColors.down,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUp
                      ? AppColors.up.withValues(alpha: 0.12)
                      : AppColors.down.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isUp ? '+' : ''}${assets.formatPriceLogic(assets.priceChangePercent)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUp ? AppColors.up : AppColors.down,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // ── Market Stats ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MARKET STATS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _StatRow(
                label: 'Volume 24h',
                value: '\$${assets.formatPriceLogic(assets.volume24h)}',
              ),
              Container(height: 1, color: AppColors.border),
              _StatRow(
                label: '24h High',
                value: '\$${assets.formatPriceLogic(assets.high24h)}',
                valueColor: AppColors.up,
              ),
              Container(height: 1, color: AppColors.border),
              _StatRow(
                label: '24h Low',
                value: '\$${assets.formatPriceLogic(assets.low24h)}',
                valueColor: AppColors.down,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ── Add ticker button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.card,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => AddTickersScreen(assets: originalAssets),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Добавить тикер',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

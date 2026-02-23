import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart';
import 'package:aspiro_trade/features/assets/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    context.read<AssetsBloc>().add(Start());
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Market',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: false,
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                context.read<AssetsBloc>().add(StopTimer());
                AutoRouter.of(context).pushAndPopUntil(
                  const HomeRoute(),
                  predicate: (value) => false,
                );
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchTextField(
                        controller: _searchController,
                        onClearTap: () =>
                            context.read<AssetsBloc>().add(Start()),
                        onSubmitted: (_) => _doSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _doSearch,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Column headers ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'NAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textQuaternary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'PRICE / 24H',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textQuaternary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Asset list ──
          BlocConsumer<AssetsBloc, AssetsState>(
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
                return const SliverFillRemaining(
                  child: Center(child: PlatformProgressIndicator()),
                );
              }
              if (state.status != Status.initial && state.assets.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: List.generate(state.assets.length, (i) {
                        final asset = state.assets[i];
                        return Column(
                          children: [
                            if (i > 0)
                              Container(
                                height: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                color: AppColors.border,
                              ),
                            AssetsItem(
                              asset: asset,
                              onTap: () {
                                context.read<AssetsBloc>().add(StopTimer());
                                AutoRouter.of(context)
                                    .push(AssetDetailsRoute(assets: asset));
                              },
                              openDrawer: () {
                                context.read<AssetsBloc>().add(StopTimer());
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.card,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (_) =>
                                      AddTickersScreen(assets: asset),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              }
              if (state.status != Status.initial && state.assets.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.card,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.search_off,
                            size: 28,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ничего не найдено',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter();
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _doSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<AssetsBloc>().add(SearchAsset(symbol: query));
    }
  }
}

import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart';
import 'package:aspiro_trade/features/assets/widgets/widgets.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;

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

    if (context.mounted) {}
    super.dispose();
  }

  void _onTapSearch(BuildContext context) {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<AssetsBloc>().add(SearchAsset(symbol: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Регистрация тикеров',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor.withValues(
              alpha: 1.25,
            ),
            toolbarHeight: 40,
            centerTitle: true,
            pinned: true,
            snap: true,
            floating: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                context.read<AssetsBloc>().add(StopTimer());
                AutoRouter.of(context).pushAndPopUntil(
                  const HomeRoute(),
                  predicate: (value) => false,
                );
              },
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              ),
            ),
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(95),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SearchTextField(
                        controller: _searchController,
                        onClearTap: () {
                          context.read<AssetsBloc>().add(Start());
                        },
                        onSubmitted: (value) => _onTapSearch(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        context.read<AssetsBloc>().add(
                          SearchAsset(symbol: _searchController.text.trim()),
                        );
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Platform.isIOS
                              ? CupertinoIcons.search
                              : Icons.search_outlined,

                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Популярные монеты',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          BlocConsumer<AssetsBloc, AssetsState>(
            listener: (context, state) {
              if (state is AssetsFailure) {
                final error = state.error;
                context.handleException(error, context);
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is AssetsLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: PlatformProgressIndicator()),
                );
              }
              if (state is AssetsLoaded) {
                return SliverList.builder(
                  itemCount: state.assets.length,
                  itemBuilder: (context, index) {
                    final asset = state.assets[index];
                    return AssetsItem(
                      asset: asset,
                      onTap: () {
                        context.read<AssetsBloc>().add(StopTimer());
                        AutoRouter.of(
                          context,
                        ).push(AssetDetailsRoute(assets: asset));
                      },
                      openDrawer: () {
                        context.read<AssetsBloc>().add(StopTimer());
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddTickersScreen(assets: asset),
                        );
                      },
                    );
                  },
                );
              }
              return const SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }
}

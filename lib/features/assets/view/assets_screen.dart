import 'package:aspiro_trade/features/add_tickers/view/view.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart';
import 'package:aspiro_trade/repositories/core/exceptions/app_exception.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/methods/methods.dart';
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

  void _onTapSearch(BuildContext context) {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<AssetsBloc>().add(SearchAsset(symbol: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
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
                        child: Icon(Icons.search),
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
                showErrorDialog(context, state.error.message, 'Ок', () {
                  if (state.error is UnauthorizedException) {
                    AutoRouter.of(context).pushAndPopUntil(
                      LoginRoute(),
                      predicate: (value) => false,
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                });
              }
            },
            builder: (context, state) {
              if (state is AssetsLoading) {
                return SliverToBoxAdapter(
                  child: Center(child: PlatformProgressIndicator()),
                );
              }
              if (state is AssetsLoaded) {
                return SliverList.builder(
                  itemCount: state.assets.length,
                  itemBuilder: (context, index) {
                    final asset = state.assets[index];
                    return GestureDetector(
                      onTap: () => AutoRouter.of(
                        context,
                      ).push(AssetDetailsRoute(assets: asset)),
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 40,
                                            );
                                          },
                                    ),
                                    SizedBox(width: 10),

                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              asset.symbol,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            SizedBox(width: 7),
                                            Text(
                                              asset.baseAsset,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),

                                        Text(
                                          '\$${asset.formatPriceLogic(asset.price)}',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),

                                      decoration: BoxDecoration(
                                        color: asset.change24h[0] == '-'
                                            ? theme.colorScheme.error
                                                  .withValues(alpha: 0.18)
                                            : theme.colorScheme.secondary
                                                  .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${asset.change24h}%',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: asset.change24h[0] == '-'
                                                  ? theme.colorScheme.error
                                                        .withValues(alpha: 0.7)
                                                  : theme.colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 10),

                                    ElevatedButton(
                                      onPressed: () {
                                        
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) =>
                                              AddTickersScreen(
                                                assets: asset,
                                                
                                              ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          theme.colorScheme.primary,
                                        ),
                                        minimumSize: WidgetStatePropertyAll(
                                          const Size(50, 50),
                                        ),
                                      ),

                                      child: Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }
}

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.onClearTap,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClearTap;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  bool _showSuffix = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _showSuffix) {
      setState(() => _showSuffix = hasText);
    }
  }

  void _clearText(bool value) {
    widget.controller.clear();
    widget.onClearTap?.call();
    setState(() => _showSuffix = !value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,

      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: 'Поиск монет...',
        fillColor: theme.cardColor,

        border: OutlineInputBorder(borderSide: BorderSide.none),

        suffixIcon: _showSuffix
            ? IconButton(
                onPressed: () => _clearText(_showSuffix),
                icon: Icon(Icons.close, size: 22),
              )
            : null,
      ),
    );
  }
}

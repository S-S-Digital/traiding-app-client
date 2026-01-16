import 'package:aspiro_trade/features/tickers/bloc/bloc.dart';
import 'package:aspiro_trade/features/tickers/widgets/widgets.dart';
import 'package:aspiro_trade/features/update_tickers/view/update_tickers_screen.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TickersScreen extends StatefulWidget {
  const TickersScreen({super.key});

  @override
  State<TickersScreen> createState() => _TickersScreenState();
}

class _TickersScreenState extends State<TickersScreen> {
  @override
  void initState() {
    context.read<TickersBloc>().add(Start());
    super.initState();
  }

  @override
  void dispose() {
    talker.debug('dispose tickers');
    context.read<TickersBloc>().add(StopTimer());
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TickersBloc>().add(Refresh());
          await Future.delayed(const Duration(milliseconds: 300));
        },

        child: CustomScrollView(
          slivers: [
            BaseAppBar(
              text: 'Активы',
              onPressed: () => AutoRouter.of(context).push(const AssetsRoute()),
            ),

            BlocConsumer<TickersBloc, TickersState>(
              listener: (context, state) {
                if (state is TickersFailure) {
                  if (state.error is AppException) {
                    final error = state.error as AppException;
                    context.handleException(error, context);
                  }
                  
                }
              },
              buildWhen: (previous, current) => current.isBuildable,
              builder: (context, state) {
                

                if (state is TickersLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PlatformProgressIndicator(),
                          Text('Загрузка...'),
                        ],
                      ),
                    ),
                  );
                } else if (state is TickersLoaded) {
                  if (state.tickers.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 60,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Список тикеров пуст',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Вы можете добавить тикеры, нажав на кнопку "+" в верхнем правом углу.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList.builder(
                    itemCount: state.tickers.length,
                    itemBuilder: (context, index) {
                      return TickersItem(
                        tickers: state.tickers[index],
                        onSwipe: () async {
                          final confirmed = await showDeleteTickerDialog(
                            context,
                          );

                          if (confirmed == true && context.mounted) {
                            context.read<TickersBloc>().add(
                              DeleteTicker(id: state.tickers[index].tickers.id),
                            );
                          }
                        },
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => UpdateTickersScreen(
                              tickers: state.tickers[index],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SliverToBoxAdapter(child: Center(child: Text('data')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

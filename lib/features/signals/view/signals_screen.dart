import 'package:aspiro_trade/features/signals/bloc/signals_bloc.dart';
import 'package:aspiro_trade/features/signals/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  final List<String> filters = ['Все', 'Покупка', 'Продажа'];
  String activeFilter = 'Все';

  @override
  void initState() {
    context.read<SignalsBloc>().add(Start());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SignalsBloc>().add(Start());
        },
        child: CustomScrollView(
          slivers: [
            const BaseAppBar(text: 'Aктивные сигналы'),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: BlocBuilder<SignalsBloc, SignalsState>(
                  builder: (context, state) {
                    if (state is! SignalsLoaded || state.signals.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final activeFilter = state.activeFilter;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isActive = filter == activeFilter;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            backgroundColor: AppColors.darkBorderColor,
                            label: Text(filter),
                            showCheckmark: false,
                            selected: isActive,
                            onSelected: (_) {
                              context.read<SignalsBloc>().add(
                                ChangeFilter(filter),
                              );
                            },
                            selectedColor: theme.primaryColor,
                            labelStyle: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                            ),
                            side: BorderSide.none,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            BlocConsumer<SignalsBloc, SignalsState>(
              listener: (context, state) {
                if (state is SignalsFailure) {
                  if (state.error is AppException) {
                    final error = state.error as AppException;
                    context.handleException(error, context);
                  }
                }
              },
              builder: (context, state) {
                if (state is SignalsLoading) {
                  return const SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlatformProgressIndicator(),
                        Text('Загрузка...'),
                      ],
                    ),
                  );
                }
                if (state is SignalsLoaded) {
                  final filteredSignals = state.signals.where((signal) {
                    if (state.activeFilter == 'Все') {
                      return true;
                    }

                    if (state.activeFilter == 'Покупка') {
                      return signal.signal.direction.toLowerCase() == 'buy';
                    }

                    if (state.activeFilter == 'Продажа') {
                      return signal.signal.direction.toLowerCase() == 'sell';
                    }

                    return true;
                  }).toList();

                  return SliverList.builder(
                    itemCount: filteredSignals.length,
                    itemBuilder: (context, index) {
                      return SignalsItem(signal: filteredSignals[index]);
                    },
                  );
                }
                return const SliverToBoxAdapter();
              },
            ),
          ],
        ),
      ),
    );
  }
}

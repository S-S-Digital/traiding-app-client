import 'package:aspiro_trade/features/history/bloc/history_bloc.dart';
import 'package:aspiro_trade/features/history/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    context.read<HistoryBloc>().add(Start());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async=> context.read<HistoryBloc>().add(Start()),
        child: CustomScrollView(
          slivers: [
            const BaseAppBar(text: 'История'),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
        
            SliverToBoxAdapter(
              child: SizedBox(
                height: 70,
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoaded) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.stats.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          final stat = state.stats[index];
                          return Statistics(stat: stat);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
        
            BlocConsumer<HistoryBloc, HistoryState>(
              listener: (context, state) {
                if(state is HistoryFailure){
                  if (state.error is AppException) {
                    final error = state.error as AppException;
                    context.handleException(error, context);
                  }
                }
              },
              builder: (context, state) {
                if (state is HistoryLoading) {
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
                } else if (state is HistoryLoaded) {
                  return SliverList.builder(
                    itemCount: state.histories.length,
                    itemBuilder: (context, index) {
                      return HistoryItem(history: state.histories[index]);
                    },
                  );
                }
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Список истории пуст!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

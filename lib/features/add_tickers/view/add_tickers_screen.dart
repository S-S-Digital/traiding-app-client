import 'package:aspiro_trade/features/add_tickers/bloc/add_tickers_bloc.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AddTickersScreen extends StatefulWidget {
  const AddTickersScreen({super.key, required this.assets});
  final Assets assets;

  @override
  State<AddTickersScreen> createState() => _AddTickersScreenState();
}

class _AddTickersScreenState extends State<AddTickersScreen> {
  final List<Map<String, String>> options = const [
    {
      'title': 'Покупка и продажа',
      'subtitle': 'уведомления о всех типах сигналов',
    },
    {
      'title': 'Только покупка',
      'subtitle': 'Уведомления только о сигналах покупки',
    },
    {
      'title': 'Только продажа',
      'subtitle': 'Уведомления только о сигналах продажи',
    },
  ];

  @override
  void initState() {
    context.read<AddTickersBloc>().add(Start(symbol: widget.assets.symbol));
    super.initState();
  }

  @override
  void dispose() {
    context.read<AddTickersBloc>().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: BlocConsumer<AddTickersBloc, AddTickersState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AddTickersLoading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlatformProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Загрузка...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          }
          if (state is AddTickersLoaded) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CryptoListTile(
                  imagePath: 'assets/pictures/bitcoin.png',
                  title: widget.assets.baseAsset,
                  subtitle: widget.assets.name.toUpperCase(),
                  size: CryptoListTileSize.large,
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: state.isValid
                        ? theme.colorScheme.secondary.withOpacity(0.3)
                        : theme.colorScheme.error.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.isValid
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      state.isValid
                          ? 'Тикер найден на бирже'
                          : 'Тикер не найден на бирже',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: state.isValid
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Divider(),
                const SizedBox(height: 10),

                

                Text(
                  'Выберите таймфрейм'.toUpperCase(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 40, // высота карточки/чипа
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ['1 час', '4 часа', '1 день', '2 день'].length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final tf = ['1 час', '4 часа', '1 день', '2 день'][index];
                      final isSelected = state.selectedTimeframe == tf;
                      return ChoiceChip(
                        label: Text(tf),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<AddTickersBloc>().add(
                            SelectTimeframe(timeframe: tf),
                          );
                        },
                        showCheckmark: false,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.cardColor,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Уведомления о сигналах'.toUpperCase(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = state.selectedOption == option['title'];
                    return GestureDetector(
                      onTap: () => context.read<AddTickersBloc>().add(
                        SelectOption(option: option['title']!),
                      ),
                      child: Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.canvasColor,
                            width: 2,
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: option['title']!,
                                groupValue: state.selectedOption,
                                onChanged: (value) => context
                                    .read<AddTickersBloc>()
                                    .add(SelectOption(option: value!)),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title']!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),

                                  Text(
                                    option['subtitle']!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w700,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size(size.width, size.height * 0.07),
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      state.isValid && state.selectedOption != null
                          ? theme.colorScheme.primary
                          : theme.cardColor,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Добавить тикер'),
                ),
                SizedBox(height: 20),
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: 16),
              Text(
                'Не удалось загрузить данные',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Попробуйте еще раз!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(
                    Size(size.width, size.height * 0.06),
                  ),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.primary,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                ),
                onPressed: () => context.read<AddTickersBloc>().add(
                  Start(symbol: widget.assets.symbol),
                ),
                child: Text('Попробовать еще раз'),
              ),

              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

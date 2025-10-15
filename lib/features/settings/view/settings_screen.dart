import 'package:aspiro_trade/ui/widgets/base_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final notifications = [
    {
      'title': 'Push-уведомления',
      'subtitle': 'Получать уведомления о новых сигналах',
      'switch': true,
      'isSwitch': true,
    },
    {
      'title': 'Email уведомления',
      'subtitle': 'Отправлять сигналы на почту',
      'switch': true,
      'isSwitch': true,
    },
    {
      'title': 'Email уведомления',
      'subtitle': 'Звуковое оповещение при сигнале',
      'switch': true,
      'isSwitch': true,
    },
  ];

  final trade = [
    {
      'title': 'Автозакрытие сделок',
      'subtitle': 'Автоматически закрывать по стоп-лоссу',
      'isSwitch': true,
      'switch': true,
    },
    {
      'title': 'Стоп-лосс',
      'subtitle': 'По умолчанию: 2%',
      'isSwitch': false,
      'switch': false,
    },
    {
      'title': 'Тейк-профит',
      'subtitle': 'По умолчанию: 5%',
      'isSwitch': false,
      'switch': false,
    },
  ];

  final interfaces = [
    {
      'title': 'Язык',
      'subtitle': 'Русский',
      'isSwitch': false,
      'switch': false,
    },
    {'title': 'Валюта', 'subtitle': 'USD', 'isSwitch': false, 'switch': false},
  ];

  final account = [
    {
      'title': 'Профиль',
      'subtitle': 'Управление профилем',
      'isSwitch': false,
      'switch': false,
    },
    {
      'title': 'Подписка',
      'subtitle': 'Premium до 15.12.2025',
      'isSwitch': false,
      'switch': false,
    },
    {
      'title': 'Выйти',
      'subtitle': 'Premium до 15.12.2025',
      'isSwitch': false,
      'switch': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BaseAppBar(text: 'Настройки'),
          SettingsContainers(text: 'Уведомления', items: notifications),
          SettingsContainers(text: 'Торговля', items: trade),
          SettingsContainers(text: 'Интерфейс', items: interfaces),
          SettingsContainers(text: 'Аккаунт', items: account),
        ],
      ),
    );
  }
}

class SettingsContainers extends StatelessWidget {
  const SettingsContainers({
    super.key,
    required this.text,
    required this.items,
  });

  final List<Map<String, Object>> items;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Container(
          padding: EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                text.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  height: 1.0,
                  color: theme.hintColor,
                  fontWeight: FontWeight.w700,
                ),
              ),


              SizedBox(height: 20),

              ListView.separated(
                itemCount: items.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: 0,
                    title: Text(
                      item['title'] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item['subtitle'] as String,
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: item['isSwitch'] == true
                        ? Switch(
                            value: item['switch'] as bool,
                            onChanged: (value) {},
                          )
                        : Icon(Icons.arrow_forward_ios),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:aspiro_trade/features/privacy_policy/view/privacy_policy_screen.dart';
import 'package:aspiro_trade/features/settings/bloc/settings_bloc.dart';
import 'package:aspiro_trade/features/settings/models/models.dart';
import 'package:aspiro_trade/features/settings/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/widgets/base_app_bar.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    context.read<SettingsBloc>().add(Start());
    super.initState();
  }

  final items = [
    SettingsItems(
      title: 'Настройки профиля',
      subtitle: '',
      switchValue: false,
      isSwitch: false,
    ),
    SettingsItems(
      title: 'Условия использования',
      subtitle: '',
      switchValue: false,
      isSwitch: false,
    ),
    SettingsItems(
      title: 'Политика конфиденциальности',
      subtitle: '',
      switchValue: false,
      isSwitch: false,
    ),
    SettingsItems(
      title: 'Подписка',
      subtitle: '',
      switchValue: false,
      isSwitch: false,
    ),
    SettingsItems(
      title: 'Выйти',
      subtitle: '',
      switchValue: false,
      isSwitch: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const BaseAppBar(text: 'Настройки'),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SettingsFailure) {
                if (state.error is AppException) {
                  final error = state.error as AppException;
                  context.handleException(error, context);
                }
              } else if (state is Close) {
                AutoRouter.of(context).pushAndPopUntil(
                  const LoginRoute(),
                  predicate: (value) => false,
                );
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is SettingsLoaded) {
                return SliverToBoxAdapter(child: UserCard(users: state.users));
              }
              return const SliverToBoxAdapter();
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          SliverList.separated(
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),

            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SettingsItem(
                  item: item,
                  onTap: () {
                    switch (index) {
                      case 0:
                        AutoRouter.of(context).push(const ProfileRoute());
                        break;
                      case 1:
                        AutoRouter.of(context).push(const TermsOfUseRoute());
                        break;
                      case 2:
                        AutoRouter.of(context).push(const PrivacyPolicyRoute());
                        break;
                      case 3:
                        AutoRouter.of(context).push(const SubscriptionRoute());
                        break;
                      case 4:
                        showExitDialog(context, () {
                          context.read<SettingsBloc>().add(Exit());
                        });
                    }
                  },
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 70)),

          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoaded) {
                return SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Версия: ${state.appVersion}'),
                      Text('(сборка: ${state.build})'),
                    ],
                  ),
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

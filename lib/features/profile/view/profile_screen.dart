import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/features/profile/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    context.read<ProfileCubit>().start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(title: Text('Профиль'), centerTitle: true),

          BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileFailure) {
                if (state.error is AppException) {
                  final error = state.error as AppException;
                  context.handleException(error, context);
                }
              }
              if (state is DeleteSuccess) {
                AutoRouter.of(context).pushAndPopUntil(
                  const LoginRoute(),
                  predicate: (value) => false,
                );
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      UserCard(users: state.users),
                      LimitCard(limits: state.limits),
                    ],
                  ),
                );
              }
              return const SliverToBoxAdapter();
            },
          ),

          SliverToBoxAdapter(
            child: Center(
              child: TextButton(
                onPressed: () async {
                  final isConfirmed = await context.showDeleteAccountDialog(
                    context,
                  );

                  if (!mounted) return;

                  if (isConfirmed == true) {
                    context.read<ProfileCubit>().deleteAccount();
                  }
                },

                child: Text(
                  'Удалить аккаунт',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkAccentRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.users});

  final Users users;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsetsGeometry.all(15),
      padding: const EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: size.height * 0.07,
                child: Icon(Icons.person, size: size.height * 0.07),
              ),

              const SizedBox(width: 20),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    users.email,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  subtitle: Text(
                    users.phoneFormatted,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'План: ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                users.isPremium ? 'Премиум' : 'Базовый',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Премиум до: ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                users.premiumUntilFormatted,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

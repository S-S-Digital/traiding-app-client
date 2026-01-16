import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.users});

  final Users users;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),

              leading: CircleAvatar(
                radius: size.height * 0.03,
                backgroundColor: theme.primaryColor,
                child: Icon(Icons.person, size: size.height * 0.03),
              ),
              title: Text(
                users.email,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                users.phone,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

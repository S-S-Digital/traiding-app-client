import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget {
  const BaseAppBar({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      title: Text(
        text,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        onPressed != null
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(theme.primaryColor),
                    minimumSize: WidgetStatePropertyAll(const Size(50, 50))
                  ),
                  onPressed: onPressed,
                  child: Icon(Icons.add)
                ),
            )
            : SizedBox(),
      ],
    );
  }
}

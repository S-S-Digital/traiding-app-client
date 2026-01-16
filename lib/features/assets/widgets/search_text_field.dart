
import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.onClearTap,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClearTap;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  bool _showSuffix = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _showSuffix) {
      setState(() => _showSuffix = hasText);
    }
  }

  void _clearText(bool value) {
    widget.controller.clear();
    widget.onClearTap?.call();
    setState(() => _showSuffix = !value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,

      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: 'Поиск монет...',
        fillColor: theme.cardColor,

        border: const OutlineInputBorder(borderSide: BorderSide.none),

        suffixIcon: _showSuffix
            ? IconButton(
                onPressed: () => _clearText(_showSuffix),
                icon: const Icon(Icons.close, size: 22),
              )
            : null,
      ),
    );
  }
}

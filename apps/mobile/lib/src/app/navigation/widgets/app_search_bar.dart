import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  final String initialValue;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      child: TextFormField(
        key: const ValueKey('global-search-field'),
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        maxLines: 2,
        minLines: 1,
        style: Theme.of(context).textTheme.titleMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintMaxLines: 1,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
          suffixIcon: Icon(
            Icons.search,
            size: 32,
            color: colorScheme.onSurface,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: colorScheme.onSurface, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: AppColors.blue, width: 1.8),
          ),
        ),
      ),
    );
  }
}

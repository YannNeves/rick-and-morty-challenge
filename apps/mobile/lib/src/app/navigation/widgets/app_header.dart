import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      surfaceTintColor: Colors.transparent,
      title: SvgPicture.asset(
        'assets/branding/logo_a.svg',
        width: 180,
        semanticsLabel: 'Rick and Morty',
      ),
      actions: [
        IconButton(
          key: const ValueKey('theme-toggle'),
          tooltip: isDark ? 'Ativar modo claro' : 'Ativar modo escuro',
          onPressed: onToggleTheme,
          icon: SvgPicture.asset(
            isDark ? 'assets/branding/sun.svg' : 'assets/branding/moon.svg',
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

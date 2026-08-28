import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppColors.black : AppColors.white;
    final foreground = isDark ? AppColors.white : AppColors.black;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.blue,
        onPrimary: AppColors.white,
        secondary: AppColors.blue,
        onSecondary: AppColors.white,
        error: const Color(0xFFBA1A1A),
        onError: AppColors.white,
        surface: background,
        onSurface: foreground,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(bodyColor: foreground, displayColor: foreground),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeepNight,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF402D00),
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: Color(0xFF533C00),
      secondary: AppColors.primary,
      onSecondary: Color(0xFF402D00),
      surface: AppColors.surfaceCard,
      onSurface: AppColors.inkPrimary,
      surfaceContainerHighest: AppColors.surfaceInset,
      error: AppColors.liveRed,
      onError: Colors.white,
      outline: AppColors.borderMedium,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.inkPrimary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.inkPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.inkPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.inkPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.inkMuted),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.inkPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderMedium, width: 1),
      ),
    ),
  );
}

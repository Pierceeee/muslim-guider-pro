import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeepNight,
      canvasColor: AppColors.bgDeepNight,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryContainer,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        outline: AppColors.borderMedium,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headlineXl(),
        displayMedium: AppTextStyles.headlineLg(),
        headlineMedium: AppTextStyles.headlineMd(),
        titleLarge: AppTextStyles.headlineMd(),
        bodyLarge: AppTextStyles.bodyLg(),
        bodyMedium: AppTextStyles.bodyMd(),
        labelSmall: AppTextStyles.labelCaps(),
      ),
      iconTheme: const IconThemeData(color: AppColors.inkMuted, size: 22),
      dividerColor: AppColors.borderMedium,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

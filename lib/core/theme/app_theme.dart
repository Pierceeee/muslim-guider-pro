import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Wires the design-token files into a Material 3 [ThemeData] instance.
///
/// The app is dark-by-default — `prototype/` doesn't define a light theme,
/// so we don't either. If/when a light theme is needed (e.g. for a
/// printable admin view), add a `light()` factory alongside [dark].
abstract final class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeepNight,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.bgDeepNight,
        error: AppColors.error,
        onError: AppColors.errorContainer,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: AppTypography.materialTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      iconTheme: const IconThemeData(color: AppColors.inkPrimary),
      dividerColor: AppColors.borderLow,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
    );
  }
}

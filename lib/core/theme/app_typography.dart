import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale lifted from `prototype/screens/*.html` Tailwind config and
/// inline class names (`font-headline-xl`, `font-body-md`, etc.).
///
/// Instrument Sans is the headline family; DM Sans is the body family.
/// Material Symbols Outlined is the icon font (used directly by the
/// `material_symbols_icons` package — no TextStyle needed here).
abstract final class AppTypography {
  // ── Headlines (Instrument Sans 700) ─────────────────────────────────
  static TextStyle headlineXl = GoogleFonts.instrumentSans(
    fontWeight: FontWeight.w700,
    fontSize: 64,
    height: 1,
    color: AppColors.primary,
  );

  static TextStyle headlineLg = GoogleFonts.instrumentSans(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.15,
    color: AppColors.inkPrimary,
  );

  static TextStyle headlineMd = GoogleFonts.instrumentSans(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.2,
    color: AppColors.inkPrimary,
  );

  // ── Numerals (tabular, Instrument Sans) ─────────────────────────────
  static TextStyle numeralTime = GoogleFonts.instrumentSans(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    color: AppColors.inkPrimary,
  );

  // ── Body (DM Sans) ──────────────────────────────────────────────────
  static TextStyle bodyLg = GoogleFonts.dmSans(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.dmSans(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.dmSans(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.4,
    color: AppColors.inkMuted,
  );

  // ── Labels (uppercase, tracked) ─────────────────────────────────────
  static TextStyle labelCaps = GoogleFonts.dmSans(
    fontWeight: FontWeight.w500,
    fontSize: 10,
    letterSpacing: 2,
    color: AppColors.inkMuted,
  );

  /// Returns a [TextTheme] wiring all of the above into Material's slots so
  /// `Theme.of(context).textTheme.bodyMedium` etc. just works on every screen.
  static TextTheme materialTextTheme() {
    return TextTheme(
      displayLarge: headlineXl,
      displayMedium: headlineXl.copyWith(fontSize: 48),
      headlineLarge: headlineLg,
      headlineMedium: headlineMd,
      headlineSmall: headlineMd.copyWith(fontSize: 18),
      titleLarge: headlineMd,
      titleMedium: bodyLg.copyWith(fontWeight: FontWeight.w700),
      titleSmall: bodyMd.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      bodySmall: bodySm,
      labelLarge: bodyMd.copyWith(fontWeight: FontWeight.w500),
      labelMedium: labelCaps.copyWith(fontSize: 11),
      labelSmall: labelCaps,
    );
  }
}

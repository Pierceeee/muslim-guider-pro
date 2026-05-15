import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle headlineXl({Color color = AppColors.inkPrimary}) =>
      GoogleFonts.instrumentSans(
        fontSize: 40,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.inkPrimary}) =>
      GoogleFonts.instrumentSans(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.28,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.inkPrimary}) =>
      GoogleFonts.instrumentSans(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.dmSans(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: color);

  static TextStyle bodyMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.dmSans(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: color);

  static TextStyle labelCaps({Color color = AppColors.primary}) =>
      GoogleFonts.dmSans(
        fontSize: 11,
        height: 1.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.88,
        color: color,
      );

  static TextStyle numeralTime({double fontSize = 15, Color color = AppColors.primary}) =>
      GoogleFonts.instrumentSans(
        fontSize: fontSize,
        height: 1.0,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );

  static TextStyle arabic({double fontSize = 16, Color color = AppColors.inkPrimary}) =>
      GoogleFonts.notoNaskhArabic(fontSize: fontSize, height: 1.5, fontWeight: FontWeight.w500, color: color);
}

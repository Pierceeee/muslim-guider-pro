import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static final displayLarge = GoogleFonts.instrumentSans(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static final headlineLarge = GoogleFonts.dmSans(
    fontSize: 28, fontWeight: FontWeight.w700, height: 1.15,
  );
  static final headlineMedium = GoogleFonts.dmSans(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.2,
  );
  static final titleLarge = GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w500, height: 1.3,
  );
  static final bodyLarge = GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.4,
  );
  static final bodyMedium = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.4,
  );
  static final labelLarge = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.5,
  );
  static final arabic = GoogleFonts.amiri(
    fontSize: 20, fontWeight: FontWeight.w400, height: 1.5,
  );
}

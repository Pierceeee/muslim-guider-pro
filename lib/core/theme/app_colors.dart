import 'package:flutter/material.dart';

/// Design tokens lifted from the prototype Tailwind config
/// (see `prototype/screens/*.html` and `docs/BUILD_PLAN.md` §4.1).
///
/// Every color the app uses must come from here — screens never declare
/// raw hex literals. When the design system evolves, this file is the
/// single point of change.
abstract final class AppColors {
  // ── Brand / primary (gold-amber) ─────────────────────────────────────
  static const Color primary = Color(0xFFF2C050);
  static const Color primaryContainer = Color(0xFFD4A537);
  static const Color onPrimary = Color(0xFF402D00);
  static const Color primaryFixed = Color(0xFFFFDF9F);
  static const Color goldHighlight = Color(0xFFF0C75E);
  static const Color goldDeep = Color(0xFF8B6914);
  static const Color inversePrimary = Color(0xFF795900);

  // ── Surfaces ────────────────────────────────────────────────────────
  static const Color background = Color(0xFF17130C); // warm dark brown
  static const Color surface = Color(0xFF17130C);
  static const Color bgDeepNight = Color(0xFF0F1626);
  static const Color bgElevated = Color(0xFF1A2238);
  static const Color surfaceCard = Color(0xFF232C44);
  static const Color surfaceContainer = Color(0xFF231F17);
  static const Color surfaceContainerHigh = Color(0xFF2E2921);
  static const Color surfaceContainerHighest = Color(0xFF39342B);
  static const Color surfaceInset = Color(0xFF2D3658);

  // ── Ink (text) ──────────────────────────────────────────────────────
  static const Color inkPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFEBE1D4); // warm white
  static const Color inkMuted = Color(0xFFA8B0C4);
  static const Color inkSubtle = Color(0xFF6B7280);
  static const Color onSurfaceVariant = Color(0xFFD2C5B0);

  // ── Semantic / status ───────────────────────────────────────────────
  static const Color liveRed = Color(0xFFFF6B6B);
  static const Color liveRedBg = Color(0xFF3D1A1A);
  static const Color successGreen = Color(0xFF4ADE80);
  static const Color successGreenBg = Color(0xFF1A3D2A);
  static const Color warningAmber = Color(0xFFFFA94D);
  static const Color warningAmberBg = Color(0xFF3D2F0F);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color maghribOrange = Color(0xFFE8763A);
  static const Color infoBlue = Color(0xFF4FC3D9);
  static const Color purpleDeep = Color(0xFF5B2C9F);
  static const Color secondary = Color(0xFFDCB8FF);
  static const Color tertiary = Color(0xFFADC8FF);

  // ── Borders / outlines ─────────────────────────────────────────────
  static const Color borderLow = Color(0xFF2D3658);
  static const Color borderMedium = Color(0xFF3A4566);
  static const Color outline = Color(0xFF9B8F7C);
  static const Color outlineVariant = Color(0xFF4E4636);
}

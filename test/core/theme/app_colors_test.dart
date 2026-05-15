import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_colors.dart';

void main() {
  test('AppColors exposes prototype tokens', () {
    expect(AppColors.primary, const Color(0xFFF2C050));
    expect(AppColors.bgDeepNight, const Color(0xFF0F1626));
    expect(AppColors.bgElevated, const Color(0xFF1A2238));
    expect(AppColors.surfaceCard, const Color(0xFF232C44));
    expect(AppColors.goldHighlight, const Color(0xFFF0C75E));
    expect(AppColors.purpleDeep, const Color(0xFF5B2C9F));
    expect(AppColors.infoBlue, const Color(0xFF4FC3D9));
    expect(AppColors.successGreen, const Color(0xFF4ADE80));
    expect(AppColors.liveRed, const Color(0xFFFF6B6B));
    expect(AppColors.fajrPurple, const Color(0xFF5B2C9F));
    expect(AppColors.asrCyan, const Color(0xFF4FC3D9));
    expect(AppColors.maghribOrange, const Color(0xFFE8763A));
  });
}

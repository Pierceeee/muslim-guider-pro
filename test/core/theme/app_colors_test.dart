import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_colors.dart';

void main() {
  test('primary gold matches prototype token #F2C050', () {
    expect(AppColors.primary, const Color(0xFFF2C050));
  });
  test('bgDeepNight matches prototype token #0F1626', () {
    expect(AppColors.bgDeepNight, const Color(0xFF0F1626));
  });
  test('liveRed matches prototype token #FF6B6B', () {
    expect(AppColors.liveRed, const Color(0xFFFF6B6B));
  });
  test('successGreen matches prototype token #4ADE80', () {
    expect(AppColors.successGreen, const Color(0xFF4ADE80));
  });
}

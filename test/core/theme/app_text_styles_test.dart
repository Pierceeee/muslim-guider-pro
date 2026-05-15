import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_text_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('AppTextStyles exposes prototype roles', (_) async {
    expect(AppTextStyles.headlineXl().fontSize, 40);
    expect(AppTextStyles.headlineLg().fontSize, 28);
    expect(AppTextStyles.headlineMd().fontSize, 24);
    expect(AppTextStyles.bodyLg().fontSize, 16);
    expect(AppTextStyles.bodyMd().fontSize, 14);
    expect(AppTextStyles.labelCaps().fontSize, 11);
    expect(AppTextStyles.labelCaps().letterSpacing, closeTo(0.88, 0.01));
    expect(AppTextStyles.numeralTime().fontWeight, FontWeight.w700);
  });
}

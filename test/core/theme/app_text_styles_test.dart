import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_text_styles.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('displayLarge is 56pt bold for the timer', (tester) async {
    expect(AppTextStyles.displayLarge.fontSize, 56);
    expect(AppTextStyles.displayLarge.fontWeight, FontWeight.w700);
  });
  testWidgets('headlineLarge is 28pt bold', (tester) async {
    expect(AppTextStyles.headlineLarge.fontSize, 28);
    expect(AppTextStyles.headlineLarge.fontWeight, FontWeight.w700);
  });
  testWidgets('bodyLarge is 16pt regular', (tester) async {
    expect(AppTextStyles.bodyLarge.fontSize, 16);
    expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.w400);
  });
}

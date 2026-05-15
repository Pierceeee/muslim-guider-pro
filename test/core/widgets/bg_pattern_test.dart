import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim_guider_pro/core/widgets/bg_pattern.dart';

void main() {
  testWidgets('BgPattern renders a tiled SVG at low opacity', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BgPattern())));
    expect(find.byType(SvgPicture), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, closeTo(0.04, 0.001));
  });
}

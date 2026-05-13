import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/gold_glow_card.dart';
import 'package:muslim_guider_pro/core/widgets/live_indicator.dart';

void main() {
  testWidgets('GoldGlowCard renders its child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: GoldGlowCard(child: Text('inside'))),
    ));
    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('LiveIndicator shows the LIVE label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LiveIndicator()),
    ));
    expect(find.text('LIVE'), findsOneWidget);
  });
}

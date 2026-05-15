import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/mic_lock_indicator.dart';

void main() {
  testWidgets('MicLockIndicator shows IDLE label when inactive', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MicLockIndicator(active: false))));
    await tester.pump();
    expect(find.text('IDLE'), findsOneWidget);
  });

  testWidgets('MicLockIndicator shows LIVE label when active', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MicLockIndicator(active: true))));
    await tester.pump();
    expect(find.text('LIVE'), findsOneWidget);
  });
}

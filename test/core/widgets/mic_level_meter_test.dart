import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/mic_level_meter.dart';

void main() {
  testWidgets('MicLevelMeter shows MIC INPUT LEVEL label and dB readout',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MicLevelMeter(level0to1: 0.6)),
    ));
    expect(find.text('MIC INPUT LEVEL'), findsOneWidget);
    expect(find.textContaining('dB'), findsOneWidget);
  });

  testWidgets('MicLevelMeter hides dB when showDbReadout is false',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MicLevelMeter(level0to1: 0.6, showDbReadout: false)),
    ));
    expect(find.textContaining('dB'), findsNothing);
  });
}

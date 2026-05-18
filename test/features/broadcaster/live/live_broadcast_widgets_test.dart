import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/widgets/listener_counter.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/widgets/live_timer.dart';
import 'package:muslim_guider_pro/core/widgets/mic_level_meter.dart';

void main() {
  testWidgets('LiveTimer formats elapsed as mm:ss', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LiveTimer(elapsed: Duration(minutes: 2, seconds: 7))),
    ));
    expect(find.text('02:07'), findsOneWidget);
  });

  testWidgets('MicLevelMeter renders bars and label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MicLevelMeter(level0to1: 0.5, barCount: 8)),
    ));
    // REVIEW(T34): consider expanding — structural type check + label only;
    // does not verify bar count or active-segment coloring.
    expect(find.byType(MicLevelMeter), findsOneWidget);
    expect(find.text('MIC INPUT LEVEL'), findsOneWidget);
  });

  testWidgets('ListenerCounter shows current count', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ListenerCounter(count: 42)),
    ));
    expect(find.textContaining('42'), findsOneWidget);
  });
}

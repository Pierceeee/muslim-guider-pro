import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/audio_waveform.dart';

void main() {
  testWidgets('AudioWaveform renders barCount bars', (tester) async {
    final controller = StreamController<double>();
    addTearDown(controller.close);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AudioWaveform(levelStream: controller.stream, barCount: 8),
      ),
    ));
    expect(find.byType(AnimatedContainer), findsNWidgets(8));
  });

  testWidgets('AudioWaveform handles stream events without throwing', (tester) async {
    final controller = StreamController<double>();
    addTearDown(controller.close);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AudioWaveform(levelStream: controller.stream, barCount: 8),
      ),
    ));
    controller.add(0.5);
    controller.add(1.0);
    controller.add(0.0);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

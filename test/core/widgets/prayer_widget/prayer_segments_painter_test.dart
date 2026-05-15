import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/prayer_segments_painter.dart';

void main() {
  testWidgets('PrayerSegmentsPainter renders without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox.square(
          dimension: 330,
          child: CustomPaint(painter: PrayerSegmentsPainter()),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  test('shouldRepaint reflects rotation changes', () {
    final a = PrayerSegmentsPainter();
    final b = PrayerSegmentsPainter(rotation: 0);
    expect(a.shouldRepaint(b), isTrue);
  });
}

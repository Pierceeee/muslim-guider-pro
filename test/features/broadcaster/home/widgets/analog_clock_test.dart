import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/analog_clock.dart';

void main() {
  testWidgets('AnalogClock renders at the given size', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: SizedBox.square(
        dimension: 240, child: AnalogClock(),
      ))),
    ));
    expect(find.byType(AnalogClock), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}

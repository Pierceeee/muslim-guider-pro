import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/big_red_broadcast_button.dart';

void main() {
  testWidgets('BigRedBroadcastButton fires onConfirmed after long press', (tester) async {
    var fired = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BigRedBroadcastButton(onConfirmed: () => fired++),
      ),
    ));

    // A short tap should NOT fire onConfirmed
    await tester.tap(find.byType(BigRedBroadcastButton));
    await tester.pump(const Duration(milliseconds: 100));
    expect(fired, 0);

    // A long press SHOULD fire onConfirmed
    final gesture = await tester.startGesture(tester.getCenter(find.byType(BigRedBroadcastButton)));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(fired, 1);
  });

  testWidgets('BigRedBroadcastButton renders the label and pulsing dot', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BigRedBroadcastButton(onConfirmed: () {})),
    ));
    expect(find.text('Tap & hold to go live'), findsOneWidget);
  });
}

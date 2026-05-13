import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/shared/slide_to_broadcast.dart';

void main() {
  testWidgets('full drag fires onConfirmed', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox(
        width: 300,
        child: SlideToBroadcast(onConfirmed: () => confirmed = true),
      )),
    ));

    final pill = tester.getRect(find.byType(SlideToBroadcast));
    await tester.dragFrom(
      pill.centerLeft + const Offset(32, 0),
      Offset(pill.width - 64, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('partial drag springs back without firing', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox(
        width: 300,
        child: SlideToBroadcast(onConfirmed: () => confirmed = true),
      )),
    ));

    final pill = tester.getRect(find.byType(SlideToBroadcast));
    await tester.dragFrom(
      pill.centerLeft + const Offset(32, 0),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
  });
}

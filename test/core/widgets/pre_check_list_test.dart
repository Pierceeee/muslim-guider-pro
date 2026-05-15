import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/pre_check_list.dart';

void main() {
  testWidgets('PreCheckList renders rows with labels and status', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PreCheckList(items: [
          PreCheckItem(label: 'Mic Connected', statusLabel: 'Ready'),
          PreCheckItem(label: 'Low Latency', statusLabel: '32ms'),
          PreCheckItem(label: 'Face ID Verified', statusLabel: 'Secure', passed: false),
        ]),
      ),
    ));
    expect(find.text('Mic Connected'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('32ms'), findsOneWidget);
    expect(find.text('Face ID Verified'), findsOneWidget);
    expect(find.text('Secure'), findsOneWidget);
  });
}

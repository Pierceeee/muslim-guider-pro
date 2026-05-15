import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/retention_chart.dart';

void main() {
  testWidgets('RetentionChart renders without error using defaults', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RetentionChart()),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(RetentionChart), findsOneWidget);
  });

  testWidgets('RetentionChart renders with custom samples', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RetentionChart(samples: [0.5, 0.4, 0.3, 0.2])),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('RetentionChart tolerates single-sample list', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RetentionChart(samples: [0.5])),
    ));
    expect(tester.takeException(), isNull);
  });
}

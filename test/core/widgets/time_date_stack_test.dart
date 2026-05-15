import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/time_date_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('TimeDateStack shows time, AM/PM, and date line', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TimeDateStack(now: DateTime(2026, 5, 7, 14, 3))),
    ));
    expect(find.text('02:03'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
    expect(find.textContaining('May 7, 2026'), findsOneWidget);
  });
}

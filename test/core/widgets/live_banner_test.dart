import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/live_banner.dart';

void main() {
  testWidgets('LiveBanner shows elapsed duration and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LiveBanner(
          elapsed: Duration(minutes: 1, seconds: 14),
          subtitle: 'Asr · 17 April',
        ),
      ),
    ));
    expect(find.textContaining('YOU ARE LIVE'), findsOneWidget);
    expect(find.textContaining('01:14'), findsOneWidget);
    expect(find.text('Asr · 17 April'), findsOneWidget);
  });

  testWidgets('LiveBanner formats hours when elapsed >= 1h', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LiveBanner(
          elapsed: Duration(hours: 1, minutes: 2, seconds: 3),
          subtitle: 'Test',
        ),
      ),
    ));
    expect(find.textContaining('01:02:03'), findsOneWidget);
  });
}

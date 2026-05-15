import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/prayer_widget.dart';

void main() {
  testWidgets('PrayerWidget builds without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PrayerWidget(size: 320))));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(PrayerWidget), findsOneWidget);
  });
}

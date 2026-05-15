import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/current_prayer_card.dart';

void main() {
  testWidgets('CurrentPrayerCard shows prayer name and from/to times', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CurrentPrayerCard(prayerName: 'Asr', fromTime: '15:47', toTime: '17:35'),
      ),
    ));
    expect(find.text('Asr Time'), findsOneWidget);
    expect(find.text('From - 15:47'), findsOneWidget);
    expect(find.text('To - 17:35'), findsOneWidget);
  });
}

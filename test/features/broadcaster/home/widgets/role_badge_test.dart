import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/maghrib_countdown.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/mic_lock_indicator.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/role_badge.dart';

void main() {
  testWidgets('RoleBadge shows the role and masjid name', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RoleBadge(masjidName: 'MASJID AL-ABRAR')),
    ));
    expect(find.text('MUADHIN'), findsOneWidget);
    expect(find.text('MASJID AL-ABRAR'), findsOneWidget);
  });

  testWidgets('MaghribCountdown formats mm:ss', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MaghribCountdown(
        remaining: Duration(minutes: 58, seconds: 20),
      )),
    ));
    expect(find.text('58:20'), findsOneWidget);
  });

  testWidgets('MicLockIndicator shows idle when not active', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MicLockIndicator(active: false)),
    ));
    expect(find.text('IDLE'), findsOneWidget);
  });
}

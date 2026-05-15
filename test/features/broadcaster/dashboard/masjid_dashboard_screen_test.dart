import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/masjid_dashboard_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Dashboard shows the masjid name, KPI grid, and recent list',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
        scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      ],
      child: const MaterialApp(home: MasjidDashboardScreen()),
    ));
    // Bounded pump — SlideToBroadcast has GestureDetector (no animation), but
    // be safe in case any child animates in future.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Masjid Al-Abrar'), findsOneWidget);
    expect(find.text("TODAY'S BROADCASTS"), findsOneWidget);
    expect(find.text('AVG LISTENERS'), findsOneWidget);
    expect(find.text('STREAM QUALITY'), findsOneWidget);
    expect(find.text('UPTIME'), findsOneWidget);
    expect(find.text('SLIDE TO BROADCAST'), findsOneWidget);
  });
}

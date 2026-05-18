import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/bg_pattern.dart';
import 'package:muslim_guider_pro/core/widgets/slide_to_broadcast.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/masjid_dashboard_screen.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/kpi_tile.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/next_broadcast_card.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/recent_broadcasts_list.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Dashboard shows the correct prototype layout',
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

    // Structural type-finders
    expect(find.byType(BgPattern), findsOneWidget);
    expect(find.byType(KpiTile), findsNWidgets(4));
    expect(find.byType(NextBroadcastCard), findsOneWidget);
    expect(find.byType(SlideToBroadcast), findsOneWidget);
    expect(find.byType(RecentBroadcastsList), findsOneWidget);

    // Header label
    expect(find.text('MUADHIN DASHBOARD'), findsOneWidget);

    // Masjid name
    expect(find.text('Masjid Al-Abrar'), findsOneWidget);

    // KPI values (hardcoded for MVP)
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('412 ms'), findsOneWidget);
    expect(find.text('47'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);

    // Section header
    expect(find.text('Recent broadcasts'), findsOneWidget);
    expect(find.text('VIEW ALL'), findsOneWidget);
  });
}

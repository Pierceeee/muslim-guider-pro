import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/bg_pattern.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/current_prayer_card.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/prayer_widget.dart';
import 'package:muslim_guider_pro/core/widgets/slide_to_broadcast.dart';
import 'package:muslim_guider_pro/core/widgets/time_date_stack.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/home_prayer_widget_screen.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/role_badge.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets(
      'Home screen renders all prototype widgets for a signed-in Muadhin',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      ],
      child: const MaterialApp(home: HomePrayerWidgetMuadhinScreen()),
    ));
    // Single pump — PrayerWidget / MicLockIndicator have infinite animations;
    // pumpAndSettle would hang.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BgPattern), findsOneWidget);
    expect(find.byType(RoleBadge), findsOneWidget);
    expect(find.byType(TimeDateStack), findsOneWidget);
    expect(find.byType(PrayerWidget), findsOneWidget);
    expect(find.byType(CurrentPrayerCard), findsOneWidget);
    expect(find.byType(SlideToBroadcast), findsOneWidget);

    // Legacy assertions kept to avoid regression
    expect(find.textContaining('MUADHIN'), findsOneWidget);
    expect(find.text('SLIDE TO BROADCAST'), findsOneWidget);
  });
}

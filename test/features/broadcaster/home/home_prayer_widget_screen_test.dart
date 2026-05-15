import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/home_prayer_widget_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Home screen renders MUADHIN badge and slide pill for a signed-in Muadhin', (tester) async {
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
    // Single pump only — AnalogClock has an infinite animation so pumpAndSettle would hang.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('MUADHIN'), findsOneWidget);
    expect(find.text('SLIDE TO BROADCAST'), findsOneWidget);
  });
}

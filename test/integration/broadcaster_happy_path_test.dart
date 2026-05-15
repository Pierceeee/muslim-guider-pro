// Happy-path integration test for the broadcaster feature.
//
// This drives the full GoRouter + Riverpod app with all repository providers
// overridden with mocks — no network, no platform channels, no physical device
// required. The test covers every screen in the broadcast loop:
//   Sign-in → Home → Dashboard → (slide) → Pre-Check → Live → Summary → Dashboard
//
// Placed under test/ so `flutter test` can run it without a connected device.
// An identical copy lives in integration_test/ for future on-device runs.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/app.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/shared/slide_to_broadcast.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Muadhin completes the broadcast loop end to end', (tester) async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      // Override with empty stream to avoid the infinite sine-wave timer leaking
      // across test teardown.
      micLevelProvider.overrideWith((_) => Stream<double>.empty()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MuslimGuiderProApp(),
    ));
    // Bounded pumps throughout — several screens carry infinite animations.
    await tester.pump(const Duration(milliseconds: 500));

    // Step 1: Sign in as Imam Yusuf.
    expect(find.text('Imam Yusuf Abdullah'), findsOneWidget);
    await tester.tap(find.text('Imam Yusuf Abdullah'));
    // Flush microtasks from selectUser → signIn → stream emit → notifyListeners
    await tester.pump();
    await tester.pump();
    // GoRouter redirect re-evaluation + slide-in animation
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Step 2: Home — MUADHIN badge confirms the Muadhin role.
    expect(find.textContaining('MUADHIN'), findsOneWidget);

    // Step 3: Navigate to Dashboard tab via bottom nav.
    await tester.tap(find.text('Dashboard'));
    await tester.pump(); // flush microtasks
    await tester.pump(); // second frame
    // Dashboard loads currentMasjidProvider (StreamProvider) — pump time for
    // the stream to emit and the widget to rebuild.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Masjid Al-Abrar'), findsOneWidget);

    // Step 4: Return to Home tab so the SlideToBroadcast widget is visible.
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 400));

    // Step 5: Slide-to-broadcast → Pre-Broadcast Check screen.
    //
    // NOTE: The SlideToBroadcast gesture cannot be reliably triggered via
    // tester.drag/fling in a widget test because the parent SingleChildScrollView
    // on HomePrayerWidgetMuadhinScreen wins the gesture arena against the
    // horizontal GestureDetector inside the slide pill. The slide widget's
    // gesture is covered by its own unit test (slide_to_broadcast_test.dart).
    //
    // Here we verify the widget is present and then trigger its onConfirmed
    // callback directly via the widget's element, which is the equivalent of
    // a successful slide — the integration test exercises every screen in the
    // loop, which is the primary goal.
    expect(find.byType(SlideToBroadcast), findsOneWidget);
    // Retrieve the widget's onConfirmed callback and invoke it directly.
    final slideWidget = tester.widget<SlideToBroadcast>(
      find.byType(SlideToBroadcast),
    );
    slideWidget.onConfirmed();
    await tester.pump(); // GoRouter push
    await tester.pump(); // second frame
    await tester.pump(const Duration(milliseconds: 400));
    // GoRouter slide-in animation.
    await tester.pump(const Duration(milliseconds: 600));

    // Step 6: Pre-Broadcast Check screen.
    expect(find.text('Pre-Broadcast Check'), findsOneWidget);

    // runFakeChecks resolves after 800 ms — pump past it.
    await tester.pump(const Duration(seconds: 1));

    // Step 7: Force mic OK via the debug button (only shown when mic ≠ ok).
    final debugBtn = find.text('Debug: force mic OK');
    expect(debugBtn, findsOneWidget);
    await tester.tap(debugBtn);
    await tester.pump(const Duration(milliseconds: 300));

    // Step 8: Continue → Live broadcast screen.
    final continueBtn = find.text('Continue');
    expect(continueBtn, findsOneWidget);
    await tester.tap(continueBtn);
    // startBroadcast is async; pushReplacement + GoRouter animation follow.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 700));

    // Step 9: Live — LiveIndicator shows "LIVE".
    expect(find.text('LIVE'), findsOneWidget);

    // Step 10: End Broadcast → confirmation dialog → tap End.
    await tester.tap(find.text('End Broadcast'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('End'), findsOneWidget);
    await tester.tap(find.text('End'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Step 11: Summary screen.
    expect(find.text('Broadcast Ended'), findsOneWidget);

    // Step 12: Done → back on Dashboard.
    await tester.tap(find.text('Done'));
    await tester.pump(); // flush microtasks
    await tester.pump(); // second frame
    // Dashboard re-loads currentMasjidProvider — pump for stream to emit.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Masjid Al-Abrar'), findsOneWidget);
  });
}

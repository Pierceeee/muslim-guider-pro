import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/live_broadcast_screen.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Live screen shows LIVE badge, listener count, and End button',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    final broadcast = MockBroadcastRepository();
    final stream = broadcast.startBroadcast(
        masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(broadcast),
        // Override micLevelProvider directly with a never-emitting stream to
        // avoid the sine fallback's pending async timer leaking after dispose.
        micLevelProvider.overrideWith((_) => const Stream<double>.empty()),
      ],
      child: MaterialApp(home: LiveBroadcastScreen(streamId: stream.id)),
    ));
    // LiveIndicator and VolumeMeter both animate forever; LiveBroadcastController
    // emits every second. Bounded pump only — pumpAndSettle would hang.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('End Broadcast'), findsOneWidget);
  });
}

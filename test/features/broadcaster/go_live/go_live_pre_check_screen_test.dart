import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/bg_pattern.dart';
import 'package:muslim_guider_pro/core/widgets/big_red_broadcast_button.dart';
import 'package:muslim_guider_pro/core/widgets/mic_level_meter.dart';
import 'package:muslim_guider_pro/core/widgets/pre_check_list.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_pre_check_screen.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

/// Shared overrides — mic stream is replaced with an empty stream so no
/// pending timers leak across test teardown.
List<Override> _overrides({MockAuthRepository? auth}) => [
      authRepositoryProvider.overrideWithValue(
          auth ?? MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider
          .overrideWithValue(MockBroadcastRepository()),
      micLevelProvider.overrideWith((_) => Stream<double>.empty()),
    ];

void main() {
  testWidgets('Pre-Check screen renders prototype visual tree', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: _overrides(auth: auth),
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(BgPattern), findsOneWidget);
    expect(find.byType(BigRedBroadcastButton), findsOneWidget);
    expect(find.byType(PreCheckList), findsOneWidget);
    expect(find.byType(MicLevelMeter), findsOneWidget);
    expect(find.text('Ready to broadcast the Athan?'), findsOneWidget);
  });

  testWidgets('Check items derived from GoLiveState are shown', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: _overrides(auth: auth),
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Microphone permission'), findsOneWidget);
    expect(find.text('Network connectivity'), findsOneWidget);
    expect(find.text('At masjid location'), findsOneWidget);
  });

  testWidgets('Settings section and toggle rows are shown', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: _overrides(auth: auth),
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Auto-archive'), findsOneWidget);
    expect(find.text('Notify subscribers'), findsOneWidget);
    expect(find.text('Asr · May 16'), findsOneWidget);
  });
}

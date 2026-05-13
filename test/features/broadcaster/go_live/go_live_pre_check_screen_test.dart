import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_pre_check_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Pre-Check screen renders three checks and Continue button',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      ],
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    // Bounded pump — checking state has a 0.8s delay; settle without
    // pumpAndSettle which could hang on CircularProgressIndicator's animation.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Microphone'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('Inside masjid radius'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Continue is disabled until allOk', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      ],
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    await tester.pump(const Duration(seconds: 1));

    final continueBtn = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(continueBtn.onPressed, isNull);
  });
}

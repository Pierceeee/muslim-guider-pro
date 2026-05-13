import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/router/app_router.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, MockAuthRepository auth) async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
    ]);
    addTearDown(container.dispose);

    final router = buildAppRouter(container);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('unauthenticated user lands on sign-in', (tester) async {
    await pumpApp(tester, MockAuthRepository());
    expect(find.text('Muslim Guider'), findsOneWidget);
    expect(find.text('Choose a profile'), findsOneWidget);
  });

  testWidgets('Muadhin lands on broadcaster home', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    await pumpApp(tester, auth);
    expect(find.text('Broadcaster Home (placeholder)'), findsOneWidget);
  });

  testWidgets('Listener lands on listener home', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_aisha');
    await pumpApp(tester, auth);
    expect(find.text('Listener Home (placeholder)'), findsOneWidget);
  });
}

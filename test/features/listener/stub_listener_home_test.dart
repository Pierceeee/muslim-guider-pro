import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/features/listener/stub_listener_home.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('StubListenerHome shows the coming-soon message', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      child: const MaterialApp(home: StubListenerHome()),
    ));
    expect(find.textContaining('Listener experience'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('Sign out clears the current user', (tester) async {
    final repo = MockAuthRepository();
    await repo.signIn('u_aisha');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: StubListenerHome()),
    ));

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(repo.currentUser, isNull);
  });
}

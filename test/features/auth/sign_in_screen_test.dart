import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/features/auth/sign_in_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('SignInScreen lists three mock users', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Imam Yusuf Abdullah'), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('Platform Admin'), findsOneWidget);
  });

  testWidgets('tapping a tile signs in via the auth repository', (tester) async {
    final repo = MockAuthRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Imam Yusuf Abdullah'));
    await tester.pumpAndSettle();

    expect(repo.currentUser?.id, 'u_imam_yusuf');
  });
}

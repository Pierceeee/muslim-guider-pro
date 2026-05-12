import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/providers/current_user_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  test('currentUserProvider emits null then the signed-in user', () async {
    final repo = MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    expect(container.read(currentUserProvider).value, isNull);

    await repo.signIn('u_imam_yusuf');
    await container.read(currentUserProvider.future);
    expect(container.read(currentUserProvider).value?.id, 'u_imam_yusuf');
  });
}

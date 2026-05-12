import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/providers/current_masjid_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  test('currentMasjidProvider is null when no user is signed in', () {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
    ]);
    addTearDown(container.dispose);
    expect(container.read(currentMasjidProvider), isNull);
  });

  test('currentMasjidProvider returns the Muadhin masjid', () async {
    final auth = MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
    ]);
    addTearDown(container.dispose);

    await auth.signIn('u_imam_yusuf');
    await Future<void>.delayed(Duration.zero);
    container.read(currentMasjidProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentMasjidProvider)?.id, 'm_al_abrar');
  });
}

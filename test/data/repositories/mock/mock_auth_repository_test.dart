import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/user.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';

void main() {
  test('signIn returns the matching mock user and emits on the stream', () async {
    final repo = MockAuthRepository();
    expect(repo.currentUser, isNull);

    final emissions = <User?>[];
    final sub = repo.watchCurrentUser().listen(emissions.add);

    final u = await repo.signIn('u_imam_yusuf');
    expect(u.role, UserRole.muadhin);
    expect(repo.currentUser?.id, 'u_imam_yusuf');

    await Future<void>.delayed(Duration.zero);
    expect(emissions.last?.id, 'u_imam_yusuf');
    await sub.cancel();
  });

  test('signIn throws on unknown id', () async {
    final repo = MockAuthRepository();
    expect(repo.signIn('nope'), throwsA(isA<StateError>()));
  });

  test('signOut clears the current user', () async {
    final repo = MockAuthRepository();
    await repo.signIn('u_imam_yusuf');
    await repo.signOut();
    expect(repo.currentUser, isNull);
  });
}

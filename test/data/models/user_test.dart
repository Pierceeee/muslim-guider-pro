import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/user.dart';

void main() {
  test('Muadhin user has a masjidId', () {
    const u = User(
      id: 'u1', displayName: 'Imam', role: UserRole.muadhin, masjidId: 'm1',
    );
    expect(u.role, UserRole.muadhin);
    expect(u.masjidId, 'm1');
  });

  test('User equality is value-based', () {
    const a = User(id: 'u1', displayName: 'A', role: UserRole.listener);
    const b = User(id: 'u1', displayName: 'A', role: UserRole.listener);
    expect(a, equals(b));
    expect(a.hashCode, b.hashCode);
  });

  test('copyWith overrides only the named field', () {
    const a = User(id: 'u1', displayName: 'A', role: UserRole.listener);
    final b = a.copyWith(displayName: 'B');
    expect(b.id, 'u1');
    expect(b.displayName, 'B');
    expect(b.role, UserRole.listener);
  });
}

import 'dart:async';

import '../../mock/mock_users.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  User? _current;
  final _controller = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> watchCurrentUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<User> signIn(String mockUserId) async {
    final match = kMockUsers.where((u) => u.id == mockUserId);
    if (match.isEmpty) {
      throw StateError('Unknown mock user id: $mockUserId');
    }
    _current = match.first;
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  List<User> availableMockUsers() => List.unmodifiable(kMockUsers);
}

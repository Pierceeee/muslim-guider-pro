import 'dart:async';

import '../../mock/mock_users.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

/// In-memory auth — accepts any non-empty credentials, "signs in" as
/// `mockUserListener` by default. Replace with `FirebaseAuthRepository`
/// in B1; consumers (Riverpod providers) only need to swap the binding.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> currentUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _current = mockUserListener;
    _controller.add(_current);
    return mockUserListener;
  }

  @override
  Future<User> signInWithProvider(String providerId) async {
    _current = mockUserListener;
    _controller.add(_current);
    return mockUserListener;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}

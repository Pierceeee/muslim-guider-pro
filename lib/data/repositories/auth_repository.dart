import '../models/user.dart';

/// Abstract auth contract. Phase F uses a mock impl; B1 swaps in
/// `FirebaseAuthRepository` without screens having to change.
abstract class AuthRepository {
  /// Currently-authenticated user, or null if signed out.
  /// Emits on every auth state transition.
  Stream<User?> currentUser();

  /// Sign in with email + password (mock impl accepts any non-empty input).
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with a federated provider (Google / Apple).
  Future<User> signInWithProvider(String providerId);

  /// Drop session, clear cached tokens.
  Future<void> signOut();
}

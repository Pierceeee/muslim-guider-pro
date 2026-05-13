import '../models/user.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> watchCurrentUser();
  Future<User> signIn(String mockUserId);
  Future<void> signOut();
  List<User> availableMockUsers();
}

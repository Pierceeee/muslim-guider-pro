import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../providers/repository_providers.dart';

class SignInState {
  const SignInState({this.busyUserId, this.error});
  final String? busyUserId;
  final String? error;

  SignInState copyWith({String? busyUserId, String? error}) =>
      SignInState(busyUserId: busyUserId, error: error);
}

class SignInController extends StateNotifier<SignInState> {
  SignInController(this._ref) : super(const SignInState());
  final Ref _ref;

  Future<User?> selectUser(String mockUserId) async {
    state = SignInState(busyUserId: mockUserId);
    try {
      final u = await _ref.read(authRepositoryProvider).signIn(mockUserId);
      state = const SignInState();
      return u;
    } on Object catch (e) {
      state = SignInState(error: e.toString());
      return null;
    }
  }
}

final signInControllerProvider =
    StateNotifierProvider<SignInController, SignInState>((ref) {
  return SignInController(ref);
});

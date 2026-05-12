import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Internal state machine for the sign-in flow.
///
/// Kept as a sealed class so screens can `switch` on the variant and the
/// compiler enforces exhaustive handling. Real flow is wired in F3.
sealed class SignInState {
  const SignInState();
}

class SignInIdle extends SignInState {
  const SignInIdle();
}

class SignInSubmitting extends SignInState {
  const SignInSubmitting();
}

class SignInSucceeded extends SignInState {
  const SignInSucceeded(this.userId);
  final String userId;
}

class SignInFailed extends SignInState {
  const SignInFailed(this.message);
  final String message;
}

/// Riverpod controller for the sign-in screen.
///
/// F3 will replace this scaffold with real flows (email/password, OTP,
/// Google/Apple SSO) talking to `AuthRepository`. For now it's an
/// idle-state notifier so the screen has a real provider to watch.
class SignInController extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInIdle();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const SignInSubmitting();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = const SignInIdle();
  }
}

final signInControllerProvider =
    NotifierProvider<SignInController, SignInState>(SignInController.new);

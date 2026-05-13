import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/repository_providers.dart';
import 'sign_in_controller.dart';
import 'widgets/mock_user_tile.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);
    final users = ref.watch(authRepositoryProvider).availableMockUsers();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text('Muslim Guider',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Choose a profile',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(state.error!,
                      style: const TextStyle(color: AppColors.liveRed),
                      textAlign: TextAlign.center),
                ),
              for (final user in users)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MockUserTile(
                    user: user,
                    busy: state.busyUserId == user.id,
                    onTap: () => ref
                        .read(signInControllerProvider.notifier)
                        .selectUser(user.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

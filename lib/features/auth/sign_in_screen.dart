import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'sign_in_controller.dart';

/// Stub for the `prototype/screens/sign-in-centered-variant.html` flow.
///
/// Real implementation lands in F3 (Onboarding & Auth). For now we only
/// render a placeholder so the route exists, the controller is wired into
/// Riverpod, and the rest of the app can navigate here without crashing.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.sectionGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Sign In', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                'prototype/screens/sign-in-centered-variant.html',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.inkMuted,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(
                'F3 placeholder — real sign-in flow (email/phone + OTP + '
                'Google/Apple SSO) lands in the Onboarding & Auth module.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const Spacer(),
              Text(
                'Controller status: ${state.runtimeType}',
                style: AppTypography.labelCaps,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bg_pattern.dart';
import '../../../core/widgets/big_red_broadcast_button.dart';
import '../../../core/widgets/mic_level_meter.dart';
import '../../../core/widgets/pre_check_list.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/mic_level_provider.dart';
import '../../../providers/repository_providers.dart';
import 'go_live_controller.dart';

class GoLivePreCheckScreen extends ConsumerStatefulWidget {
  const GoLivePreCheckScreen({super.key});

  @override
  ConsumerState<GoLivePreCheckScreen> createState() =>
      _GoLivePreCheckScreenState();
}

class _GoLivePreCheckScreenState extends ConsumerState<GoLivePreCheckScreen> {
  bool _autoArchive = true;
  bool _notifySubscribers = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goLiveControllerProvider.notifier).runFakeChecks();
      _requestMic();
    });
  }

  Future<void> _requestMic() async {
    final controller = ref.read(goLiveControllerProvider.notifier)
      ..setMic(CheckStatus.checking);
    try {
      final status = await Permission.microphone.request();
      controller.setMic(
        status.isGranted ? CheckStatus.ok : CheckStatus.failed,
      );
    } catch (_) {
      controller.setMic(CheckStatus.failed);
    }
  }

  void _startBroadcast() {
    final user = ref.read(currentUserProvider).value;
    final masjid = ref.read(currentMasjidProvider);
    if (user == null || masjid == null) return;
    final stream = ref
        .read(broadcastRepositoryProvider)
        .startBroadcast(masjidId: masjid.id, muadhinId: user.id);
    if (!mounted) return;
    context.push('${RouteNames.livePath}/${stream.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goLiveControllerProvider);
    final micLevel =
        ref.watch(micLevelProvider).maybeWhen(data: (v) => v, orElse: () => 0.0);

    final allPassed = state.allOk;
    final failedCount = [state.mic, state.network, state.geofence]
        .where((s) => s == CheckStatus.failed)
        .length;

    final checkItems = [
      PreCheckItem(
        label: 'Microphone permission',
        passed: state.mic == CheckStatus.ok,
        statusLabel: state.mic == CheckStatus.ok ? 'Granted' : 'Required',
      ),
      PreCheckItem(
        label: 'Network connectivity',
        passed: state.network == CheckStatus.ok,
        statusLabel: state.network == CheckStatus.ok ? 'Stable' : 'Offline',
      ),
      PreCheckItem(
        label: 'At masjid location',
        passed: state.geofence == CheckStatus.ok,
        statusLabel:
            state.geofence == CheckStatus.ok ? 'Verified' : 'Out of range',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Bottom layer: arabesque background
          const BgPattern(),

          // Decorative radial blur — top-right gold
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative radial blur — bottom-left purple
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purpleDeep.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top nav row
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Symbols.chevron_left,
                            color: AppColors.inkPrimary,
                            size: 26,
                          ),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const Spacer(),
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),

                  // 2. Header block
                  const SizedBox(height: 16),
                  Text(
                    'Ready to broadcast the Athan?',
                    style: AppTextStyles.headlineLg(color: AppColors.inkPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pre-broadcast checks ensure smooth performance. '
                    'Hold the broadcast button to begin.',
                    style: AppTextStyles.bodyMd(color: AppColors.inkMuted),
                  ),

                  // 3. BigRedBroadcastButton
                  const SizedBox(height: 24),
                  BigRedBroadcastButton(
                    onConfirmed: _startBroadcast,
                  ),

                  // Debug override in debug mode
                  if (kDebugMode && state.mic != CheckStatus.ok)
                    TextButton(
                      onPressed: () => ref
                          .read(goLiveControllerProvider.notifier)
                          .setMic(CheckStatus.ok),
                      child: const Text('Debug: force mic OK'),
                    ),

                  // 4. Pre-broadcast checks card
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header row with pill
                        Row(
                          children: [
                            Text(
                              'Pre-broadcast checks',
                              style: AppTextStyles.bodyLg(
                                      color: AppColors.inkPrimary)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: allPassed
                                    ? AppColors.successGreenBg
                                    : AppColors.liveRedBg,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: allPassed
                                      ? AppColors.successGreen
                                          .withValues(alpha: 0.4)
                                      : AppColors.liveRed
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                allPassed
                                    ? 'ALL PASSED'
                                    : '$failedCount ISSUE(S)',
                                style: AppTextStyles.labelCaps(
                                        color: allPassed
                                            ? AppColors.successGreen
                                            : AppColors.liveRed)
                                    .copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Check items list
                        PreCheckList(items: checkItems),

                        const SizedBox(height: 16),

                        // Mic level meter
                        MicLevelMeter(level0to1: micLevel),
                      ],
                    ),
                  ),

                  // 5. Settings section
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'BROADCAST SETTINGS',
                        style:
                            AppTextStyles.labelCaps(color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: 12),

                      // Broadcast label field
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.borderMedium),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Asr · May 16',
                              style: AppTextStyles.bodyLg(
                                  color: AppColors.inkPrimary),
                            ),
                            const Spacer(),
                            const Icon(
                              Symbols.edit,
                              color: AppColors.inkMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Toggle rows
                      _ToggleRow(
                        title: 'Auto-archive',
                        subtitle: 'Automatically save to your library',
                        value: _autoArchive,
                        onChanged: (v) => setState(() => _autoArchive = v),
                      ),
                      const SizedBox(height: 4),
                      _ToggleRow(
                        title: 'Notify subscribers',
                        subtitle: 'Send push alert to followers',
                        value: _notifySubscribers,
                        onChanged: (v) =>
                            setState(() => _notifySubscribers = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLg(color: AppColors.inkPrimary),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMd(color: AppColors.inkMuted)
                      .copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

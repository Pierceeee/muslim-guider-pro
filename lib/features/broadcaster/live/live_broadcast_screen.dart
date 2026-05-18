import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/audio_waveform.dart';
import '../../../core/widgets/bg_pattern.dart';
import '../../../core/widgets/live_banner.dart';
import '../../../core/widgets/mic_level_meter.dart';
import '../../../data/models/broadcast_stream.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/mic_level_provider.dart';
import '../../../providers/mic_level_stream_provider.dart';
import '../../../providers/repository_providers.dart';
import 'live_broadcast_controller.dart';

class LiveBroadcastScreen extends ConsumerWidget {
  const LiveBroadcastScreen({super.key, required this.streamId});
  final String streamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcastStream =
        ref.read(broadcastRepositoryProvider).findById(streamId);
    if (broadcastStream == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.broadcasterDashboard);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final masjid = ref.watch(currentMasjidProvider);
    final tick =
        ref.watch(liveBroadcastControllerProvider(broadcastStream.startedAt));
    final micLevel = ref.watch(micLevelProvider).value ?? 0.0;
    final micStream = ref.watch(micLevelStreamProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bgDeepNight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Bottom layer: background pattern
          const BgPattern(),

          // Decorative gradient orbs
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.liveRed.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purpleDeep.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. LiveBanner — full width (no horizontal padding)
                LiveBanner(
                  elapsed: tick.elapsed,
                  subtitle: 'Asr · May 16',
                ),

                // 2–5. Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 2. Masjid name + gold underline
                        Center(
                          child: Text(
                            masjid?.name ?? 'Masjid Al-Abrar',
                            style: AppTextStyles.headlineMd(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 64,
                            height: 2,
                            color: AppColors.primary,
                            margin: const EdgeInsets.only(top: 8),
                          ),
                        ),

                        // 3. AudioWaveform
                        const SizedBox(height: 32),
                        AudioWaveform(levelStream: micStream),

                        // 4. LiveStatsGrid — 3-column glass card
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.bgElevated
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.borderLow),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LISTENERS',
                                            style: AppTextStyles.labelCaps(
                                                color: AppColors.inkMuted),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${tick.listenerCount}',
                                            style:
                                                AppTextStyles.numeralTime(
                                                    fontSize: 20,
                                                    color:
                                                        AppColors.inkPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    VerticalDivider(
                                        color: AppColors.borderLow,
                                        width: 24),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LATENCY',
                                            style: AppTextStyles.labelCaps(
                                                color: AppColors.inkMuted),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '0ms', // TODO(T31): wire real latency
                                            style:
                                                AppTextStyles.numeralTime(
                                                    fontSize: 20,
                                                    color:
                                                        AppColors.inkPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    VerticalDivider(
                                        color: AppColors.borderLow,
                                        width: 24),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'HEALTH',
                                            style: AppTextStyles.labelCaps(
                                                color: AppColors.inkMuted),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Stable', // TODO(T31): wire real health
                                            style:
                                                AppTextStyles.numeralTime(
                                                    fontSize: 20,
                                                    color:
                                                        AppColors.inkPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 5. MicLevelMeter
                        const SizedBox(height: 24),
                        MicLevelMeter(level0to1: micLevel),
                      ],
                    ),
                  ),
                ),

                // 6. Bottom action row — pinned at the bottom of the outer Column
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    // Extra clearance for the FloatingPillNav on real devices.
                    MediaQuery.paddingOf(context).bottom + 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause stream (outlined)
                      OutlinedButton.icon(
                        icon: const Icon(Symbols.pause, size: 18),
                        label: const Text('Pause stream'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.inkPrimary,
                          side: const BorderSide(
                              color: AppColors.borderMedium),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          // TODO(T30): wire pause when audio recorder lands
                        },
                      ),

                      // End broadcast (red gradient pill)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(broadcastRepositoryProvider)
                                .endBroadcast(streamId, EndReason.normal);
                            // NOTE(T30): when endBroadcast becomes async, ensure context.mounted is
                            // re-checked AFTER the await — not before. Sync call today, async tomorrow.
                            if (!context.mounted) return;
                            context.pushReplacement(
                                '${RouteNames.summaryPath}/$streamId');
                          },
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFF6B6B),
                                  Color(0xFFC1272D),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.stop_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'End broadcast',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bg_pattern.dart';
import '../../../core/widgets/retention_chart.dart';
import '../../../providers/repository_providers.dart';
import '../../broadcaster/dashboard/widgets/kpi_tile.dart';

class BroadcastSummaryScreen extends ConsumerStatefulWidget {
  const BroadcastSummaryScreen({super.key, required this.streamId});
  final String streamId;

  @override
  ConsumerState<BroadcastSummaryScreen> createState() =>
      _BroadcastSummaryScreenState();
}

class _BroadcastSummaryScreenState
    extends ConsumerState<BroadcastSummaryScreen> {
  bool _saveAudio = true;
  bool _includeInDigest = true;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final stream =
        ref.read(broadcastRepositoryProvider).findById(widget.streamId);
    if (stream == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.broadcasterDashboard);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final prayerName = 'Asr Broadcast'; // TODO(T31): derive from schedule
    final durationStr = _formatDuration(stream.duration);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background layer
          const Positioned.fill(child: BgPattern()),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top success banner — full-width, no horizontal padding
                  Container(
                    color: AppColors.successGreenBg,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Symbols.mosque,
                            color: AppColors.successGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Broadcast complete ✓',
                          style: AppTextStyles.labelCaps(
                                  color: AppColors.successGreen)
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Padded rest of content
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 2. Header block
                        const SizedBox(height: 24),
                        Text(
                          prayerName,
                          style: AppTextStyles.headlineLg(
                              color: AppColors.inkPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$durationStr · ${DateFormat.yMMMd().format(stream.startedAt)} at ${DateFormat.jm().format(stream.startedAt)}',
                          style: AppTextStyles.bodyMd(
                              color: AppColors.inkMuted),
                        ),
                        // 3. 2×2 SummaryStatsGrid
                        const SizedBox(height: 24),
                        GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            KpiTile(
                              label: 'Listeners reached',
                              // TODO(T31): differentiate from peak — use totalUniqueListeners when available
                              value: stream.peakListenerCount.toString(),
                            ),
                            const KpiTile(
                              label: 'Avg latency',
                              value: '412 ms', // TODO(T31): real metric
                            ),
                            KpiTile(
                              label: 'Peak listeners',
                              value: stream.peakListenerCount.toString(),
                            ),
                            const KpiTile(
                              label: 'Stream uptime',
                              value: '100%', // TODO(T31): real metric
                            ),
                          ],
                        ),
                        // 4. RetentionChart card
                        const SizedBox(height: 24),
                        _SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Audience retention',
                                    style: AppTextStyles.bodyLg(
                                            color: AppColors.inkPrimary)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  Text(
                                    durationStr,
                                    style: AppTextStyles.labelCaps(
                                        color: AppColors.inkMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const RetentionChart(),
                            ],
                          ),
                        ),
                        // 5. "Save to archive?" card
                        const SizedBox(height: 24),
                        _SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Save to archive?',
                                style: AppTextStyles.bodyLg(
                                        color: AppColors.inkPrimary)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              _ToggleRow(
                                title: 'Save full audio',
                                subtitle:
                                    'Store the recording for later playback',
                                value: _saveAudio,
                                onChanged: (v) =>
                                    setState(() => _saveAudio = v),
                              ),
                              const SizedBox(height: 4),
                              _ToggleRow(
                                title: 'Include in monthly digest',
                                subtitle:
                                    'Feature this broadcast in the monthly summary',
                                value: _includeInDigest,
                                onChanged: (v) =>
                                    setState(() => _includeInDigest = v),
                              ),
                            ],
                          ),
                        ),
                        // 6. Action buttons
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () =>
                                  context.go(RouteNames.broadcasterDashboard),
                              child: Text(
                                'Save & finish',
                                style: AppTextStyles.bodyLg(
                                        color: AppColors.onPrimary)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.liveRed,
                                side: BorderSide(
                                    color: AppColors.liveRed
                                        .withValues(alpha: 0.4)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: const StadiumBorder(),
                              ),
                              // TODO(T31): call broadcast repository delete before navigating.
                              onPressed: () =>
                                  context.go(RouteNames.broadcasterDashboard),
                              child: Text(
                                'Discard recording',
                                style: AppTextStyles.bodyLg(
                                        color: AppColors.liveRed)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

/// Shared surface card container used within this screen.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: child,
    );
  }
}

/// A single toggle row with title + subtitle + Switch.
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    AppTextStyles.bodyMd(color: AppColors.inkPrimary),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodyMd(color: AppColors.inkMuted)
                    .copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          // TODO(T31): wire to BroadcastRepository.updateRetention.
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}

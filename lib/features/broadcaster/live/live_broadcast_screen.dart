import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/live_indicator.dart';
import '../../../data/models/broadcast_stream.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/mic_level_provider.dart';
import '../../../providers/repository_providers.dart';
import 'live_broadcast_controller.dart';
import 'widgets/listener_counter.dart';
import 'widgets/live_timer.dart';
import '../../../core/widgets/mic_level_meter.dart';

class LiveBroadcastScreen extends ConsumerWidget {
  const LiveBroadcastScreen({super.key, required this.streamId});
  final String streamId;

  Future<void> _endBroadcast(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End broadcast?'),
        content: const Text('Listeners will be disconnected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(broadcastRepositoryProvider).endBroadcast(streamId, EndReason.normal);
    if (!context.mounted) return;
    context.pushReplacement('${RouteNames.summaryPath}/$streamId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.read(broadcastRepositoryProvider).findById(streamId);
    if (stream == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.broadcasterDashboard);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final masjid = ref.watch(currentMasjidProvider);
    final tick = ref.watch(liveBroadcastControllerProvider(stream.startedAt));
    final micLevel = ref.watch(micLevelProvider).value ?? 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(alignment: Alignment.topLeft, child: LiveIndicator()),
                const SizedBox(height: 16),
                Text(masjid?.name ?? '',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Center(child: LiveTimer(elapsed: tick.elapsed)),
                const SizedBox(height: 8),
                Center(child: ListenerCounter(count: tick.listenerCount)),
                const SizedBox(height: 24),
                MicLevelMeter(level0to1: micLevel),
                const SizedBox(height: 40),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.liveRed,
                    foregroundColor: AppColors.inkPrimary,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () => _endBroadcast(context, ref),
                  child: const Text('End Broadcast'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

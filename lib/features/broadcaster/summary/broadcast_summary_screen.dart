import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gold_glow_card.dart';
import '../../../providers/repository_providers.dart';

class BroadcastSummaryScreen extends ConsumerWidget {
  const BroadcastSummaryScreen({super.key, required this.streamId});
  final String streamId;

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours.toString().padLeft(2, '0')}:$mm:$ss'
        : '$mm:$ss';
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
    final peak = stream.peakListenerCount;
    final avg = (peak * 0.7).round();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: AppColors.successGreen, size: 56),
              const SizedBox(height: 8),
              Text('Broadcast Ended',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GoldGlowCard(
                child: Column(
                  children: [
                    _row(context, 'Duration', _format(stream.duration)),
                    const Divider(),
                    _row(context, 'Peak listeners', '$peak'),
                    const Divider(),
                    _row(context, 'Average listeners', '$avg'),
                    const Divider(),
                    _row(context, 'Audio quality', 'Excellent'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(RouteNames.broadcasterDashboard),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                child: const Text('Done'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing not yet wired')),
                ),
                child: const Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

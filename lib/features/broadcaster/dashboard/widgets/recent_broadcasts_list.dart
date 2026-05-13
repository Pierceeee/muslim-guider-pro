import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gold_glow_card.dart';
import '../../../../data/models/broadcast_stream.dart';

class RecentBroadcastsList extends StatelessWidget {
  const RecentBroadcastsList({super.key, required this.entries});
  final List<BroadcastStream> entries;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return GoldGlowCard(
        child: Text('No recent broadcasts',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GoldGlowCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEE, d MMM · HH:mm')
                                .format(e.startedAt),
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text('${e.peakListenerCount} listeners · ${_format(e.duration)}',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(e.endReason?.name.toUpperCase() ?? 'ENDED',
                        style: const TextStyle(
                          fontSize: 10, letterSpacing: 1,
                          color: AppColors.successGreen,
                        )),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/gold_glow_card.dart';

class NextBroadcastCard extends StatelessWidget {
  const NextBroadcastCard({
    super.key,
    required this.prayerName,
    required this.at,
  });

  final String prayerName;
  final DateTime at;

  @override
  Widget build(BuildContext context) {
    return GoldGlowCard(
      child: Row(
        children: [
          const Icon(Icons.cell_tower, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT BROADCAST',
                    style: Theme.of(context).textTheme.labelLarge),
                Text(prayerName,
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          Text(DateFormat('HH:mm').format(at),
              style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

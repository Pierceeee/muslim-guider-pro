import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import '../../../providers/recent_broadcasts_provider.dart';
import '../../../core/widgets/slide_to_broadcast.dart';
import 'widgets/kpi_tile.dart';
import 'widgets/next_broadcast_card.dart';
import 'widgets/recent_broadcasts_list.dart';

class MasjidDashboardScreen extends ConsumerWidget {
  const MasjidDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjid = ref.watch(currentMasjidProvider);
    if (masjid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final today = DateTime.now();
    final times = ref.watch(prayerTimesProvider(
      PrayerTimesArg(date: today, masjidId: masjid.id),
    ));
    final recent = ref.watch(recentBroadcastsProvider(masjid.id));
    final next = times.nextAt(today);
    final nextAt = times.times[next]!;
    final todayCount =
        recent.where((s) => _sameDay(s.startedAt, today)).length;
    final avgListeners = recent.isEmpty
        ? 0
        : (recent.map((s) => s.peakListenerCount).reduce((a, b) => a + b) /
                recent.length)
            .round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(masjid.name,
                style: Theme.of(context).textTheme.headlineLarge),
            Text(masjid.city,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SlideToBroadcast(
              onConfirmed: () => context.push(RouteNames.goLive),
            ),
            const SizedBox(height: 16),
            NextBroadcastCard(prayerName: _prayerLabel(next), at: nextAt),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                KpiTile(label: "Today's Broadcasts", value: '$todayCount'),
                KpiTile(label: 'Avg Listeners', value: '$avgListeners'),
                const KpiTile(label: 'Stream Quality', value: 'Excellent'),
                const KpiTile(label: 'Uptime', value: '99.2%'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Recent broadcasts',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            RecentBroadcastsList(entries: recent),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _prayerLabel(Object prayer) {
    final name = prayer.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }
}

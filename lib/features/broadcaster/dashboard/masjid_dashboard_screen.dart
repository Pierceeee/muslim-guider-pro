import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/material_symbols.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bg_pattern.dart';
import '../../../core/widgets/slide_to_broadcast.dart';
import '../../../data/models/prayer_times.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import '../../../providers/recent_broadcasts_provider.dart';
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

    final nextPrayer = times.nextAt(today);
    final nextAt = times.times[nextPrayer] ?? today.add(const Duration(hours: 1));

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: BgPattern()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row ──────────────────────────────────────────
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MUADHIN DASHBOARD',
                            style: AppTextStyles.labelCaps(
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            masjid.name,
                            style: AppTextStyles.headlineLg(),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceCard,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Sym.cellTower,
                            size: 22,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── 2×2 KPI grid ─────────────────────────────────────
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      KpiTile(
                        label: 'Listeners Today',
                        value: '1,284',
                        trailingIcon: Sym.trendingUp,
                        trailingIconColor: AppColors.successGreen,
                      ),
                      KpiTile(
                        label: 'Avg Latency',
                        value: '412 ms',
                      ),
                      KpiTile(
                        label: 'Broadcasts',
                        value: '47',
                      ),
                      KpiTile(
                        label: 'Verify Score',
                        value: '98%',
                      ),
                    ],
                  ),

                  // ── Next broadcast hero card ──────────────────────────
                  const SizedBox(height: 24),
                  NextBroadcastCard(
                    prayerName: _prayerLabel(nextPrayer),
                    at: nextAt,
                    onGoLive: () => context.push(RouteNames.goLive),
                  ),

                  // ── Slide to broadcast ────────────────────────────────
                  const SizedBox(height: 24),
                  SlideToBroadcast(
                    variant: SlideToBroadcastVariant.dashboard,
                    onConfirmed: () => context.push(RouteNames.goLive),
                  ),

                  // ── Recent broadcasts section header ──────────────────
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Recent broadcasts',
                        style: AppTextStyles.headlineMd()
                            .copyWith(fontSize: 18),
                      ),
                      const Spacer(),
                      Text(
                        'VIEW ALL',
                        style: AppTextStyles.labelCaps(
                            color: AppColors.primary),
                      ),
                    ],
                  ),

                  // ── Recent broadcasts list ────────────────────────────
                  const SizedBox(height: 12),
                  RecentBroadcastsList(entries: recent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _prayerLabel(Prayer prayer) {
    final name = prayer.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

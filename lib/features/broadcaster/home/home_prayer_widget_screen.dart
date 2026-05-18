import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/prayer_format.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bg_pattern.dart';
import '../../../core/widgets/prayer_widget/current_prayer_card.dart';
import '../../../core/widgets/prayer_widget/mic_lock_indicator.dart';
import '../../../core/widgets/prayer_widget/prayer_widget.dart';
import '../../../core/widgets/slide_to_broadcast.dart';
import '../../../core/widgets/time_date_stack.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import '../../../providers/qibla_direction_provider.dart';
import 'widgets/role_badge.dart';

class HomePrayerWidgetMuadhinScreen extends ConsumerStatefulWidget {
  const HomePrayerWidgetMuadhinScreen({super.key});

  @override
  ConsumerState<HomePrayerWidgetMuadhinScreen> createState() =>
      _HomePrayerWidgetMuadhinScreenState();
}

class _HomePrayerWidgetMuadhinScreenState
    extends ConsumerState<HomePrayerWidgetMuadhinScreen> {
  @override
  Widget build(BuildContext context) {
    final masjid = ref.watch(currentMasjidProvider);
    final qibla = ref.watch(qiblaDirectionProvider((
      lat: masjid?.latitude ?? 21.4225,
      lng: masjid?.longitude ?? 39.8262,
    )));
    final now = DateTime.now();
    final times = masjid == null
        ? null
        : ref.watch(prayerTimesProvider(
            PrayerTimesArg(date: now, masjidId: masjid.id)));

    // Cache O(N) lookups — called once, reused below.
    final currentPrayer = times?.currentAt(now);
    final nextPrayer = times?.nextAt(now);

    // Derive next prayer data
    final remaining = times?.toNextAt(now) ?? Duration.zero;
    final nextPrayerName = nextPrayer != null ? prayerLabel(nextPrayer) : '—';

    // from/to for CurrentPrayerCard: current prayer start → next prayer start
    String fromTime = '—';
    String toTime = '—';
    if (times != null && currentPrayer != null && nextPrayer != null) {
      fromTime = formatPrayerTime(times.times[currentPrayer]);
      toTime = formatPrayerTime(times.times[nextPrayer]);
    }

    final currentPrayerCardName =
        currentPrayer != null ? prayerLabel(currentPrayer) : '—';

    return Scaffold(
      body: Stack(
        children: [
          // Layer 0: decorative background pattern
          const Positioned.fill(child: BgPattern()),
          // Content on top
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row ────────────────────────────────────────
                  Row(
                    children: [
                      RoleBadge(masjidName: masjid?.name ?? '...'),
                      const Spacer(),
                      // 48×48 circular profile button
                      GestureDetector(
                        onTap: () {}, // profile route out of scope
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bgElevated,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Symbols.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Time / Date ────────────────────────────────────────
                  const SizedBox(height: 16),
                  TimeDateStack(now: now),

                  // ── Prayer widget stack ────────────────────────────────
                  const SizedBox(height: 32),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Prayer circle — centred
                      Center(
                        child: PrayerWidget(
                          size: 340,
                          qiblaAngleDeg: qibla.maybeWhen(
                            data: (d) => d,
                            orElse: () => 35.0,
                          ),
                        ),
                      ),
                      // Floating left tag (overflows above)
                      Positioned(
                        left: 0,
                        top: -30,
                        child: CurrentPrayerCard(
                          prayerName: currentPrayerCardName,
                          fromTime: fromTime,
                          toTime: toTime,
                        ),
                      ),
                      // Mic-lock indicator (top-right)
                      const Positioned(
                        right: 16,
                        top: 0,
                        child: MicLockIndicator(active: false),
                      ),
                    ],
                  ),

                  // ── Slide to broadcast ────────────────────────────────
                  const SizedBox(height: 24),
                  SlideToBroadcast(
                    variant: SlideToBroadcastVariant.home,
                    onConfirmed: () => context.push(RouteNames.goLive),
                  ),

                  // ── Chevron hint ───────────────────────────────────────
                  const SizedBox(height: 16),
                  Center(
                    child: Icon(
                      Symbols.keyboard_double_arrow_up,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),

                  // ── Big countdown ──────────────────────────────────────
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Text(
                        formatHHMM(remaining),
                        style: AppTextStyles.numeralTime(
                          fontSize: 64,
                          color: AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: 'Time Remaining for Prayer: ',
                          style: AppTextStyles.bodyMd(color: AppColors.inkMuted),
                          children: [
                            TextSpan(
                              text: nextPrayerName,
                              style: AppTextStyles.bodyMd(color: AppColors.primary)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
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

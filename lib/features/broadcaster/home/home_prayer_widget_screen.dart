import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import 'widgets/analog_clock.dart';
import 'widgets/maghrib_countdown.dart';
import 'widgets/mic_lock_indicator.dart';
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
    final today = DateTime.now();
    final times = masjid == null
        ? null
        : ref.watch(prayerTimesProvider(
            PrayerTimesArg(date: today, masjidId: masjid.id)));
    final now = DateTime.now();
    final remaining = times?.toNextAt(now) ?? Duration.zero;
    final hijri = HijriCalendar.fromDate(now);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  RoleBadge(masjidName: (masjid?.name ?? '').toUpperCase()),
                  const Spacer(),
                  const MicLockIndicator(active: false),
                ],
              ),
              const SizedBox(height: 24),
              Text(DateFormat('hh:mm a').format(now),
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, d MMMM y').format(now),
                  style: Theme.of(context).textTheme.bodyLarge),
              Text(hijri.toFormat('dd MMMM yyyy'),
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              const SizedBox.square(
                dimension: 260,
                child: AnalogClock(),
              ),
              const SizedBox(height: 16),
              MaghribCountdown(
                  remaining: remaining,
                  label: 'TIME UNTIL NEXT PRAYER'),
              const SizedBox(height: 24),
              _SlidePillEntry(
                onTap: () {
                  // Real navigation lands in Task 28 (SlideToBroadcast widget +
                  // go_router push to /broadcaster/go-live). Stub for now so the
                  // screen renders.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidePillEntry extends StatelessWidget {
  const _SlidePillEntry({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Center(
        child: TextButton(
          onPressed: onTap,
          child: Text('SLIDE TO BROADCAST',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(letterSpacing: 2)),
        ),
      ),
    );
  }
}

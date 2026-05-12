import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/prayer_times.dart';
import '../../../data/providers/listener_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/prayer-schedule-birmingham.html`.
///
/// Sections (top → bottom): sticky top bar · calendar card · selected-day
/// header · prayer list · floating bottom nav.
///
/// Data: [todaysPrayerScheduleProvider] for the prayer times. "Next prayer"
/// + "in X h Y m" countdown both derive from real `DateTime.now()` against
/// the schedule — no hardcoded labels.
class PrayerScheduleScreen extends ConsumerStatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  ConsumerState<PrayerScheduleScreen> createState() =>
      _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends ConsumerState<PrayerScheduleScreen> {
  late DateTime _viewedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewedMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() => setState(() {
        _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month + 1);
      });

  void _goToToday() {
    final now = DateTime.now();
    setState(() => _viewedMonth = DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(todaysPrayerScheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: <Widget>[
                _StickyTopBar(
                  location: scheduleAsync.valueOrNull?.locationName ??
                      'Locating…',
                  onCalendarTap: _goToToday,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.containerMargin,
                    0,
                    AppSpacing.containerMargin,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CalendarCard(
                        viewedMonth: _viewedMonth,
                        today: DateTime.now(),
                        onPrev: _prevMonth,
                        onNext: _nextMonth,
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _DayHeader(date: DateTime.now()),
                      const SizedBox(height: 16),
                      scheduleAsync.when(
                        data: (schedule) => _PrayerList(schedule: schedule),
                        loading: () => const _PrayerListSkeleton(),
                        error: (e, _) =>
                            _InlineError(message: 'Schedule unavailable.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.namePrayerSchedule,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky top bar
// ─────────────────────────────────────────────────────────────────────────────

class _StickyTopBar extends StatelessWidget {
  const _StickyTopBar({
    required this.location,
    required this.onCalendarTap,
  });
  final String location;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        16,
        AppSpacing.containerMargin,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                location.toUpperCase(),
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Prayer schedule',
                style: AppTypography.headlineMd,
              ),
            ],
          ),
          Material(
            color: AppColors.bgElevated,
            borderRadius: AppRadii.xlAll,
            child: InkWell(
              onTap: onCalendarTap,
              borderRadius: AppRadii.xlAll,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Symbols.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar card
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.viewedMonth,
    required this.today,
    required this.onPrev,
    required this.onNext,
  });
  final DateTime viewedMonth;
  final DateTime today;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendar(viewedMonth, today);
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${_monthNames[viewedMonth.month - 1]} ${viewedMonth.year}',
                style: AppTypography.headlineMd.copyWith(fontSize: 18),
              ),
              Row(
                children: <Widget>[
                  _ChevronButton(
                    icon: Symbols.chevron_left_rounded,
                    onTap: onPrev,
                  ),
                  const SizedBox(width: 8),
                  _ChevronButton(
                    icon: Symbols.chevron_right_rounded,
                    onTap: onNext,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _DayOfWeekHeader(),
          const SizedBox(height: 12),
          _DateGrid(cells: cells),
        ],
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.borderLow,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
      ),
    );
  }
}

class _DayOfWeekHeader extends StatelessWidget {
  const _DayOfWeekHeader();

  static const _labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final label in _labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _DateGrid extends StatelessWidget {
  const _DateGrid({required this.cells});
  final List<_CalendarCell> cells;

  @override
  Widget build(BuildContext context) {
    // Render in 7-wide rows.
    final rows = <List<_CalendarCell>>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }
    return Column(
      children: <Widget>[
        for (var r = 0; r < rows.length; r++) ...<Widget>[
          if (r > 0) const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (final cell in rows[r])
                Expanded(child: _DateCell(cell: cell)),
            ],
          ),
        ],
      ],
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({required this.cell});
  final _CalendarCell cell;

  @override
  Widget build(BuildContext context) {
    final isToday = cell.isToday;
    if (isToday) {
      return Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${cell.day}',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '${cell.day}',
        textAlign: TextAlign.center,
        style: AppTypography.bodyLg.copyWith(
          color: cell.isCurrentMonth
              ? AppColors.onSurfaceVariant
              : AppColors.inkSubtle,
        ),
      ),
    );
  }
}

class _CalendarCell {
  const _CalendarCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
  });
  final int day;
  final bool isCurrentMonth;
  final bool isToday;
}

List<_CalendarCell> _buildCalendar(DateTime month, DateTime today) {
  final firstOfMonth = DateTime(month.year, month.month);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  // Monday-first week: DateTime.weekday = 1..7 (Mon..Sun).
  final leading = firstOfMonth.weekday - 1;

  // Trailing pad up to a multiple of 7.
  final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
  final cells = <_CalendarCell>[];
  final prevMonthLastDay = DateTime(month.year, month.month, 0).day;

  // Leading (previous month, faded)
  for (var i = 0; i < leading; i++) {
    final day = prevMonthLastDay - leading + 1 + i;
    cells.add(_CalendarCell(
      day: day,
      isCurrentMonth: false,
      isToday: false,
    ));
  }

  // Current month
  for (var i = 1; i <= daysInMonth; i++) {
    final isToday = today.year == month.year &&
        today.month == month.month &&
        today.day == i;
    cells.add(_CalendarCell(
      day: i,
      isCurrentMonth: true,
      isToday: isToday,
    ));
  }

  // Trailing (next month, faded)
  var nextDay = 1;
  while (cells.length < totalCells) {
    cells.add(_CalendarCell(
      day: nextDay,
      isCurrentMonth: false,
      isToday: false,
    ));
    nextDay++;
  }

  return cells;
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected-day header
// ─────────────────────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});
  final DateTime date;

  static const _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Today — ${date.day} ${_months[date.month - 1]}',
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.goldHighlight,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          // Hijri lookup is a real `hijri` package job (B5). Until that lands,
          // we surface the calendar method so the line isn't blank/fake.
          'Calendar method: Muslim World League',
          style: AppTypography.bodyMd.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer list
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerList extends StatelessWidget {
  const _PrayerList({required this.schedule});
  final PrayerTimes schedule;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final entries = <_PrayerEntry>[
      _PrayerEntry(name: 'Fajr', initial: 'F', time: schedule.fajr),
      _PrayerEntry(name: 'Dhuhr', initial: 'D', time: schedule.dhuhr),
      _PrayerEntry(name: 'Asr', initial: 'A', time: schedule.asr),
      _PrayerEntry(name: 'Maghrib', initial: 'M', time: schedule.maghrib),
      _PrayerEntry(name: 'Isha', initial: 'I', time: schedule.isha),
    ];

    // Find next prayer index (or -1 if all past).
    final nextIdx = entries.indexWhere((e) => e.time.isAfter(now));

    return Column(
      children: <Widget>[
        for (var i = 0; i < entries.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          _PrayerRow(
            entry: entries[i],
            status: _statusFor(i, nextIdx, entries[i].time, now),
            isNext: i == nextIdx,
          ),
        ],
      ],
    );
  }

  _PrayerStatus _statusFor(int i, int nextIdx, DateTime time, DateTime now) {
    if (i == nextIdx) {
      final remaining = time.difference(now);
      return _PrayerStatus(label: _formatRemaining(remaining), isNext: true);
    }
    if (time.isAfter(now)) return const _PrayerStatus(label: 'Upcoming');
    return const _PrayerStatus(label: 'Ended');
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return 'Now';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return 'Next · in ${minutes}m';
    return 'Next · in ${hours}h ${minutes}m';
  }
}

class _PrayerEntry {
  const _PrayerEntry({
    required this.name,
    required this.initial,
    required this.time,
  });
  final String name;
  final String initial;
  final DateTime time;
}

class _PrayerStatus {
  const _PrayerStatus({required this.label, this.isNext = false});
  final String label;
  final bool isNext;
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.entry,
    required this.status,
    required this.isNext,
  });
  final _PrayerEntry entry;
  final _PrayerStatus status;
  final bool isNext;

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.heroAll,
      child: Stack(
        children: <Widget>[
          if (isNext)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.heroAll,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: AppRadii.heroAll,
              border: Border.all(
                color: isNext
                    ? AppColors.primary.withValues(alpha: 0.30)
                    : AppColors.inkPrimary.withValues(alpha: 0.05),
                width: isNext ? 2 : 1,
              ),
              boxShadow: isNext
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: <Widget>[
                _PrayerInitial(letter: entry.initial),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.name,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.inkPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (status.isNext)
                        _NextStatusPill(label: status.label)
                      else
                        Text(
                          status.label,
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.inkSubtle,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _fmtTime(entry.time),
                  style: AppTypography.numeralTime.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
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

class _PrayerInitial extends StatelessWidget {
  const _PrayerInitial({required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: AppRadii.xlAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.goldHighlight, AppColors.goldDeep],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NextStatusPill extends StatefulWidget {
  const _NextStatusPill({required this.label});
  final String label;

  @override
  State<_NextStatusPill> createState() => _NextStatusPillState();
}

class _NextStatusPillState extends State<_NextStatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.liveRed.withValues(
                alpha: 0.5 + (_pulse.value * 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.label,
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.liveRed,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / error
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerListSkeleton extends StatelessWidget {
  const _PrayerListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < 5; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard.withValues(alpha: 0.6),
              borderRadius: AppRadii.heroAll,
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInner,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.heroAll,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Symbols.error_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TimeDateStack extends StatelessWidget {
  const TimeDateStack({super.key, required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final hour12 = DateFormat('hh:mm').format(now);
    final ampm = DateFormat('a').format(now);
    final greg = DateFormat('MMM d, yyyy - EEEE').format(now);
    final h = HijriCalendar.fromDate(now);
    final hijri = '${h.hDay} ${h.longMonthName} ${h.hYear}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hour12,
              style: AppTextStyles.numeralTime(fontSize: 68, color: AppColors.primary).copyWith(
                shadows: const [Shadow(color: Color(0x73F2C050), blurRadius: 18)],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              ampm,
              style: AppTextStyles.labelCaps(color: AppColors.primary)
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('$greg, $hijri',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(color: AppColors.inkMuted)),
      ],
    );
  }
}

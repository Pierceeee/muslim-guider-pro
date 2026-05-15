import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';

class CurrentPrayerCard extends StatelessWidget {
  const CurrentPrayerCard({
    super.key,
    required this.prayerName,
    required this.fromTime,
    required this.toTime,
  });

  final String prayerName;
  final String fromTime;
  final String toTime;

  @override
  Widget build(BuildContext context) {
    final hairline = const Color(0xFF729DBB).withValues(alpha: 0.3);
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF51768E),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: hairline),
          right: BorderSide(color: hairline),
          bottom: BorderSide(color: hairline),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 15),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$prayerName Time',
              style: AppTextStyles.bodyMd(color: Colors.white)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('From - $fromTime',
              style: AppTextStyles.bodyMd(color: Colors.white)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w700, height: 1.3)),
          Text('To - $toTime',
              style: AppTextStyles.bodyMd(color: Colors.white)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w700, height: 1.3)),
        ],
      ),
    );
  }
}

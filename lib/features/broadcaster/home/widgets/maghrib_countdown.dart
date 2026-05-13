import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MaghribCountdown extends StatelessWidget {
  const MaghribCountdown({super.key, required this.remaining, this.label});

  final Duration remaining;
  final String? label;

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '${hh.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (label != null)
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        Text(_format(remaining),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  shadows: const [
                    Shadow(color: Color(0x66F2C050), blurRadius: 18),
                  ],
                )),
      ],
    );
  }
}

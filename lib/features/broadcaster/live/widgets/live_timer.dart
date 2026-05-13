import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LiveTimer extends StatelessWidget {
  const LiveTimer({super.key, required this.elapsed});
  final Duration elapsed;

  String _format(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hh > 0 ? '${hh.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_format(elapsed),
        style: Theme.of(context).textTheme.displayLarge
            ?.copyWith(color: AppColors.primary));
  }
}

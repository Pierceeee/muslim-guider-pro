import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class MicLockIndicator extends StatefulWidget {
  const MicLockIndicator({super.key, required this.active});
  final bool active;
  @override
  State<MicLockIndicator> createState() => _MicLockIndicatorState();
}

class _MicLockIndicatorState extends State<MicLockIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final r = 8 * _ctrl.value;
            final o = 0.55 * (1 - _ctrl.value);
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgElevated,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: o),
                    blurRadius: 0,
                    spreadRadius: r,
                  ),
                ],
              ),
              child: const Icon(Symbols.mic, color: AppColors.primary, size: 28),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          widget.active ? 'LIVE' : 'IDLE',
          style: AppTextStyles.labelCaps(color: AppColors.primary).copyWith(fontSize: 9),
        ),
      ],
    );
  }
}

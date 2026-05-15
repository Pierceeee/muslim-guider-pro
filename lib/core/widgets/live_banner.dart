import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LiveBanner extends StatefulWidget {
  const LiveBanner({
    super.key,
    required this.elapsed,
    required this.subtitle,
  });

  final Duration elapsed;
  final String subtitle;

  @override
  State<LiveBanner> createState() => _LiveBannerState();
}

class _LiveBannerState extends State<LiveBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.liveRedBg,
        border: Border(
          bottom: BorderSide(
            color: AppColors.liveRed.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.liveRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.liveRed
                            .withValues(alpha: 0.5 * _pulse.value),
                        blurRadius: 8 * _pulse.value,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'YOU ARE LIVE · ${_formatElapsed(widget.elapsed)}',
                style: AppTextStyles.labelCaps(color: AppColors.inkPrimary)
                    .copyWith(letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: AppTextStyles.bodyMd(
              color: AppColors.liveRed.withValues(alpha: 0.6),
            ).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

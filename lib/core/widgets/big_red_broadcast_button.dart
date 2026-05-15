import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BigRedBroadcastButton extends StatefulWidget {
  const BigRedBroadcastButton({super.key, required this.onConfirmed});
  final VoidCallback onConfirmed;

  @override
  State<BigRedBroadcastButton> createState() => _BigRedBroadcastButtonState();
}

class _BigRedBroadcastButtonState extends State<BigRedBroadcastButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (_) => setState(() => _pressed = true),
      onLongPressCancel: () => setState(() => _pressed = false),
      onLongPressEnd: (_) => setState(() => _pressed = false),
      onLongPress: () {
        setState(() => _pressed = false);
        widget.onConfirmed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF4D4F), Color(0xFFC1272D)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
            boxShadow: const [
              BoxShadow(color: Color(0x66FF4D4F), blurRadius: 40),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6 + 0.4 * _pulse.value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('Tap & hold to go live',
                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

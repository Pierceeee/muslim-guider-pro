import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SlideToBroadcast extends StatefulWidget {
  const SlideToBroadcast({
    super.key,
    required this.onConfirmed,
    this.label = 'SLIDE TO BROADCAST',
    this.confirmThreshold = 0.8,
  });

  final VoidCallback onConfirmed;
  final String label;
  final double confirmThreshold;

  @override
  State<SlideToBroadcast> createState() => _SlideToBroadcastState();
}

class _SlideToBroadcastState extends State<SlideToBroadcast> {
  double _drag = 0;
  double _maxDrag = 0;
  bool _fired = false;

  void _onUpdate(DragUpdateDetails d) {
    setState(() {
      _drag = (_drag + d.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _onEnd(DragEndDetails _) {
    if (_fired) return;
    if (_maxDrag > 0 && _drag / _maxDrag >= widget.confirmThreshold) {
      _fired = true;
      widget.onConfirmed();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const thumbSize = 56.0;
      _maxDrag = constraints.maxWidth - thumbSize - 8;
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceInset,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(letterSpacing: 2),
            ),
            Positioned(
              left: 4 + _drag,
              child: GestureDetector(
                onHorizontalDragUpdate: _onUpdate,
                onHorizontalDragEnd: _onEnd,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic,
                      color: AppColors.bgDeepNight, size: 28),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

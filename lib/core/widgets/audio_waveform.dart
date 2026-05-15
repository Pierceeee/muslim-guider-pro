import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AudioWaveform extends StatefulWidget {
  const AudioWaveform({
    super.key,
    required this.levelStream,
    this.barCount = 96,
  });

  final Stream<double> levelStream; // values in 0..1
  final int barCount;

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> {
  late final List<double> _samples;
  final _rand = math.Random();
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _samples = List.generate(widget.barCount, (_) => 0.2 + _rand.nextDouble() * 0.6);
    _sub = widget.levelStream.listen(_onLevel);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onLevel(double level) {
    if (!mounted) return;
    setState(() {
      _samples.removeAt(0);
      _samples.add((0.2 + level * 0.8).clamp(0.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: Row(
        children: [
          for (var i = 0; i < widget.barCount; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: 192 * _samples[i],
                decoration: BoxDecoration(
                  color: i.isEven ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

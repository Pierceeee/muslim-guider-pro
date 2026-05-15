import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SlideToBroadcastVariant { dashboard, home }

class SlideToBroadcast extends StatefulWidget {
  const SlideToBroadcast({
    super.key,
    required this.onConfirmed,
    this.variant = SlideToBroadcastVariant.dashboard,
    this.confirmThreshold = 0.9,
  });

  final VoidCallback onConfirmed;
  final SlideToBroadcastVariant variant;
  final double confirmThreshold;

  @override
  State<SlideToBroadcast> createState() => _SlideToBroadcastState();
}

class _SlideToBroadcastState extends State<SlideToBroadcast>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _maxX = 0;
  bool _fired = false;

  late final AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_fired) return;
    _animController.stop();
    setState(() {
      _dragX = (_dragX + d.delta.dx).clamp(0.0, _maxX);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_fired) return;
    if (_maxX > 0 && _dragX / _maxX >= widget.confirmThreshold) {
      _fired = true;
      _animateTo(_maxX, onDone: () {
        widget.onConfirmed();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _dragX = 0;
              _fired = false;
            });
          }
        });
      });
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    final start = _dragX;
    _anim = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    )..addListener(() {
        if (mounted) setState(() => _dragX = _anim.value);
      });
    _animController.forward(from: 0).whenCompleteOrCancel(() {
      onDone?.call();
    });
  }

  // ── Pill track (shared) ────────────────────────────────────────────────────

  Widget _buildTrack() {
    const thumbSize = 52.0;
    const trackHeight = 64.0;
    const trackPadding = 6.0;

    return LayoutBuilder(builder: (context, constraints) {
      _maxX = constraints.maxWidth - thumbSize - trackPadding * 2;

      return Container(
        height: trackHeight,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Label — fades as thumb moves over it
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                'SLIDE TO BROADCAST',
                style: AppTextStyles.labelCaps(color: AppColors.primary)
                    .copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Draggable thumb
            Positioned(
              left: trackPadding + _dragX,
              child: GestureDetector(
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE1B354), Color(0xFFC18C2F)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x44C18C2F),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Symbols.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Dashboard variant ──────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // 56×56 mic disc
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE1B354), Color(0xFFC18C2F)],
              ),
            ),
            child: const Icon(Symbols.mic, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          // Pill track fills remaining width
          Expanded(child: _buildTrack()),
        ],
      ),
    );
  }

  // ── Home variant ───────────────────────────────────────────────────────────

  Widget _buildHome() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status block
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SLIDE TO BROADCAST ADHAN',
                      style: AppTextStyles.labelCaps(color: AppColors.primary)
                          .copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hold and slide right to go on-air · slide left to end',
                      style: AppTextStyles.bodyMd(color: AppColors.inkMuted)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'UNLOCKED',
                style: AppTextStyles.labelCaps(color: AppColors.inkMuted)
                    .copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Pill track — no left mic disc for home variant
          _buildTrack(),
          const SizedBox(height: 6),
          // Footer hint
          Text(
            'Only Muadhins inside the masjid radius can broadcast.',
            style: AppTextStyles.bodyMd(color: AppColors.inkMuted)
                .copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      SlideToBroadcastVariant.dashboard => _buildDashboard(),
      SlideToBroadcastVariant.home => _buildHome(),
    };
  }
}

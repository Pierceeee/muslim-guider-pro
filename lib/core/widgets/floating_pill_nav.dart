import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../icons/material_symbols.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavSpec>[
    _NavSpec('Home', _IconRef.home),
    _NavSpec('Dashboard', _IconRef.dashboard),
    _NavSpec('Nearby', _IconRef.locationOn),
    _NavSpec('Inbox', _IconRef.mail),
    _NavSpec('Me', _IconRef.person),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgElevated.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _PillItem(spec: _items[i], active: i == currentIndex, onTap: () => onTap(i)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _IconRef { home, dashboard, locationOn, mail, person }

class _NavSpec {
  const _NavSpec(this.label, this.icon);
  final String label;
  final _IconRef icon;
}

class _PillItem extends StatelessWidget {
  const _PillItem({required this.spec, required this.active, required this.onTap});
  final _NavSpec spec;
  final bool active;
  final VoidCallback onTap;

  IconData _icon() => switch (spec.icon) {
        _IconRef.home => Sym.home(active),
        _IconRef.dashboard => Sym.dashboard(active),
        _IconRef.locationOn => Sym.locationOn(active),
        _IconRef.mail => Sym.mail(active),
        _IconRef.person => Sym.person(active),
      };

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.primary : Colors.transparent;
    final fg = active ? AppColors.onPrimary : AppColors.inkMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 10, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(), color: fg, size: 22),
            const SizedBox(height: 2),
            Text(spec.label, style: AppTextStyles.labelCaps(color: fg).copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

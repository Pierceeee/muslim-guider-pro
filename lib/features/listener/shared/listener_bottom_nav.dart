import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

/// The floating glass pill nav that sits over every listener screen.
///
/// Pass the route name of the current screen; the matching tab renders as
/// the active gold pill. Tapping any other tab navigates to that route.
class ListenerBottomNav extends StatelessWidget {
  const ListenerBottomNav({required this.currentRouteName, super.key});

  final String currentRouteName;

  static const _items = <_NavItem>[
    _NavItem(
      icon: Symbols.home_rounded,
      label: 'Home',
      routeName: ListenerRoute.nameHomePrayerWidget,
    ),
    _NavItem(
      icon: Symbols.dashboard_rounded,
      label: 'Dashboard',
      routeName: ListenerRoute.nameHomeListener,
    ),
    _NavItem(
      icon: Symbols.location_on_rounded,
      label: 'Nearby',
      routeName: ListenerRoute.nameNearbyMasjids,
    ),
    _NavItem(
      icon: Symbols.schedule_rounded,
      label: 'Times',
      routeName: ListenerRoute.namePrayerSchedule,
    ),
    _NavItem(
      icon: Symbols.mail_rounded,
      label: 'Inbox',
      routeName: ListenerRoute.nameInbox,
    ),
    _NavItem(
      icon: Symbols.person_rounded,
      label: 'Me',
      routeName: ListenerRoute.nameProfile,
    ),
  ];

  void _onTap(BuildContext context, String routeName) {
    // Tapping the already-active tab would push a duplicate route entry.
    if (routeName == currentRouteName) return;
    context.goNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: AppRadii.fullAll,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadii.fullAll,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated.withValues(alpha: 0.78),
                  borderRadius: AppRadii.fullAll,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    for (final item in _items)
                      Expanded(
                        flex: item.routeName == currentRouteName ? 2 : 1,
                        child: _NavTile(
                          item: item,
                          isActive: item.routeName == currentRouteName,
                          onTap: () => _onTap(context, item.routeName),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });
  final IconData icon;
  final String label;
  final String routeName;
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadii.fullAll,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  widget.item.icon,
                  color: AppColors.onPrimary,
                  size: 20,
                  fill: 1,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.fullAll,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppRadii.fullAll,
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(widget.item.icon, color: AppColors.inkMuted, size: 20),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.inkMuted,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

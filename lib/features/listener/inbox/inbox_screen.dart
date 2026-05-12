import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/notification_item.dart';
import '../../../data/providers/listener_providers.dart';
import '../shared/listener_bottom_nav.dart';

/// Recreates `prototype/screens/inbox.html`.
///
/// Data: `notificationsProvider` (mutable Notifier — taps mark items read).
/// Layout: sticky top bar with unread count · "recent" list · "Earlier this
/// week" divider · "earlier" list (subtle) · shared bottom nav.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  static const _earlierThreshold = Duration(days: 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);
    final now = DateTime.now();
    final recent = notifications
        .where((n) => now.difference(n.createdAt) <= _earlierThreshold)
        .toList();
    final earlier = notifications
        .where((n) => now.difference(n.createdAt) > _earlierThreshold)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgDeepNight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                72,
                AppSpacing.containerMargin,
                140,
              ),
              children: <Widget>[
                for (var i = 0; i < recent.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: AppSpacing.gutter),
                  _NotificationCard(
                    item: recent[i],
                    onTap: () => _handleTap(context, ref, recent[i]),
                  ),
                ],
                if (earlier.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sectionGap),
                  Text(
                    'EARLIER THIS WEEK',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.inkSubtle,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < earlier.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: AppSpacing.gutter),
                    _NotificationCard(
                      item: earlier[i],
                      muted: true,
                      onTap: () => _handleTap(context, ref, earlier[i]),
                    ),
                  ],
                ],
                if (notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'You\'re all caught up.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            _StickyTopBar(
              unreadCount: unread,
              onSearchTap: () => _searchTBD(context),
              onAvatarTap: () =>
                  context.goNamed(ListenerRoute.nameProfile),
              onMarkAllRead: unread == 0
                  ? null
                  : () => ref
                      .read(notificationsProvider.notifier)
                      .markAllRead(),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: ListenerBottomNav(
                currentRouteName: ListenerRoute.nameInbox,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
  ) {
    ref.read(notificationsProvider.notifier).markRead(item.id);
    if (item.linkedStreamId != null) {
      context.goNamed(
        ListenerRoute.nameLivePlayer,
        pathParameters: <String, String>{'streamId': item.linkedStreamId!},
      );
      return;
    }
    if (item.linkedMasjidId != null) {
      context.goNamed(
        ListenerRoute.nameMasjidDetail,
        pathParameters: <String, String>{'masjidId': item.linkedMasjidId!},
      );
      return;
    }
    // Account-style notifications have no link — just mark read.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Marked as read.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }

  void _searchTBD(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Inbox search lands with the global search bar in F4 polish.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky top bar — overlay above the list
// ─────────────────────────────────────────────────────────────────────────────

class _StickyTopBar extends StatelessWidget {
  const _StickyTopBar({
    required this.unreadCount,
    required this.onSearchTap,
    required this.onAvatarTap,
    required this.onMarkAllRead,
  });
  final int unreadCount;
  final VoidCallback onSearchTap;
  final VoidCallback onAvatarTap;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.bgDeepNight.withValues(alpha: 0.85),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          12,
          AppSpacing.containerMargin,
          12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Inbox',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.inkPrimary,
                    fontSize: 22,
                  ),
                ),
                if (unreadCount > 0) ...<Widget>[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmberBg,
                      borderRadius: AppRadii.fullAll,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.goldHighlight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: <Widget>[
                if (onMarkAllRead != null)
                  Material(
                    color: Colors.transparent,
                    borderRadius: AppRadii.fullAll,
                    child: InkWell(
                      onTap: onMarkAllRead,
                      borderRadius: AppRadii.fullAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text(
                          'Mark all read',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  borderRadius: AppRadii.fullAll,
                  child: InkWell(
                    onTap: onSearchTap,
                    borderRadius: AppRadii.fullAll,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Symbols.search_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: AppColors.surfaceContainerHighest,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onAvatarTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'A',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification card — type-driven icon + colour
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    this.muted = false,
  });
  final NotificationItem item;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(item.kind);
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadii.heroAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.heroAll,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Opacity(
          opacity: muted ? 0.75 : 1,
          child: Container(
            padding: AppSpacing.cardInner,
            decoration: BoxDecoration(
              borderRadius: AppRadii.heroAll,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IconTile(visual: visual),
                const SizedBox(width: AppSpacing.gutter),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTypography.bodyLg.copyWith(
                                color: AppColors.inkPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _agoLabel(item.createdAt),
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.inkSubtle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.inkMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!item.read) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _agoLabel(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.isNegative || diff.inSeconds < 30) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} wk ago';
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.visual});
  final _NotificationVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: AppRadii.xlAll,
        color: visual.bg,
      ),
      alignment: Alignment.center,
      child: Icon(
        visual.icon,
        color: visual.fg,
        size: 24,
        fill: visual.filled ? 1 : 0,
      ),
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual({
    required this.icon,
    required this.bg,
    required this.fg,
    this.filled = false,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final bool filled;
}

_NotificationVisual _visualFor(NotificationKind kind) =>
    switch (kind) {
      NotificationKind.liveNow => const _NotificationVisual(
          icon: Symbols.sensors_rounded,
          bg: AppColors.liveRedBg,
          fg: AppColors.liveRed,
          filled: true,
        ),
      NotificationKind.prayerReminder => const _NotificationVisual(
          icon: Symbols.notifications_active_rounded,
          bg: AppColors.warningAmberBg,
          fg: AppColors.goldHighlight,
        ),
      NotificationKind.verificationStatus => const _NotificationVisual(
          icon: Symbols.verified_rounded,
          bg: AppColors.successGreenBg,
          fg: AppColors.successGreen,
          filled: true,
        ),
      NotificationKind.scheduleUpdate => const _NotificationVisual(
          icon: Symbols.schedule_rounded,
          bg: AppColors.warningAmberBg,
          fg: AppColors.goldHighlight,
        ),
      NotificationKind.account => _NotificationVisual(
          icon: Symbols.mosque_rounded,
          bg: AppColors.bgElevated,
          fg: AppColors.inkMuted.withValues(alpha: 1),
        ),
    };

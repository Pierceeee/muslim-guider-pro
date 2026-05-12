/// Kind of in-app notification surfaced in the listener's Inbox.
///
/// Drives the icon + tile colour for each row, and lets future deep-link
/// routing (B5) pick the right destination for each notification type.
enum NotificationKind {
  /// A followed masjid is broadcasting right now.
  liveNow,

  /// Heads-up before a prayer time.
  prayerReminder,

  /// Verification status changed (e.g. 4-Layer chain advanced).
  verificationStatus,

  /// A followed masjid changed its prayer schedule.
  scheduleUpdate,

  /// Donation receipt or general account notice.
  account,
}

/// User-facing notification record. v1 mock; B5 backs this with FCM history
/// stored in `/notifications/{userId}/items`.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.linkedStreamId,
    this.linkedMasjidId,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  /// Optional deep-link target. When non-null, tapping the notification
  /// navigates the listener directly to the related surface.
  final String? linkedStreamId;
  final String? linkedMasjidId;
}

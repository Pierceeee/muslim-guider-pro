import '../models/notification_item.dart';

/// Computed against TODAY each time the list is read so "2 min ago" /
/// "Yesterday" labels stay coherent regardless of when the app launches.
List<NotificationItem> get mockNotifications {
  final now = DateTime.now();
  DateTime ago(Duration d) => now.subtract(d);

  return <NotificationItem>[
    NotificationItem(
      id: 'notif-live-abrar-asr',
      kind: NotificationKind.liveNow,
      title: 'Live now · Asr',
      body: 'Masjid Al-Abrar is broadcasting now',
      createdAt: ago(const Duration(minutes: 2)),
      linkedStreamId: 'stream-abrar-asr',
      linkedMasjidId: 'masjid-al-abrar',
    ),
    NotificationItem(
      id: 'notif-fajr-reminder',
      kind: NotificationKind.prayerReminder,
      title: 'Fajr in 30 minutes',
      body: 'Masjid Al-Abrar · 04:42 local',
      createdAt: ago(const Duration(minutes: 28)),
      linkedMasjidId: 'masjid-al-abrar',
    ),
    NotificationItem(
      id: 'notif-verified',
      kind: NotificationKind.verificationStatus,
      title: 'You are now verified ✓',
      body:
          'Your 20th QR scan at Masjid Al-Abrar unlocked broadcast verification',
      createdAt: ago(const Duration(days: 1)),
      read: true,
      linkedMasjidId: 'masjid-al-abrar',
    ),
    NotificationItem(
      id: 'notif-schedule-update',
      kind: NotificationKind.scheduleUpdate,
      title: 'Prayer time updated',
      body: 'Dhuhr now 12:38 for summer schedule',
      createdAt: ago(const Duration(days: 2)),
      read: true,
      linkedMasjidId: 'masjid-al-abrar',
    ),
    NotificationItem(
      id: 'notif-donation-receipt',
      kind: NotificationKind.account,
      title: 'Donation receipt',
      body:
          'Thank you for your contribution to the Masjid Al-Abrar expansion project.',
      createdAt: ago(const Duration(days: 4)),
      read: true,
    ),
  ];
}

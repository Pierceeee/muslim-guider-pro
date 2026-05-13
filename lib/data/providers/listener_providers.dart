import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_notifications.dart';
import '../models/masjid.dart';
import '../models/notification_item.dart';
import '../models/prayer_times.dart';
import '../models/stream_record.dart';
import '../models/user.dart';
import '../models/user_preferences.dart';
import '../models/user_stats.dart';
import 'repository_providers.dart';

/// Listener-facing data providers — the API screens watch.
///
/// Screens never call repositories directly; they always go through one of
/// these. That gives us a single seam where mock data turns into real
/// backend data without screens changing a line.

// ── User location (mock: Birmingham). B-phase: swap with `geolocator`. ───────
class _UserLocation {
  const _UserLocation({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

final _userLocationProvider = Provider<_UserLocation>(
  (ref) =>
      const _UserLocation(latitude: 52.4862, longitude: -1.8904), // Birmingham
);

// ── Auth / current user ────────────────────────────────────────────────────

/// Currently-authenticated user (or null if signed out).
/// Mock impl initially emits `null`; subscribing screens see a transition
/// to the listener fixture after [ensureSignedInUserProvider] resolves.
final currentUserStreamProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).currentUser(),
);

/// "Best effort" current user — in v1 the dashboard auto-signs-in with the
/// mock listener fixture if no one is signed in yet so the UI always has
/// something to render. Real F3 sign-in flow obsoletes this.
final ensureSignedInUserProvider = FutureProvider<User>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.signInWithEmail(
    email: 'abdullah@example.com',
    password: 'demo',
  );
});

// ── Prayer schedule ────────────────────────────────────────────────────────

/// Today's prayer times at the user's current location with their preferred
/// calculation method.
final todaysPrayerScheduleProvider = FutureProvider<PrayerTimes>((ref) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  final method = await repo.getCurrentMethod();
  final loc = ref.watch(_userLocationProvider);
  return repo.getDailySchedule(
    date: DateTime.now(),
    latitude: loc.latitude,
    longitude: loc.longitude,
    method: method,
  );
});

// ── Masjid queries ─────────────────────────────────────────────────────────

/// Single masjid by id.
final masjidByIdProvider = FutureProvider.family<Masjid, String>(
  (ref, masjidId) => ref.watch(masjidRepositoryProvider).getById(masjidId),
);

/// User's preferred masjid (`null` if no preference saved).
final preferredMasjidProvider = FutureProvider<Masjid?>((ref) async {
  final user = await ref.watch(ensureSignedInUserProvider.future);
  final id = user.preferredMasjidId;
  if (id == null) return null;
  return ref.watch(masjidRepositoryProvider).getById(id);
});

/// Masjids near the user, sorted by distance.
final nearbyMasjidsProvider = FutureProvider<List<Masjid>>((ref) {
  final loc = ref.watch(_userLocationProvider);
  return ref.watch(masjidRepositoryProvider).getNearby(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
});

/// Nearby masjids for the discovery surface — drops the user's preferred
/// masjid the way the prototype's `nearby-masjids.html` does, since the
/// preferred masjid already has its own hero on the dashboard.
final nearbyMasjidsForDiscoveryProvider =
    FutureProvider<List<Masjid>>((ref) async {
  final allFuture = ref.watch(nearbyMasjidsProvider.future);
  final preferredFuture = ref.watch(preferredMasjidProvider.future);
  final all = await allFuture;
  final preferred = await preferredFuture;
  if (preferred == null) return all;
  return all.where((m) => m.id != preferred.id).toList();
});

/// Featured masjids for the home dashboard.
final featuredMasjidsProvider = FutureProvider<List<Masjid>>(
  (ref) => ref.watch(masjidRepositoryProvider).getFeatured(),
);

// ── Broadcasts ─────────────────────────────────────────────────────────────

/// All currently-live streams across all masjids.
final activeStreamsProvider = StreamProvider<List<StreamRecord>>(
  (ref) => ref.watch(broadcastRepositoryProvider).watchActiveStreams(),
);

/// Recent broadcasts (live + ended) for one masjid.
final masjidBroadcastsProvider =
    FutureProvider.family<List<StreamRecord>, String>(
  (ref, masjidId) =>
      ref.watch(broadcastRepositoryProvider).getRecentByMasjid(masjidId),
);

/// Single stream by id.
final streamByIdProvider = FutureProvider.family<StreamRecord, String>(
  (ref, streamId) =>
      ref.watch(broadcastRepositoryProvider).getById(streamId),
);

// ── Joined views ───────────────────────────────────────────────────────────

/// A live broadcast bundled with its masjid record — the shape listener UIs
/// actually want to render (icon, name, distance + listener count, etc.).
/// In Phase B this join happens server-side; the mock provider below does
/// it client-side so screens never have to look up masjids themselves.
class LiveBroadcastView {
  const LiveBroadcastView({required this.stream, required this.masjid});
  final StreamRecord stream;
  final Masjid masjid;
}

/// All live broadcasts joined with their masjid records, sorted by current
/// listener count (descending). Excludes streams whose masjid we can't
/// resolve (shouldn't happen in v1 mocks but keeps the UI defensive).
final liveBroadcastsViewProvider =
    FutureProvider<List<LiveBroadcastView>>((ref) async {
  final streams = await ref.watch(activeStreamsProvider.future);
  final masjidRepo = ref.watch(masjidRepositoryProvider);
  final results = <LiveBroadcastView>[];
  for (final s in streams) {
    try {
      final masjid = await masjidRepo.getById(s.masjidId);
      results.add(LiveBroadcastView(stream: s, masjid: masjid));
    } catch (_) {
      // Masjid record missing — skip, don't crash the UI.
    }
  }
  results.sort(
    (a, b) =>
        b.stream.listenerCountCurrent.compareTo(a.stream.listenerCountCurrent),
  );
  return results;
});

/// Live broadcasts to show under "Live broadcasts near you" on the dashboard.
/// Drops the user's preferred masjid (which is already rendered as its own
/// hero card above the list) so we don't show the same masjid twice.
final nearbyLiveBroadcastsProvider =
    FutureProvider<List<LiveBroadcastView>>((ref) async {
  // Fire both lookups in parallel — preferred-masjid only narrows the list,
  // so there's no reason to await the broadcasts before subscribing to it.
  final allFuture = ref.watch(liveBroadcastsViewProvider.future);
  final preferredFuture = ref.watch(preferredMasjidProvider.future);
  final all = await allFuture;
  final preferred = await preferredFuture;
  if (preferred == null) return all;
  return all.where((b) => b.masjid.id != preferred.id).toList();
});

// ── Notifications ──────────────────────────────────────────────────────────

/// Listener's notification inbox, newest-first.
///
/// v1 mock; B5 reads `/notifications/{userId}/items` from Firestore (FCM
/// history). Tapping a notification marks it read — that mutation lives on
/// the controller below.
final notificationsProvider =
    NotifierProvider<NotificationsController, List<NotificationItem>>(
  NotificationsController.new,
);

class NotificationsController extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    final list = List<NotificationItem>.from(mockNotifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Number of unread notifications — drives the "N new" pill in the inbox.
  int get unreadCount => state.where((n) => !n.read).length;

  /// Flip an entry's `read` flag to true. No-op if already read or missing.
  void markRead(String id) {
    state = <NotificationItem>[
      for (final n in state)
        if (n.id == id && !n.read)
          NotificationItem(
            id: n.id,
            kind: n.kind,
            title: n.title,
            body: n.body,
            createdAt: n.createdAt,
            read: true,
            linkedStreamId: n.linkedStreamId,
            linkedMasjidId: n.linkedMasjidId,
          )
        else
          n,
    ];
  }

  /// Bulk-mark everything in the inbox as read.
  void markAllRead() {
    state = <NotificationItem>[
      for (final n in state)
        if (n.read)
          n
        else
          NotificationItem(
            id: n.id,
            kind: n.kind,
            title: n.title,
            body: n.body,
            createdAt: n.createdAt,
            read: true,
            linkedStreamId: n.linkedStreamId,
            linkedMasjidId: n.linkedMasjidId,
          ),
    ];
  }
}

/// Convenience: unread count (live updates when [NotificationsController] mutates).
final unreadNotificationsCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.read).length,
);

// ── User preferences (settings screen) ─────────────────────────────────────

/// Listener-side toggles + picker selections from the settings screen.
/// v1 holds these in memory; B5 persists them via `SharedPreferences` and
/// later syncs to Firestore for cross-device parity.
final userPreferencesProvider =
    NotifierProvider<UserPreferencesController, UserPreferences>(
  UserPreferencesController.new,
);

class UserPreferencesController extends Notifier<UserPreferences> {
  @override
  UserPreferences build() => const UserPreferences();

  void setAutoPlayNearestAthan(bool v) =>
      state = state.copyWith(autoPlayNearestAthan: v);

  void setBackgroundProximity(bool v) =>
      state = state.copyWith(backgroundProximity: v);

  void setPrayerReminders(bool v) =>
      state = state.copyWith(prayerReminders: v);

  void setFaceId(bool v) => state = state.copyWith(faceId: v);

  void setLanguage(AppLanguage v) => state = state.copyWith(language: v);

  void setHijriCalendar(HijriCalendarVariant v) =>
      state = state.copyWith(hijriCalendar: v);
}

// ── User stats (profile screen) ────────────────────────────────────────────

/// Aggregate metrics for the signed-in user. v1 returns plausible hardcoded
/// numbers; B-phase replaces this with real Firestore aggregate queries.
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  // Touch the user so we re-emit when sign-in state changes.
  await ref.watch(ensureSignedInUserProvider.future);
  return const UserStats(
    broadcastsHeard: 312,
    masjidsVerified: 4,
    memberSinceYear: 2026,
    // tazkiyaScore intentionally null in v1 — Phase 2 populates this.
    tazkiyaScore: 87,
  );
});

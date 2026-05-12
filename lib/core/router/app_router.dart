import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/listener/account/profile_screen.dart';
import '../../features/listener/account/settings_screen.dart';
import '../../features/listener/discovery/nearby_masjids_screen.dart';
import '../../features/listener/discovery/search_results_screen.dart';
import '../../features/listener/home/home_listener_screen.dart';
import '../../features/listener/home/home_prayer_widget_screen.dart';
import '../../features/listener/inbox/inbox_screen.dart';
import '../../features/listener/masjid/masjid_detail_screen.dart';
import '../../features/listener/player/live_player_screen.dart';
import '../../features/listener/player/replay_player_screen.dart';
import '../../features/listener/player/stream_ended_screen.dart';
import '../../features/listener/player/stream_reconnecting_screen.dart';
import '../../features/listener/schedule/prayer_schedule_screen.dart';
import '../../features/listener/tv/smart_tv_pairing_screen.dart';

/// All listener routes derived from `prototype/index.html`.
///
/// Path constants and route names are kept in sync with prototype slugs for
/// findability — when code references `nameLivePlayer`, the matching HTML
/// file is `prototype/screens/live-player-masjid-al-abrar.html`.
///
/// Auth and broadcaster routes will land here when F3 and F5 begin.
class ListenerRoute {
  ListenerRoute._();

  // Paths
  static const String homeListener = '/';
  static const String homePrayerWidget = '/home-prayer-widget';
  static const String nearbyMasjids = '/nearby-masjids';
  static const String searchResults = '/search-results';
  static const String masjidDetail = '/masjid/:masjidId';
  static const String livePlayer = '/live/:streamId';
  static const String replayPlayer = '/replay/:streamId';
  static const String streamEnded = '/stream/ended';
  static const String streamReconnecting = '/stream/reconnecting';
  static const String prayerSchedule = '/prayer-schedule';
  static const String inbox = '/inbox';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String smartTvPairing = '/smart-tv-pairing';

  // Route names — what callers pass to `context.goNamed(...)`.
  static const String nameHomeListener = 'home-listener';
  static const String nameHomePrayerWidget = 'home-prayer-widget';
  static const String nameNearbyMasjids = 'nearby-masjids';
  static const String nameSearchResults = 'search-results-nearby';
  static const String nameMasjidDetail = 'masjid-detail';
  static const String nameLivePlayer = 'live-player';
  static const String nameReplayPlayer = 'replay-player';
  static const String nameStreamEnded = 'stream-ended-state';
  static const String nameStreamReconnecting = 'stream-reconnecting-state';
  static const String namePrayerSchedule = 'prayer-schedule';
  static const String nameInbox = 'inbox';
  static const String nameProfile = 'profile';
  static const String nameSettings = 'settings';
  static const String nameSmartTvPairing = 'smart-tv-pairing';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: ListenerRoute.homeListener,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: ListenerRoute.homeListener,
        name: ListenerRoute.nameHomeListener,
        builder: (context, state) => const HomeListenerScreen(),
      ),
      GoRoute(
        path: ListenerRoute.homePrayerWidget,
        name: ListenerRoute.nameHomePrayerWidget,
        builder: (context, state) => const HomePrayerWidgetScreen(),
      ),
      GoRoute(
        path: ListenerRoute.nearbyMasjids,
        name: ListenerRoute.nameNearbyMasjids,
        builder: (context, state) => const NearbyMasjidsScreen(),
      ),
      GoRoute(
        path: ListenerRoute.searchResults,
        name: ListenerRoute.nameSearchResults,
        builder: (context, state) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: ListenerRoute.masjidDetail,
        name: ListenerRoute.nameMasjidDetail,
        builder: (context, state) => MasjidDetailScreen(
          masjidId: state.pathParameters['masjidId'] ?? 'unknown',
        ),
      ),
      GoRoute(
        path: ListenerRoute.livePlayer,
        name: ListenerRoute.nameLivePlayer,
        builder: (context, state) => LivePlayerScreen(
          streamId: state.pathParameters['streamId'] ?? 'unknown',
        ),
      ),
      GoRoute(
        path: ListenerRoute.replayPlayer,
        name: ListenerRoute.nameReplayPlayer,
        builder: (context, state) => ReplayPlayerScreen(
          streamId: state.pathParameters['streamId'] ?? 'unknown',
        ),
      ),
      GoRoute(
        path: ListenerRoute.streamEnded,
        name: ListenerRoute.nameStreamEnded,
        builder: (context, state) => const StreamEndedScreen(),
      ),
      GoRoute(
        path: ListenerRoute.streamReconnecting,
        name: ListenerRoute.nameStreamReconnecting,
        builder: (context, state) => const StreamReconnectingScreen(),
      ),
      GoRoute(
        path: ListenerRoute.prayerSchedule,
        name: ListenerRoute.namePrayerSchedule,
        builder: (context, state) => const PrayerScheduleScreen(),
      ),
      GoRoute(
        path: ListenerRoute.inbox,
        name: ListenerRoute.nameInbox,
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: ListenerRoute.profile,
        name: ListenerRoute.nameProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: ListenerRoute.settings,
        name: ListenerRoute.nameSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: ListenerRoute.smartTvPairing,
        name: ListenerRoute.nameSmartTvPairing,
        builder: (context, state) => const SmartTvPairingScreen(),
      ),
    ],
  );
});

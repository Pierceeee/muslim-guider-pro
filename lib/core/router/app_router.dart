import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/broadcaster/home/home_prayer_widget_screen.dart';
import '../../features/listener/stub_listener_home.dart';
import '../../providers/current_user_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/stub_screen.dart';
import 'route_names.dart';

GoRouter buildAppRouter(ProviderContainer container) {
  return GoRouter(
    initialLocation: RouteNames.root,
    refreshListenable: _UserChangeNotifier(container),
    redirect: (context, state) {
      final user = container.read(currentUserProvider).value;
      final atSignIn = state.matchedLocation == RouteNames.signIn;

      if (user == null) {
        return atSignIn ? null : RouteNames.signIn;
      }

      final target = _homeForRole(user.role);
      if (state.matchedLocation == RouteNames.root || atSignIn) {
        return target;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.root,
        builder: (context, state) => const _BootingPlaceholder(),
      ),
      GoRoute(
        path: RouteNames.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _BroadcasterShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: RouteNames.broadcasterHome,
            builder: (context, state) => const HomePrayerWidgetMuadhinScreen(),
          ),
          GoRoute(
            path: RouteNames.broadcasterDashboard,
            builder: (context, state) =>
                const _PlaceholderScreen('Broadcaster Dashboard (placeholder)'),
          ),
          GoRoute(
            path: RouteNames.broadcasterNearby,
            builder: (context, state) =>
                const StubScreen(label: 'Nearby', icon: Icons.near_me_outlined),
          ),
          GoRoute(
            path: RouteNames.broadcasterInbox,
            builder: (context, state) =>
                const StubScreen(label: 'Inbox', icon: Icons.inbox_outlined),
          ),
          GoRoute(
            path: RouteNames.broadcasterMe,
            builder: (context, state) =>
                const StubScreen(label: 'Me', icon: Icons.person_outline),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.listenerHome,
        builder: (context, state) => const StubListenerHome(),
      ),
      GoRoute(
        path: RouteNames.goLive,
        builder: (context, state) =>
            const _PlaceholderScreen('Go Live (placeholder)'),
      ),
      GoRoute(
        path: '${RouteNames.livePath}/:streamId',
        builder: (context, state) => _PlaceholderScreen(
          'Live (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
      GoRoute(
        path: '${RouteNames.summaryPath}/:streamId',
        builder: (context, state) => _PlaceholderScreen(
          'Summary (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
    ],
  );
}

String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.muadhin:
    case UserRole.admin:
      return RouteNames.broadcasterHome;
    case UserRole.listener:
      return RouteNames.listenerHome;
  }
}

class _UserChangeNotifier extends ChangeNotifier {
  _UserChangeNotifier(this._container) {
    _sub = _container.listen<AsyncValue<User?>>(
      currentUserProvider,
      (prev, next) => notifyListeners(),
      fireImmediately: false,
    );
  }
  final ProviderContainer _container;
  late final ProviderSubscription<AsyncValue<User?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

class _BootingPlaceholder extends StatelessWidget {
  const _BootingPlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

class _BroadcasterShell extends StatelessWidget {
  const _BroadcasterShell({required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = [
    RouteNames.broadcasterHome,
    RouteNames.broadcasterDashboard,
    RouteNames.broadcasterNearby,
    RouteNames.broadcasterInbox,
    RouteNames.broadcasterMe,
  ];

  int get _currentIndex {
    final i = _tabs.indexOf(location);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => GoRouter.of(context).go(_tabs[i]),
      ),
    );
  }
}

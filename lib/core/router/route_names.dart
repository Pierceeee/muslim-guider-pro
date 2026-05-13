abstract class RouteNames {
  static const root = '/';
  static const signIn = '/sign-in';

  static const broadcasterHome = '/broadcaster/home';
  static const broadcasterDashboard = '/broadcaster/dashboard';
  static const broadcasterNearby = '/broadcaster/nearby';
  static const broadcasterInbox = '/broadcaster/inbox';
  static const broadcasterMe = '/broadcaster/me';

  static const goLive = '/broadcaster/go-live';
  static const livePath = '/broadcaster/live'; // append /:streamId
  static const summaryPath = '/broadcaster/summary'; // append /:streamId

  static const listenerHome = '/listener/home';
}

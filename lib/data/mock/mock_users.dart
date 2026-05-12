import '../models/user.dart';

/// Fixture users used by every mock repository.
///
/// Single mock folder convention: every piece of fake data lives in
/// `lib/data/mock/` so it can be deleted in one sweep when Phase B is
/// done swapping in real backends.
const mockUserListener = User(
  id: 'user-abdullah',
  displayName: 'Abdullah',
  role: UserRole.listener,
  email: 'abdullah@example.com',
  avatarUrl: 'https://example.com/avatar-abdullah.png',
  preferredMasjidId: 'masjid-al-abrar',
);

const mockUserMuadhin = User(
  id: 'user-yusuf',
  displayName: 'Imam Yusuf',
  role: UserRole.muadhin,
  email: 'yusuf@masjid-al-abrar.example',
  avatarUrl: 'https://example.com/avatar-yusuf.png',
  preferredMasjidId: 'masjid-al-abrar',
);

const mockUserAdmin = User(
  id: 'user-admin',
  displayName: 'Platform Admin',
  role: UserRole.admin,
  email: 'admin@athanplatform.io',
);

const mockUsers = <User>[
  mockUserListener,
  mockUserMuadhin,
  mockUserAdmin,
];

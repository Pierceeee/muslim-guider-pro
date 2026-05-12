import '../models/user.dart';

const kMockUsers = <User>[
  User(
    id: 'u_imam_yusuf',
    displayName: 'Imam Yusuf Abdullah',
    role: UserRole.muadhin,
    masjidId: 'm_al_abrar',
  ),
  User(
    id: 'u_aisha',
    displayName: 'Aisha Rahman',
    role: UserRole.listener,
  ),
  User(
    id: 'u_admin',
    displayName: 'Platform Admin',
    role: UserRole.admin,
  ),
];

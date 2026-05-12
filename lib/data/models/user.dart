/// Roles a user can hold in v1. The full RBAC chain
/// (`SUPER_ADMIN > PLATFORM_ADMIN > MASJID_BOARD > IMAM > MUADHIN > MEMBER > GUEST`)
/// lands in B1. v1 mock data uses the slim subset below.
enum UserRole { listener, muadhin, admin }

/// Plain Dart immutable user model.
///
/// Phase 2-7 reserved fields (tazkiyaScore, familyTreeId, walletAddress,
/// etc.) intentionally absent until the schema needs them in B1.
class User {
  const User({
    required this.id,
    required this.displayName,
    required this.role,
    required this.email,
    this.avatarUrl,
    this.preferredMasjidId,
    this.countryCode = 'GB',
    this.timezone = 'Europe/London',
  });

  final String id;
  final String displayName;
  final UserRole role;
  final String email;
  final String? avatarUrl;
  final String? preferredMasjidId;
  final String countryCode;
  final String timezone;
}

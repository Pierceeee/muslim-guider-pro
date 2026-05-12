/// Aggregate listener metrics rendered on the profile screen.
///
/// v1 mock returns hardcoded values; B-phase backs each field with a real
/// aggregate query:
///   • broadcastsHeard — count of distinct streams the user has subscribed to
///   • masjidsVerified — count of unique Masjids the user has Layer-4 scanned
///   • tazkiyaScore   — Phase 2 (Tazkiya) — null until that pillar ships
///   • memberSince    — user.createdAt year
class UserStats {
  const UserStats({
    required this.broadcastsHeard,
    required this.masjidsVerified,
    required this.memberSinceYear,
    this.tazkiyaScore,
  });

  final int broadcastsHeard;
  final int masjidsVerified;
  final int memberSinceYear;

  /// Null while Phase 2 (Tazkiya) isn't built. Phase 2 onset populates this.
  final int? tazkiyaScore;
}

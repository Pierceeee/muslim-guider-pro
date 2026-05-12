/// Lifecycle state for an institutional Masjid record.
/// Mirrors the verification chain documented in `docs/BUILD_PLAN.md` §2 / RFQ §4.
enum MasjidStatus {
  pendingVerification,
  pendingMuadhinAuth,
  active,
  suspended,
  rejected,
}

class Masjid {
  const Masjid({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.streetAddress,
    this.heroImageUrl,
    this.distanceKm,
    this.isBroadcasting = false,
    this.currentStreamId,
    this.isVerified = false,
    this.openStatusLabel,
    this.timezone = 'Europe/London',
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final MasjidStatus status;

  /// Optional street line, e.g. "12 Alum Rock Rd". Combine with [city] for
  /// the full display address.
  final String? streetAddress;

  final String? heroImageUrl;

  /// Convenience field populated by `MasjidRepository.getNearby` when the
  /// caller's location is known. Null when the masjid is loaded out of
  /// proximity context.
  final double? distanceKm;

  final bool isBroadcasting;
  final String? currentStreamId;

  /// Whether the masjid has cleared the verification chain
  /// (RFQ §4 Layers 1-3 minimum, or 1-4 for "fully verified").
  final bool isVerified;

  /// Short human label about today's opening hours, e.g. "Open until 10:00 PM"
  /// or "Opens at 4:30 AM". v1 keeps this as a denormalised string; B-phase
  /// can compute it from a structured schedule.
  final String? openStatusLabel;

  final String timezone;

  /// Single-line address used in masjid-detail and similar surfaces:
  /// "12 Alum Rock Rd, Birmingham" — falls back to just the city if no
  /// street is set.
  String get displayAddress => streetAddress == null
      ? '$city, $country'
      : '$streetAddress, $city';
}

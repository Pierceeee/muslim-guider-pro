import '../models/masjid.dart';

/// Masjid registry queries. Phase F: mock fixtures. Phase B2: Firestore +
/// `geoflutterfire_plus` geohash queries.
abstract class MasjidRepository {
  /// Masjids near a given coordinate, sorted by ascending distance.
  /// `radiusKm` defaults to 25 to match the prototype's "nearby" copy.
  Future<List<Masjid>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm,
    int limit,
  });

  /// Single masjid by id; throws [StateError] if unknown.
  Future<Masjid> getById(String masjidId);

  /// Full-text search across masjid names + cities.
  Future<List<Masjid>> search(String query);

  /// Currently-featured masjids (broadcasting now, high-trust, or hand-picked
  /// for the home `home-listener` screen).
  Future<List<Masjid>> getFeatured();
}

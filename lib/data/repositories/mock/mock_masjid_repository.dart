import '../../mock/mock_masjids.dart';
import '../../models/masjid.dart';
import '../masjid_repository.dart';

/// In-memory implementation of [MasjidRepository] backed by `mock_masjids.dart`.
/// Swapped for `FirestoreMasjidRepository` in B2.
class MockMasjidRepository implements MasjidRepository {
  const MockMasjidRepository();

  @override
  Future<List<Masjid>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    int limit = 20,
  }) async {
    // Mock fixtures already have distanceKm baked in. In B2 we compute real
    // Haversine distance and sort by it.
    final list = mockMasjids
        .where((m) => (m.distanceKm ?? double.infinity) <= radiusKm)
        .toList()
      ..sort(
        (a, b) =>
            (a.distanceKm ?? double.infinity).compareTo(
              b.distanceKm ?? double.infinity,
            ),
      );
    return list.take(limit).toList();
  }

  @override
  Future<Masjid> getById(String masjidId) async {
    return mockMasjids.firstWhere(
      (m) => m.id == masjidId,
      orElse: () =>
          throw StateError('No mock masjid with id "$masjidId"'),
    );
  }

  @override
  Future<List<Masjid>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return mockMasjids;
    return mockMasjids
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.city.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<List<Masjid>> getFeatured() async {
    // "Featured" rule for v1: currently broadcasting masjids first, then
    // any active masjid. Real ranking lands in B2 once we have trust scores.
    final featured = <Masjid>[
      ...mockMasjids.where((m) => m.isBroadcasting),
      ...mockMasjids.where(
        (m) => !m.isBroadcasting && m.status == MasjidStatus.active,
      ),
    ];
    return featured;
  }
}

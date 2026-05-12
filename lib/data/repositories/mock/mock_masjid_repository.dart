import '../../mock/mock_masjids.dart';
import '../../models/masjid.dart';
import '../masjid_repository.dart';

class MockMasjidRepository implements MasjidRepository {
  @override
  Masjid? findById(String id) {
    for (final m in kMockMasjids) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  List<Masjid> all() => List.unmodifiable(kMockMasjids);
}

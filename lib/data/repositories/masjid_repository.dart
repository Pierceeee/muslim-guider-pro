import '../models/masjid.dart';

abstract class MasjidRepository {
  Masjid? findById(String id);
  List<Masjid> all();
}

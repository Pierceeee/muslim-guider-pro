import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';

void main() {
  final repo = MockMasjidRepository();

  test('findById returns Masjid Al-Abrar', () {
    final m = repo.findById('m_al_abrar');
    expect(m?.name, 'Masjid Al-Abrar');
    expect(m?.city, 'Birmingham');
  });

  test('findById returns null for unknown id', () {
    expect(repo.findById('nope'), isNull);
  });

  test('all returns three masjids', () {
    expect(repo.all().length, 3);
  });
}

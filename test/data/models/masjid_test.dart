import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/masjid.dart';

void main() {
  test('Masjid stores its authorised muadhin ids', () {
    const m = Masjid(
      id: 'm_al_abrar', name: 'Masjid Al-Abrar', city: 'Birmingham',
      authorisedMuadhinIds: ['u_imam_yusuf'],
    );
    expect(m.authorisedMuadhinIds, contains('u_imam_yusuf'));
    expect(m.isBroadcasting, isFalse);
  });

  test('copyWith updates isBroadcasting and currentStreamId together', () {
    const m = Masjid(
      id: 'm1', name: 'X', city: 'Y', authorisedMuadhinIds: [],
    );
    final live = m.copyWith(isBroadcasting: true, currentStreamId: 's1');
    expect(live.isBroadcasting, isTrue);
    expect(live.currentStreamId, 's1');
  });
}

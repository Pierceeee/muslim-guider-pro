import '../models/masjid.dart';

const kMockMasjids = <Masjid>[
  Masjid(
    id: 'm_al_abrar',
    name: 'Masjid Al-Abrar',
    city: 'Birmingham',
    authorisedMuadhinIds: ['u_imam_yusuf'],
  ),
  Masjid(
    id: 'm_al_noor',
    name: 'Masjid Al-Noor',
    city: 'Birmingham',
    authorisedMuadhinIds: [],
  ),
  Masjid(
    id: 'm_al_huda',
    name: 'Masjid Al-Huda',
    city: 'Manchester',
    authorisedMuadhinIds: [],
  ),
];

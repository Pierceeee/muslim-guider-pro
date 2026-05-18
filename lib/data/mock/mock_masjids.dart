import '../models/masjid.dart';

const kMockMasjids = <Masjid>[
  Masjid(
    id: 'm_al_abrar',
    name: 'Masjid Al-Abrar',
    city: 'Birmingham',
    authorisedMuadhinIds: ['u_imam_yusuf'],
    latitude: 52.4862,
    longitude: -1.8904,
  ),
  Masjid(
    id: 'm_al_noor',
    name: 'Masjid Al-Noor',
    city: 'Birmingham',
    authorisedMuadhinIds: [],
    latitude: 52.4862,
    longitude: -1.8904,
  ),
  Masjid(
    id: 'm_al_huda',
    name: 'Masjid Al-Huda',
    city: 'Manchester',
    authorisedMuadhinIds: [],
    latitude: 53.4808,
    longitude: -2.2426,
  ),
];

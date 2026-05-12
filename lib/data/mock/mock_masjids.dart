import '../models/masjid.dart';

/// Fixture Masjid records used by every mock repository.
///
/// Coverage spans the prototype's three "many-masjid" surfaces:
///   • `home-listener` (masjid card + live broadcasts list)
///   • `nearby-masjids` (4-card list)
///   • `masjid-detail` (focused on Al-Abrar)
///
/// Coordinates centre roughly on Birmingham so the proximity engine picks
/// them all up. Distance is denormalised onto each record because v1
/// computes it server-side (B-phase swaps this for real Haversine maths).

const mockMasjidAlAbrar = Masjid(
  id: 'masjid-al-abrar',
  name: 'Masjid Al-Abrar',
  streetAddress: '12 Alum Rock Rd',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4862,
  longitude: -1.8904,
  status: MasjidStatus.active,
  heroImageUrl: 'https://example.com/masjid-al-abrar.jpg',
  distanceKm: 0.4,
  isBroadcasting: true,
  currentStreamId: 'stream-abrar-asr',
  isVerified: true,
  openStatusLabel: 'Open until 10:00 PM',
);

const mockMasjidAlHuda = Masjid(
  id: 'masjid-al-huda',
  name: 'Al-Huda Mosque',
  streetAddress: '224 Stoney Lane',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4719,
  longitude: -1.8731,
  status: MasjidStatus.active,
  distanceKm: 0.4,
  isBroadcasting: true,
  currentStreamId: 'stream-huda-asr',
  isVerified: true,
  openStatusLabel: 'Open until 10:00 PM',
);

const mockMasjidMadina = Masjid(
  id: 'masjid-madina',
  name: 'Madina Islamic Center',
  streetAddress: '180 Naseby Rd',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4801,
  longitude: -1.8612,
  status: MasjidStatus.active,
  distanceKm: 1.2,
  isVerified: true,
  openStatusLabel: 'Opens at 4:30 AM',
);

const mockMasjidBaitul = Masjid(
  id: 'masjid-baitul',
  name: 'Baitul Mukarram',
  streetAddress: '14 Stratford Rd',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4640,
  longitude: -1.8590,
  status: MasjidStatus.active,
  distanceKm: 2.8,
  isBroadcasting: true,
  currentStreamId: 'stream-baitul-quran',
  openStatusLabel: 'Open until 11:30 PM',
);

const mockMasjidGrandCentral = Masjid(
  id: 'masjid-grand-central',
  name: 'Grand Central Masjid',
  streetAddress: '180 Bordesley Green',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4732,
  longitude: -1.8483,
  status: MasjidStatus.active,
  distanceKm: 4.1,
  isVerified: true,
  openStatusLabel: 'Open for Isha',
);

const mockMasjidDarulGhufran = Masjid(
  id: 'masjid-darul-ghufran',
  name: 'Darul Ghufran',
  streetAddress: '503 Coventry Rd',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4666,
  longitude: -1.8434,
  status: MasjidStatus.active,
  distanceKm: 3.5,
  isBroadcasting: true,
  currentStreamId: 'stream-darul-ghufran-asr',
  isVerified: true,
  openStatusLabel: 'Open until 11:00 PM',
);

const mockMasjidAlAnsar = Masjid(
  id: 'masjid-al-ansar',
  name: 'Al-Ansar Mosque',
  streetAddress: '88 Alum Rock Rd',
  city: 'Birmingham',
  country: 'United Kingdom',
  latitude: 52.4889,
  longitude: -1.8731,
  status: MasjidStatus.active,
  distanceKm: 0.9,
  isBroadcasting: true,
  currentStreamId: 'stream-al-ansar-quran',
  isVerified: true,
  openStatusLabel: 'Open until 10:30 PM',
);

const mockMasjidSultan = Masjid(
  id: 'masjid-sultan',
  name: 'Sultan Mosque',
  streetAddress: '3 Muscat St',
  city: 'Singapore',
  country: 'Singapore',
  latitude: 1.3026,
  longitude: 103.8593,
  status: MasjidStatus.active,
  // Geographically far — included for global-search coverage but not nearby.
  distanceKm: 10684,
  isBroadcasting: true,
  currentStreamId: 'stream-sultan-jumuah',
  isVerified: true,
  openStatusLabel: 'Open until 11:00 PM',
  timezone: 'Asia/Singapore',
);

const mockMasjidEastLondon = Masjid(
  id: 'masjid-east-london',
  name: 'East London Mosque',
  streetAddress: '46-92 Whitechapel Rd',
  city: 'London',
  country: 'United Kingdom',
  latitude: 51.5172,
  longitude: -0.0654,
  status: MasjidStatus.active,
  distanceKm: 161,
  isVerified: true,
  openStatusLabel: 'Open until 11:30 PM',
);

/// All masjids in the v1 fixture set. Order matters only for the rare caller
/// that doesn't filter or sort — e.g. an unstyled debug list.
const mockMasjids = <Masjid>[
  mockMasjidAlAbrar,
  mockMasjidAlHuda,
  mockMasjidMadina,
  mockMasjidBaitul,
  mockMasjidGrandCentral,
  mockMasjidDarulGhufran,
  mockMasjidAlAnsar,
  mockMasjidSultan,
  mockMasjidEastLondon,
];

import '../models/stream_record.dart';

/// Hand-curated `DateTime`s used by the mock fixtures.
///
/// Anchored to TODAY's date so "ended X min ago" labels stay coherent
/// regardless of when the app is launched. v1 mocks; B-phase backend will
/// stamp these from real server clocks.
final _now = DateTime.now();
DateTime _at(int hour, int minute) =>
    DateTime(_now.year, _now.month, _now.day, hour, minute);

// ── Live now ──────────────────────────────────────────────────────────────

/// Live — Asr at Masjid Al-Abrar. The user's preferred masjid; the dashboard's
/// hero masjid card and masjid-detail "Listen" CTA both point here.
final mockStreamAbrarAsr = StreamRecord(
  id: 'stream-abrar-asr',
  masjidId: 'masjid-al-abrar',
  muadhinId: 'user-yusuf',
  muadhinName: 'Imam Yusuf',
  title: 'Asr Khutbah',
  prayer: StreamPrayer.asr,
  startedAt: _at(15, 47),
  status: StreamStatus.live,
  listenerCountPeak: 1247,
  listenerCountCurrent: 1198,
  latencyMs: 428,
);

/// Live — Asr at Al-Huda Mosque.
final mockStreamHudaAsr = StreamRecord(
  id: 'stream-huda-asr',
  masjidId: 'masjid-al-huda',
  muadhinId: 'user-yusuf',
  muadhinName: 'Sheikh Idris',
  title: 'Asr Prayer',
  prayer: StreamPrayer.asr,
  startedAt: _at(15, 50),
  status: StreamStatus.live,
  listenerCountPeak: 420,
  listenerCountCurrent: 388,
  latencyMs: 460,
);

/// Live — Jumu'ah at Sultan Mosque (Singapore). Highest-listenership stream
/// in the fixture set so it leads the dashboard's "Live broadcasts" list.
final mockStreamSultanJumuah = StreamRecord(
  id: 'stream-sultan-jumuah',
  masjidId: 'masjid-sultan',
  muadhinId: 'user-yusuf',
  muadhinName: 'Sheikh Hassan',
  title: 'Khutbah in progress',
  prayer: StreamPrayer.jumuah,
  startedAt: _at(12, 45),
  status: StreamStatus.live,
  listenerCountPeak: 1240,
  listenerCountCurrent: 1240,
  latencyMs: 512,
);

/// Live — Asr at Darul Ghufran.
final mockStreamDarulGhufranAsr = StreamRecord(
  id: 'stream-darul-ghufran-asr',
  masjidId: 'masjid-darul-ghufran',
  muadhinId: 'user-yusuf',
  muadhinName: 'Imam Bilal',
  title: 'Asr Prayer',
  prayer: StreamPrayer.asr,
  startedAt: _at(15, 44),
  status: StreamStatus.live,
  listenerCountPeak: 850,
  listenerCountCurrent: 850,
  latencyMs: 480,
);

/// Live — Quran recitation at Al-Ansar Mosque.
final mockStreamAlAnsarQuran = StreamRecord(
  id: 'stream-al-ansar-quran',
  masjidId: 'masjid-al-ansar',
  muadhinId: 'user-yusuf',
  muadhinName: 'Qari Tariq',
  title: 'Quran Recitation',
  prayer: StreamPrayer.dhikr,
  startedAt: _at(15, 30),
  status: StreamStatus.live,
  listenerCountPeak: 420,
  listenerCountCurrent: 420,
  latencyMs: 510,
);

/// Live — Quran recitation at Baitul Mukarram.
final mockStreamBaitulQuran = StreamRecord(
  id: 'stream-baitul-quran',
  masjidId: 'masjid-baitul',
  muadhinId: 'user-yusuf',
  muadhinName: 'Qari Imran',
  title: 'Quran Recitation',
  prayer: StreamPrayer.dhikr,
  startedAt: _at(15, 25),
  status: StreamStatus.live,
  listenerCountPeak: 210,
  listenerCountCurrent: 210,
  latencyMs: 540,
);

// ── Ended today (replay available) ────────────────────────────────────────

final mockStreamAbrarDhuhr = StreamRecord(
  id: 'stream-abrar-dhuhr',
  masjidId: 'masjid-al-abrar',
  muadhinId: 'user-yusuf',
  muadhinName: 'Imam Yusuf',
  title: 'Dhuhr Prayer',
  prayer: StreamPrayer.dhuhr,
  startedAt: _at(12, 38),
  endedAt: _at(12, 56),
  status: StreamStatus.ended,
  listenerCountPeak: 612,
  endReason: StreamEndReason.normal,
  replayUrl: 'https://example.com/replays/stream-abrar-dhuhr.m4a',
);

final mockStreamAbrarFajr = StreamRecord(
  id: 'stream-abrar-past-fajr',
  masjidId: 'masjid-al-abrar',
  muadhinId: 'user-yusuf',
  muadhinName: 'Imam Yusuf',
  title: 'Fajr Remembrance',
  prayer: StreamPrayer.fajr,
  startedAt: _at(5, 12),
  endedAt: _at(5, 39),
  status: StreamStatus.ended,
  listenerCountPeak: 832,
  endReason: StreamEndReason.normal,
  replayUrl: 'https://example.com/replays/stream-abrar-past-fajr.m4a',
);

/// All streams in the v1 fixture set. Repositories filter by status as needed.
final mockStreams = <StreamRecord>[
  mockStreamAbrarAsr,
  mockStreamHudaAsr,
  mockStreamSultanJumuah,
  mockStreamDarulGhufranAsr,
  mockStreamAlAnsarQuran,
  mockStreamBaitulQuran,
  mockStreamAbrarDhuhr,
  mockStreamAbrarFajr,
];

# Muslim Guider Pro

Broadcaster (Muadhin) and listener mobile app for live-streaming the Athan and related prayer-time tools.

This repository implements the broadcaster side per the HTML prototype in `../prototype`, with real audio capture, local broadcast persistence, computed prayer times, and live Qibla bearing.

## Status

- Phases 1–4 of `docs/superpowers/plans/2026-05-14-prototype-alignment-mvp.md` complete.
- Broadcaster screens (Home, Dashboard, Go-Live, Live, Summary) match prototype.
- Real audio capture (`record`), local persistence (`shared_preferences`), real prayer times (`adhan_dart`), live Qibla (`flutter_compass`) wired.
- 102 widget/unit tests pass. 5 golden tests are skipped pending bundled-font assets (see `test/features/broadcaster/goldens/README.md`).

## Stack

- Flutter SDK `^3.11.5`
- `flutter_riverpod ^2.5.1` — state management
- `go_router ^14.0.0` — navigation
- `flutter_svg ^2.0.10`, `google_fonts ^6.2.1` (DM Sans + Instrument Sans), `material_symbols_icons ^4.2901.0`
- `record ^5.1.2`, `path_provider ^2.1.4`, `shared_preferences ^2.3.2`
- `adhan_dart ^2.0.1`, `geolocator ^13.0.1`, `flutter_compass ^0.8.1`, `permission_handler ^11.3.1`
- `hijri ^3.0.0`, `intl ^0.20.2`

## Running

```
flutter pub get
flutter run            # default device
flutter run -d chrome  # web (mic + compass not supported on web; sine fallback active)
flutter run -d android # real mic + compass
```

## Tests

```
flutter test                 # 102 widget/unit tests
flutter test --tags golden   # currently 5 skipped (see test/features/broadcaster/goldens/README.md)
flutter analyze              # known: 3 pre-existing minor issues (2 info, 1 warning)
```

## Plan & docs

- Implementation plan: `docs/superpowers/plans/2026-05-14-prototype-alignment-mvp.md`
- HTML prototype reference: `../prototype/screens/` (sibling repo)
- Older Flutter reference (GetX-based, for widget composition only): `../muslimguider-flutter/`

## Project structure

```
lib/
├── core/
│   ├── theme/        — AppColors, AppTextStyles, AppTheme
│   ├── widgets/      — shared widgets (BgPattern, PrayerWidget, FloatingPillNav,
│   │                   SlideToBroadcast, MicLevelMeter, AudioWaveform, LiveBanner,
│   │                   BigRedBroadcastButton, RetentionChart, PreCheckList, …)
│   ├── icons/        — Sym helper over material_symbols_icons
│   ├── router/       — go_router + broadcaster ShellRoute
│   └── utils/        — prayer_format helpers
├── data/
│   ├── models/       — Masjid, BroadcastStream, PrayerTimes, User, …
│   ├── repositories/ — abstract interfaces + mock/ + real/
│   ├── mock/         — seed data for development
│   └── services/     — PrayerTimeService, QiblaService
├── features/broadcaster/
│   ├── home/         — Prayer widget home screen
│   ├── dashboard/    — KPI grid + recent broadcasts
│   ├── go_live/      — Pre-broadcast checks
│   ├── live/         — Active broadcast + waveform
│   └── summary/      — Post-broadcast summary
├── providers/        — Riverpod providers
└── main.dart
```

## Deferred for follow-up

- Listener-side screens (Nearby, Inbox, Me) are `StubScreen` placeholders.
- Manual device QA (Android, iOS, Chrome) not yet executed from sandbox.
- Bundled font assets (Instrument Sans, DM Sans TTF) needed to un-skip 5 golden tests.
- Multiple calculation methods / madhabs per masjid (currently hardcoded to muslimWorldLeague + Shafi).
- Android TV / Apple TV screens (Phase 1, owner override 2026-05-15) — not yet started.

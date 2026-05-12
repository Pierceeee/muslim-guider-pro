# Muslim Guider Pro — Build Plan

**How we will build Phase 1 of the Live Athan Broadcasting Platform**

| Field | Value |
|---|---|
| Doc type | Internal build plan (owner-authored, supersedes RFQ where noted) |
| Source RFQ | [`RFQ_muslim_pro_guider.md`](./RFQ_muslim_pro_guider.md) (RFQ-2024-001 v1.0) |
| Created | 2026-05-13 |
| Owner | Project owner (issuer of the RFQ) |
| Status | Draft v1 — pending owner review |
| Target | v1 covers all 36 prototype screens; frontend-first (~10 wk) → backend (~9 wk) → launch (~2 wk); ecosystem hooks reserved but Phase 2-7 features unbuilt |

---

## 0. How to read this doc

The [RFQ](./RFQ_muslim_pro_guider.md) is the **aspirational** spec — the fully-built, agency-delivered, multi-region, RFQ-2024-001-compliant Phase 1.

This doc is the **realistic** Phase 1 — what the owner is actually going to build first. It deviates from the RFQ in specific, documented ways. Sections labeled **"Deviation"** explicitly note where this plan diverges from the RFQ and why.

The mental model:
- The **RFQ** answers: *"What does the fully-realised product look like?"*
- This **build plan** answers: *"What's the smallest version that proves the thing works, that we can build first, without painting ourselves into a corner for Phases 2–7?"*

---

## 1. Decisions snapshot

These are the foundational choices already made by the owner. They drive every section below.

| # | Decision | Rationale | Deviation from RFQ? |
|---|---|---|---|
| D1 | **Owner is also the RFQ issuer** — can override MUST HAVEs at will | The RFQ exists; the owner authors the build plan from it | n/a |
| D2 | **Flutter (Dart) for all clients** — Android, iOS, Web | One codebase, faster iteration, owner-acceptable tradeoffs | Yes — overrides AND-001, IOS-001, AND-002, IOS-002, IOS-011, etc. |
| D3 | **Drop Smart TV from Phase 1 entirely** | No tvOS via Flutter; defer Smart TV to a dedicated future phase | Yes — drops RFQ §3.3 |
| D4 | **7-pillar fields reserved in schema, but only Phase 1 features built in v1** | Phases 2-7 are out of scope, but their reserved user-schema fields are present from day 1 so no migration is needed when those phases activate | Reshape — phases 2-7 features deferred while honoring the RFQ's "7-pillar forward-compat" requirement |
| D5 | **Firebase** for backend (Firestore + Auth + Functions + FCM + Storage) | Lowest day-1 friction; managed services; good Flutter support | Yes — RFQ §6.2 calls for AWS Aurora + Keycloak + EKS |
| D6 | **AWS Chime SDK** for WebRTC streaming, via Flutter platform channels | RFQ-recommended streaming stack; owner accepts SDK-gap cost | Partial — Chime is in RFQ; Flutter integration is non-RFQ |
| D7 | **Frontend-first sequencing** — build all UI screens with mocks before any backend integration | Owner directive (2026-05-13): visual product reviewable end-to-end before backend cost is committed; same codebase swaps mocks for real APIs in Phase B | n/a |
| D8 | **All 36 prototype screens ship in v1** — same codebase, mocks now → real APIs later | Owner directive (2026-05-13): the prototype is the v1 product, not the v2 target | Reshape — moves QR scans, replay, scheduled broadcasts, and Smart TV mobile-pairing UI from "deferred" into v1 |

---

## 2. Scope: what ships in v1

### 2.1 In scope for v1 (all 36 prototype screens, fully backed)

**Frontend (Phase F):**

- All 36 screens from `prototype/` recreated in Flutter (Android + iOS + Web)
- Full design system per §4 — theme tokens, ornament widgets (orb, waveform, live pill, glass card, hero gradient, arabesque, octagonal star), iconography
- Mock data layer (Riverpod + repository pattern) covering every screen's state needs
- Localisation pipeline (English + Arabic, RTL-ready)
- Mock-driven happy paths AND error states for every flow (sign-in failures, stream reconnects, QR scan outside radius, etc.)

**Backend (Phase B):**

- Firebase Auth (email/password + Google + Apple) with biometric unlock (`local_auth`)
- Canonical user profile in Firestore with reserved fields for Phases 2–7
- Masjid registry (Firestore + geohash via `geoflutterfire_plus`) with self-registration + admin approval
- **Full 4-Layer Verification** (no simplification):
  - Layer 1: Board self-registers Masjid
  - Layer 2: Imam (or platform admin) certifies the institution
  - Layer 3: Imam nominates Muadhin
  - Layer 4: 20 community QR scans inside geofenced Masjid radius
- Live Athan broadcast via AWS Chime SDK + Flutter platform channels (one-way audio: Muadhin → many listeners)
- Broadcast recording → S3 → replay playback (the `replay-player` screen is real, not a mock)
- Scheduled broadcasts (Cloud Scheduler triggers Cloud Function)
- Smart TV pairing API (mobile-side pairing UI ships; actual TV apps still deferred to Phase 1.x)
- Prayer times (on-device Adhan calculation, 6 algorithms)
- Push notifications (FCM topics for followed Masjids; scheduled local notifications)
- Admin web dashboard (Flutter Web — Masjid + Muadhin moderation, stream monitor, audit log)
- Crashlytics + Analytics + cost monitoring + budget alerts
- Single Firebase region (US-Central) at v1 launch

**Launch (Phase L):**

- App Store + Google Play submissions
- TestFlight + Google Play internal track beta with ~20 testers
- 7-day pilot with 5 Masjids before public beta

### 2.2 Deferred to Phase 1.x (post-v1 incremental)

- **Smart TV applications** (Android TV + Apple TV — Masjid Mode + Home Mode). Only the mobile-side pairing UI ships in v1.
- Multi-region Chime deployment for <500ms global latency (v1 ships single-region with <1.5s target)
- TURN/STUN tuning for restrictive corporate/school networks
- Webhook outbound events for Masjid-integrators
- Adaptive bitrate down to 8kbps (Chime handles bitrate adaptation; v1 doesn't expose the controls)
- TOTP MFA (biometric covers the MFA need for v1)

### 2.3 Deferred to Phase 2+ (triggered by ecosystem expansion)

- Self-hosted Keycloak / EKS migration — *triggered by Phase 2 (Tazkiya) onset*
- Postgres + PostGIS migration from Firestore — *triggered by Phase 2 or Phase 3 (AnsApp)*
- GraphQL API gateway — *Phase 2+*
- Multi-region cloud deployment + full IaC (Terraform/CDK) — *triggered by 100k+ MAU*
- Graph database (Neo4j or `pg_graphql`) for AnsApp — *Phase 3 trigger*

### 2.4 Pre-launch hardening (required before public marketing push)

- 10,000+ concurrent listener load test
- Third-party penetration test (no Critical/High unresolved)
- WCAG 2.1 AA accessibility audit
- Arabic localisation review by native speaker

### 2.5 Explicitly out of scope

- Phases 2–7 features (Tazkiya, AnsApp, LocalMotion, Sunnah Marriage, Hiring & Services, Decentralised Finance)
- Content moderation of live audio streams
- Payment processing
- Third-party mosque-management software integrations

---

## 3. Architecture overview

```
+--------------------------------------------------------------------------+
|                              CLIENT (Flutter)                            |
|   Android  |  iOS  |  Web (admin dashboard)                              |
|   - Riverpod state mgmt                                                  |
|   - go_router for routing                                                |
|   - flutter_local_notifications + firebase_messaging                     |
|   - local_auth (biometrics)                                              |
|   - Native platform channels:                                            |
|       * AWS Chime SDK (Kotlin on Android, Swift on iOS)                  |
|       * Background audio (just_audio + audio_service)                    |
|       * Background location (geolocator)                                 |
+----------------------------------+---------------------------------------+
                                   |
                          HTTPS / Firebase SDKs
                                   |
+----------------------------------+---------------------------------------+
|                       BACKEND (Firebase + AWS Chime)                     |
|                                                                          |
|   Firebase Auth ----------+                                              |
|                           |                                              |
|   Cloud Functions (Node)--+--> AWS Chime API (CreateMeeting / Attendee)  |
|     - createMeeting()                                                    |
|     - joinMeeting()                                                      |
|     - endMeeting()                                                       |
|     - verifyMasjid()                                                     |
|     - rotateQrToken()                                                    |
|                                                                          |
|   Firestore (NoSQL)                                                      |
|     /users   /masjids   /muadhins   /streams   /verifications            |
|     /qrTokens   /prayerTimes   /auditLog                                 |
|                                                                          |
|   Firebase Storage                                                       |
|     Masjid logos, Muadhin avatars, optional recorded Athan archive       |
|                                                                          |
|   FCM (push)                                                             |
|     Prayer-time reminders, Athan start alerts                            |
|                                                                          |
|   AWS Chime SFU (regional)                                               |
|     One-way audio: Muadhin publishes, listeners subscribe                |
+--------------------------------------------------------------------------+
```

### Why this shape

- **One backend control plane (Firebase) for auth + data + functions + push** — minimises moving parts.
- **AWS Chime as a separate audio plane** — only invoked when a broadcast starts/joins. Firebase orchestrates; Chime delivers audio. Backend cost stays predictable.
- **Native platform channels live in a single Dart-facing module** (`lib/streaming/`) so the rest of the app stays Flutter-pure.

---

## 4. Design system (derived from `prototype/`)

The visual system is fully fleshed out in [`prototype/`](../prototype/) — 36 HTML mockups browseable via `prototype/index.html`. **The prototype is the canonical visual spec**: when this build plan disagrees with a prototype screen on layout, copy, or styling, the prototype wins.

This section extracts the design tokens from the prototype's Tailwind config and maps them to a Flutter theme. The module-screen-coverage table at the end (§4.7) shows which Phase F module owns each prototype category.

### 4.1 Color tokens

Extracted from the Tailwind config in every prototype screen. These map to `ColorScheme` + an `AppColors` theme extension in Flutter.

**Brand & primary (gold/amber)**

| Token | Hex | Flutter mapping | Usage |
|---|---|---|---|
| `primary` | `#f2c050` | `colorScheme.primary` | Brand gold — buttons, accents, prayer-time highlight |
| `primary-container` | `#d4a537` | `colorScheme.primaryContainer` | Filled card backgrounds |
| `on-primary` | `#402d00` | `colorScheme.onPrimary` | Text on gold |
| `primary-fixed` | `#ffdf9f` | extension | Soft gold backgrounds |
| `gold-highlight` | `#F0C75E` | extension | Live-broadcast orb glow, headline accents |
| `gold-deep` | `#8B6914` | extension | Deep gold for gradients and shadow |
| `inverse-primary` | `#795900` | extension | Inverted-surface accent |

**Surfaces**

| Token | Hex | Usage |
|---|---|---|
| `background` / `surface` | `#17130c` | App background (warm dark brown) |
| `bg-deep-night` | `#0F1626` | Hero gradients, splash, live player |
| `bg-elevated` | `#1A2238` | Elevated cards, list items |
| `surface-card` | `#232C44` | Default card background (most common) |
| `surface-container` | `#231f17` | Tonal surface 1 |
| `surface-container-high` | `#2e2921` | Tonal surface 2 |
| `surface-container-highest` | `#39342b` | Tonal surface 3 |
| `surface-inset` | `#2D3658` | Progress-bar tracks, inset wells |

**Ink (text)**

| Token | Hex | Usage |
|---|---|---|
| `ink-primary` | `#FFFFFF` | Primary text on dark |
| `on-surface` / `on-background` | `#ebe1d4` | Default body text (warm white) |
| `ink-muted` | `#A8B0C4` | Secondary text |
| `ink-subtle` | `#6B7280` | Tertiary / disabled text |
| `on-surface-variant` | `#d2c5b0` | Captions on cards |

**Semantic & status**

| Token | Hex | Usage |
|---|---|---|
| `live-red` | `#FF6B6B` | Live-broadcast indicator |
| `live-red-bg` | `#3D1A1A` | Live-pill background |
| `success-green` | `#4ADE80` | Verification confirmed |
| `success-green-bg` | `#1A3D2A` | Success pill background |
| `warning-amber` | `#FFA94D` | Pending verification |
| `warning-amber-bg` | `#3D2F0F` | Warning pill background |
| `error` | `#ffb4ab` | Error text |
| `error-container` | `#93000a` | Error pill background |
| `maghrib-orange` | `#E8763A` | Sunset / Maghrib prayer accent |
| `info-blue` | `#4FC3D9` | Informational chips |
| `purple-deep` | `#5B2C9F` | Hero gradient secondary |
| `secondary` / `secondary-fixed-dim` | `#dcb8ff` | Tonal lavender accents |
| `tertiary` | `#adc8ff` | Tertiary blue accent |

**Borders & outlines**

| Token | Hex | Usage |
|---|---|---|
| `border-low` | `#2D3658` | Subtle dividers |
| `border-medium` | `#3A4566` | Card outlines |
| `outline` | `#9b8f7c` | Form-control outlines |
| `outline-variant` | `#4e4636` | Disabled outlines |

### 4.2 Typography

| Family | Source | Weights | Flutter mapping | Used for |
|---|---|---|---|---|
| **Instrument Sans** | Google Fonts | 400, 700 | `GoogleFonts.instrumentSans()` | Headlines (`font-headline-xl`/`-lg`/`-md`), numeral time displays |
| **DM Sans** | Google Fonts | 400, 500, 700 | `GoogleFonts.dmSans()` | Body (`font-body-md`/`-lg`), labels (`font-label-caps`) |
| **Material Symbols Outlined** | Google Fonts (variable) | variable | Bundle variable font as asset; use `Icon(IconData(codepoint))` or `material_symbols_icons` pkg | All icons |
| **Noto Naskh Arabic** | Google Fonts (TBD) | 400, 500, 700 | `GoogleFonts.notoNaskhArabic()` | Arabic UI when localised (RTL) |

**Type scale** (extracted from prototype):

| Style | Approx size | Family | Example |
|---|---|---|---|
| `headline-xl` | 64px / leading-none | Instrument Sans 700 | Hero prayer countdown |
| `headline-lg` | 28–32px | Instrument Sans 700 | Page titles |
| `headline-md` | 18–20px | Instrument Sans 700 | Card titles, masjid names |
| `body-lg` | 14px | DM Sans 400/500 | List rows, primary text |
| `body-md` | 13px | DM Sans 400 | Secondary text |
| `label-caps` | 10–11px | DM Sans 500 uppercase, `tracking-[0.2em]` | Pills, chip labels, section eyebrows |
| `numeral-time` | tabular-nums | Instrument Sans | Prayer-time displays |

### 4.3 Spacing & radii

| Token | Value | Usage |
|---|---|---|
| `unit` | 4px | Base spacing unit |
| `gutter` | 16px | Inter-element gap |
| `section-gap` | 24px | Between content sections |
| `container-margin` | 20px | Screen-edge padding |
| `card-padding` | 16px | Default card inner padding |
| `radius.DEFAULT` | 4px | |
| `radius.lg` | 8px | |
| `radius.xl` | 12px | Most cards |
| `radius.21` | 21px | Hero cards (custom — `rounded-[21px]` recurs throughout) |
| `radius.full` | 9999px | Pills, chips, avatars |

### 4.4 Motifs & ornamentation

These recurring visual elements give the app its Islamic character. They must be reproduced faithfully in Flutter:

1. **Arabesque pattern** — small repeating SVG (8-pointed star, gold at 8% opacity). Inline source visible in `prototype/screens/smart-tv-pairing.html`. Use behind hero sections and modals — implement as a tiled `Image.asset` or `CustomPainter`.
2. **Octagonal star frame** — 8-point clip-path surrounding the live audio orb (`live-player-masjid-al-abrar.html`). CSS: `polygon(30% 0%, 70% 0%, 100% 30%, 100% 70%, 70% 100%, 30% 100%, 0% 70%, 0% 30%)`. In Flutter: `ClipPath` with a custom `OctagonalStarClipper` or a `CustomPainter` for the outlined version.
3. **Gold orb visualizer** — radial gradient from `gold-highlight` through `primary` to `gold-deep`, with a soft inset highlight at 30% 30%, surrounded by two faint expanding rings. The orb pulses during live broadcast. Implement as an `AnimatedBuilder` widget.
4. **Audio waveform bars** — ~44 vertical bars (1.5px wide, heights 4–14px), alternating between `primary` and `ink-primary`. Used during live playback. In Phase F: a fixed-amplitude animated visualizer driven by a periodic `AnimationController`. In Phase B: real amplitude data from the Chime SDK if exposed; otherwise the synthetic visualizer stays.
5. **Live pill** — small rounded chip, pulsing red dot, `live-red` text on `live-red-bg` — often shows latency in ms ("LIVE · 428 ms"). Used on player, broadcaster dashboard, and home cards.
6. **Glass surfaces** — `backdrop-blur-xl` cards over patterned backgrounds. Flutter: `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` inside a `ClipRRect`.
7. **Subtle gold border** — cards commonly use `border-primary/10` (10% gold). In Flutter: `Border.all(color: AppColors.primary.withOpacity(0.1), width: 1)`.
8. **Hero gradient** — `bg-gradient-to-br from-purple-deep to-bg-deep-night`. The recurring hero treatment (next-prayer card, splash, live player). Build as a reusable `HeroGradient` widget.

### 4.5 Iconography

- **Material Symbols Outlined** (variable font) is the entire icon set. The prototype uses both outlined and filled variants intentionally (filled for "active/on" states via `font-variation-settings: 'FILL' 1`).
- Flutter approach: bundle the Material Symbols variable font as an asset and use `Icon(IconData(codepoint, fontFamily: 'MaterialSymbols'))`, OR use the community package `material_symbols_icons`.
- Common symbols used: `mosque`, `verified`, `grade`, `expand_more`, `arrow_back`, `pause`, `play_arrow`, `qr_code_scanner`, `wifi`, `notifications`, `settings`, `location_on`, `schedule`, `volume_up`, `mic`.

### 4.6 Flutter wiring

Single source of design tokens in `lib/theme/`:

```
lib/theme/
  app_colors.dart       # Static const Color values for every token above
  app_typography.dart   # TextStyle constants for each font-* token
  app_spacing.dart      # Padding/gap constants (unit, gutter, section_gap, ...)
  app_radii.dart        # BorderRadius constants
  app_theme.dart        # ThemeData (dark) wiring ColorScheme + TextTheme + extensions
  ornaments/
    arabesque_painter.dart       # CustomPainter for the repeating motif
    octagonal_star_clipper.dart  # ClipPath + decorative border
    gold_orb.dart                # Animated orb widget
    audio_waveform.dart          # Animated bars
    hero_gradient.dart           # Reusable BoxDecoration
    live_pill.dart               # Pulsing live indicator with optional latency
    glass_card.dart              # BackdropFilter card primitive
```

The app is **dark-by-default**. A light theme is not part of v1 — the prototype doesn't define one. If the admin dashboard needs light surfaces later, that's a separate workstream.

### 4.7 Prototype → module coverage

Per decision D8, **all 36 prototype screens ship in v1.** Each Phase F module owns one prototype category — there are no "parked" screens at the v1 level (Smart TV apps themselves are Phase 1.x, but the mobile-side `smart-tv-pairing` screen ships in F4).

| F-module | Prototype category | Screens (count) |
|---|---|---|
| **F3 Onboarding & Auth** | Onboarding & Auth | 10 — `splash-screen`, `onboarding-welcome`, `onboarding-proximity`, `onboarding-verified`, `permissions-bundle`, `language-region-selection`, `sign-in-centered-variant`, `create-account-step-1/2/3` |
| **F4 Listener** | Listener | 14 — `home-prayer-widget`, `home-listener`, `nearby-masjids`, `search-results-nearby`, `masjid-detail`, `live-player-masjid-al-abrar`, `replay-player-masjid-al-abrar`, `stream-ended-state`, `stream-reconnecting-state`, `prayer-schedule-birmingham`, `inbox`, `profile`, `settings`, `smart-tv-pairing` |
| **F5 Broadcaster** | Broadcaster | 7 — `home-prayer-widget-muadhin`, `masjid-dashboard-muadhin`, `go-live-pre-broadcast-check`, `live-broadcast-masjid-al-abrar`, `schedule-broadcast-muadhin`, `broadcast-summary-masjid-al-abrar`, `audit-log-muadhin` |
| **F6 Verification** | Verification | 5 — `qr-scan-masjid-al-abrar`, `qr-scan-success`, `qr-scan-error-outside-radius`, `verification-status-masjid-al-abrar`, `verification-history` |

**Total:** 36 screens. The admin web dashboard (built in B-phase, not F-phase) does not have prototype mockups — it derives from the same design tokens.

The `live-athan-masjid-companion`, `onboarding-auth-flow-compact`, `prayer-schedule-birmingham-compact` HTML files in `prototype/screens/` are variants not registered in `prototype/index.html` — treated as design alternatives, not separate work.

---

## 5. Phase structure (frontend-first)

Per decision D7, work is sequenced into three phases. Phase F builds the entire Flutter frontend with mock data. Phase B replaces mock repository implementations with real Firebase + AWS Chime + Cloud Functions backends. Phase L hardens, polishes, and launches.

```
   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
   │   PHASE F    │ ─→ │   PHASE B    │ ─→ │   PHASE L    │
   │  Frontend    │    │   Backend    │    │   Launch     │
   │  + mocks     │    │  integration │    │              │
   │              │    │              │    │              │
   │  ~10 weeks   │    │  ~9 weeks    │    │   ~2 weeks   │
   │  36 screens  │    │ Mocks → APIs │    │ Stores + beta│
   └──────────────┘    └──────────────┘    └──────────────┘
```

### 5.1 Phase F modules (frontend with mocks)

| # | Module | Depends on | Effort | Output |
|---|---|---|---|---|
| F0 | Foundation: Flutter scaffold + lint + CI + `go_router` skeleton | — | 1 wk | App boots; CI green; all 36 routes navigable to placeholders |
| F1 | Design system + ornament widgets (`lib/theme/` per §4) | F0 | 1.5 wk | Reusable theme + 6 ornament widgets + showcase route |
| F2 | Mock data layer + Riverpod state management | F0 | 1 wk | Repository interfaces + fake impls + fixtures |
| F3 | Onboarding & Auth screens (10 prototype screens) | F1, F2 | 1.5 wk | Splash, onboarding, sign-in, create-account flow |
| F4 | Listener screens (14 prototype screens) | F1, F2 | 2.5 wk | Home, nearby, masjid detail, live/replay player, prayer schedule, profile, settings, Smart TV pairing UI |
| F5 | Broadcaster screens (7 prototype screens) | F1, F2 | 1.5 wk | Muadhin home, dashboard, pre-broadcast check, live broadcast UI, scheduled-broadcast UI, summary, audit log |
| F6 | Verification screens (5 prototype screens) | F1, F2 | 1 wk | QR scan camera flow, success/error states, verification status, history |
| F7 | Frontend QA + design review | F3-F6 | 0.5 wk | Pixel-parity pass against prototype + owner sign-off |
| | **Phase F total** | | **~10 wk** | **All 36 screens running on real devices, no backend** |

### 5.2 Phase B modules (backend integration)

| # | Module | Depends on | Effort | Output |
|---|---|---|---|---|
| B0 | Firebase project + environment setup (dev/staging/prod) | Phase F complete | 0.5 wk | Three Firebase projects provisioned; AWS Chime IAM set up |
| B1 | Auth + user profile backend (swap repos → Firebase Auth + Firestore) | B0 | 1 wk | Real sign-in, real profiles |
| B2 | Masjid registry + proximity backend | B1 | 1 wk | Real Firestore + geohash queries |
| B3 | Verification (full 4-Layer) backend | B2 | 1.5 wk | Cloud Functions for all 4 layers, QR validation, geofence enforcement |
| B4 | Streaming backend (AWS Chime + native platform channels) | B2 | 2.5 wk | Real WebRTC audio, broadcaster + listener |
| B5 | Prayer times + notifications backend | B1 | 1 wk | FCM topic subs, scheduled push |
| B6 | Auxiliary backends: recording, scheduled broadcasts, Smart TV pairing API | B4 | 1 wk | Chime recording → S3, Cloud Scheduler triggers, TV pairing codes |
| B7 | Backend integration testing | B1–B6 | 0.5 wk | All mock impls swapped; smoke test green |
| | **Phase B total** | | **~9 wk** | **Real APIs powering all 36 screens** |

### 5.3 Phase L modules (launch)

| # | Module | Effort | Output |
|---|---|---|---|
| L0 | Polish + analytics + crashlytics + monitoring | 1 wk | Analytics events, Crashlytics, security rules audit, cost alerts |
| L1 | Store submissions + beta + bug bash | 1 wk | Apple + Google submissions; TestFlight + Play Internal; 7-day pilot |
| | **Phase L total** | **~2 wk** | **Public beta live** |

### 5.4 Total project

**~21 weeks** of net effort. With buffer for holidays, sick days, and unknown unknowns, plan for **24-26 weeks** calendar time.

**Parallelism:** Phase F has limited parallelism (F1 + F2 can overlap with each other; F3-F6 require F1+F2 to land). Phase B can parallelise B3, B4, B5 once B2 lands.

---

## 6. Module details

> **Reading guide:** Phase F (frontend, with mocks) gets detailed deliverables because that's what's happening first. Phase B (backend integration) is summarised — full backend specs become their own per-module docs when Phase B begins.

---

### Phase F — Frontend with mocks

#### F0 — Foundation (1 week)

**Goal:** project skeleton + automation pipeline so every subsequent module ships green. No backend dependencies yet.

**Deliverables:**
- Flutter project scaffold (already done — Android + iOS + Web targets, `com.muslimguider` org)
- Folder convention:
  - `lib/features/{onboarding,auth,listener,broadcaster,verification,admin,common}/screens/`
  - `lib/theme/` (filled in F1)
  - `lib/data/{repositories,mocks,fixtures,models}/` (filled in F2)
- Routing skeleton with `go_router` — empty placeholder widgets at all 36 routes
- Riverpod 2.x state management: `flutter_riverpod`, `riverpod_generator`, `freezed` for state classes, `riverpod_lint`
- Localisation pipeline (`flutter_localizations` + `intl`) — English + Arabic placeholder ARB files; RTL detection wired
- Strict lint (`very_good_analysis: ^6.x`) + `dart format` enforced in CI
- GitHub Actions CI: `flutter analyze`, `flutter test`, `flutter build apk --debug`, `flutter build ios --no-codesign`, `flutter build web`
- Pre-commit hook running `dart format` and `flutter analyze`
- `README.md` at `lib/` root explaining folder convention
- **No Firebase, no AWS dependencies yet** — F0 explicitly forbids backend SDK imports

**Acceptance:**
- All 36 routes navigable via `go_router` (each shows a placeholder with the route name)
- CI runs green on a no-op PR
- `flutter analyze` has zero issues on the empty scaffold
- App boots on Android emulator, iOS simulator, and Chrome

#### F1 — Design system + ornament widgets (1.5 weeks)

**Goal:** every visual primitive needed to recreate the prototype lives in one tested place. After F1, screen modules consume widgets and tokens — they don't recreate them.

**Deliverables:**
- `lib/theme/app_colors.dart` — all hex tokens from §4.1 as `static const Color`
- `lib/theme/app_typography.dart` — `TextStyle` constants for each `font-*` token in §4.2 (uses `google_fonts` package or bundled assets)
- `lib/theme/app_spacing.dart`, `app_radii.dart` — sizing constants
- `lib/theme/app_theme.dart` — `ThemeData` (dark) wiring `ColorScheme` + `TextTheme` + `ThemeExtension` for non-M3 tokens (gold-highlight, maghrib-orange, live-red, etc.)
- `lib/theme/ornaments/`:
  - `arabesque_painter.dart` — repeating 8-pointed star background, gold @ 8% opacity
  - `octagonal_star_clipper.dart` — clip path + outlined variant
  - `gold_orb.dart` — radial-gradient orb with animated pulse and outer rings
  - `audio_waveform.dart` — animated bar visualizer (~44 bars, 1.5px wide, alternating heights)
  - `live_pill.dart` — pulsing red dot + optional latency badge ("LIVE · 428 ms")
  - `glass_card.dart` — backdrop-blur card primitive
  - `hero_gradient.dart` — `purple-deep` → `bg-deep-night` gradient `BoxDecoration`
- `lib/theme/showcase_screen.dart` — debug-only route that displays every ornament + every color/typography token (for visual QA against prototype)
- Bundled fonts in `pubspec.yaml`: Instrument Sans (700), DM Sans (400/500/700), Material Symbols Outlined (variable) — OR via `google_fonts` with cache prefetching

**Acceptance:**
- Showcase screen renders all ornaments correctly on Android / iOS / Chrome
- Hot-reload swap of any token in `app_colors.dart` propagates across the showcase
- Golden tests for each ornament widget pass
- Visual QA: side-by-side comparison of showcase vs prototype motifs — no perceivable differences

#### F2 — Mock data layer + Riverpod state management (1 week)

**Goal:** repository pattern so backend can be swapped in during Phase B without touching any screen code. After F2, the rest of Phase F never touches a mock implementation directly — only the repository interface.

**Deliverables:**
- Repository interfaces in `lib/data/repositories/`:
  - `auth_repository.dart` — `signUp`, `signIn`, `signInWithGoogle`, `signInWithApple`, `signOut`, `currentUser` (stream), `biometricUnlock`, `requestOtp`, `verifyOtp`
  - `user_repository.dart` — `getProfile`, `updateProfile`, `getPreferences`, `setPreference`
  - `masjid_repository.dart` — `getNearby(coord, radiusKm)`, `search(query)`, `getById(id)`, `register(payload)`, `favourite(id)`, `unfavourite(id)`
  - `stream_repository.dart` — `getActiveStreams`, `getStreamById`, `startBroadcast`, `joinBroadcast`, `endBroadcast`, `getStreamHealth`, `getReplay(streamId)`, `scheduleBroadcast`
  - `verification_repository.dart` — `getVerificationStatus(masjidId)`, `getVerificationHistory(masjidId)`, `submitQrScan(token, coord)`, `validateGeofence(masjidId, coord)`, `generateQrToken(masjidId)`
  - `prayer_repository.dart` — `getDailySchedule(coord, method)`, `getCalculationMethod`, `setCalculationMethod`
  - `notification_repository.dart` — `getInbox`, `markRead(id)`, `subscribeToMasjid(id)`, `getSubscriptions`
  - `tv_pairing_repository.dart` — `requestPairingCode`, `confirmPairing(code)`
- Fake implementations in `lib/data/mocks/` returning hard-coded fixtures from `lib/data/fixtures/`:
  - `users.json` — sample listener + sample Muadhin + sample admin
  - `masjids.json` — 50 Masjids worldwide with realistic coordinates (Mecca, Medina, London, Birmingham, Jakarta, Istanbul, etc.)
  - `streams.json` — 3 active streams + 5 past streams (with replay URLs pointing to local sample mp3s)
  - `verification.json` — Layer 1-3 records + Layer 4 partial (19/20 scans)
  - `audit_log.json` — 30 sample audit events
- Riverpod providers exposing each repository — `final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository())` — easily overridable in tests and in Phase B
- State classes via `freezed`: `AuthState`, `UserState`, `MasjidListState`, `StreamState`, `VerificationState`, `PrayerScheduleState`, etc.
- `MockDelay` helper that simulates realistic API latency (200-800ms) so UI loading states feel real; `--dart-define MOCK_DELAY=0` skips it for fast dev
- Failure injection: each mock has a `--dart-define MOCK_FAIL=<repo>:<method>` knob to test error states without writing per-screen test code

**Acceptance:**
- Every screen in F3-F6 can be powered by mocks alone, with realistic loading + error states
- Repository interfaces are the only contract — `lib/features/**/screens/` never imports anything from `lib/data/mocks/`
- 80%+ test coverage on repository state notifiers and `freezed` state classes

#### F3 — Onboarding & Auth screens (1.5 weeks)

**Goal:** all 10 Onboarding & Auth prototype screens running, with the mock auth flow producing a "signed-in" state.

**Screens (10):** `splash-screen`, `onboarding-welcome`, `onboarding-proximity`, `onboarding-verified`, `permissions-bundle`, `language-region-selection`, `sign-in-centered-variant`, `create-account-step-1` (email/phone), `create-account-step-2` (OTP), `create-account-step-3` (profile)

**Deliverables:**
- One file per screen under `lib/features/onboarding/screens/` and `lib/features/auth/screens/`
- Onboarding flow controller (Riverpod `Notifier`) walks user through welcome → proximity → verified → permissions; persists "onboarded" flag to `SharedPreferences`
- Auth flow controller branches between sign-in and create-account
- Permissions: use `permission_handler` to actually request notifications, location, microphone permissions — match the prototype's deny states
- Language picker: writes choice to `SharedPreferences`, updates app locale on the fly
- OTP entry: 6-digit segmented input widget; mock auto-fills the correct OTP after 1.5s for happy path
- Splash screen: native splash via `flutter_native_splash` + the in-app splash widget for branded loading

**Acceptance:**
- Fresh install → onboarding flow → mock sign-in or mock create-account → home (F4 placeholder)
- Onboarded flag persists across app restart
- Locale switch (EN ↔ AR) flips RTL correctly across all 10 screens
- Permissions actually request OS-level permissions; denial paths render the prototype's error states
- Side-by-side visual parity against prototype on iPhone 13 simulator + Pixel 6 emulator

#### F4 — Listener screens (2.5 weeks)

**Goal:** all 14 Listener prototype screens, including the live player with mock audio and the Smart TV pairing flow.

**Screens (14):** `home-prayer-widget`, `home-listener`, `nearby-masjids`, `search-results-nearby`, `masjid-detail`, `live-player-masjid-al-abrar`, `replay-player-masjid-al-abrar`, `stream-ended-state`, `stream-reconnecting-state`, `prayer-schedule-birmingham`, `inbox`, `profile`, `settings`, `smart-tv-pairing`

**Deliverables:**
- One file per screen under `lib/features/listener/screens/`
- Bottom navigation (home / search / inbox / profile) — visible only on the screens that show it in the prototype
- Mock audio playback: the `audio_waveform` widget animates from a synthetic amplitude curve; a "mock playing" state controls the visualizer
- Reconnect / ended states reachable via dev menu (no real network errors yet)
- Smart TV pairing screen renders a QR code from a mock pairing service that returns a fake 6-digit code after 1s
- Settings page wires all real local preferences (theme, language, calculation method, notification toggles) — even without backend, they persist via `SharedPreferences`
- Profile page renders the mock user fixture from F2
- Replay player has a scrubber + play/pause controlling the orb state

**Acceptance:**
- All 14 screens reachable through a real navigation flow (not just dev menu)
- Live player: orb pulses, waveform animates, latency badge updates with mock values
- Pixel parity against prototype: side-by-side spot-check of all 14 screens with owner at week's end

#### F5 — Broadcaster screens (1.5 weeks)

**Goal:** all 7 Broadcaster prototype screens, with a mock broadcast lifecycle that runs end-to-end.

**Screens (7):** `home-prayer-widget-muadhin`, `masjid-dashboard-muadhin`, `go-live-pre-broadcast-check`, `live-broadcast-masjid-al-abrar`, `schedule-broadcast-muadhin`, `broadcast-summary-masjid-al-abrar`, `audit-log-muadhin`

**Deliverables:**
- One file per screen under `lib/features/broadcaster/screens/`
- Mock broadcast lifecycle: tap "Start broadcast" → 3-2-1 countdown → simulated 5-minute broadcast → "End" button → mock summary screen with fake listener count, duration, peak-listeners chart
- Pre-broadcast checklist verifies mic permission (real), network reachability (`connectivity_plus`), and a mocked "Layer 4 verified" state from the verification repo
- Schedule broadcast: date+time picker writes to mock state; entry appears on the dashboard's "Upcoming" list
- Audit log displays mock entries from F2 fixtures

**Acceptance:**
- Full mock broadcast flow runs end-to-end without any backend
- Schedule entry appears on dashboard after creation; can be edited and cancelled
- All 7 screens pixel-match prototype

#### F6 — Verification screens (1 week)

**Goal:** all 5 Verification prototype screens, with mock QR-scan + geofence flow that exercises both success and failure UIs.

**Screens (5):** `qr-scan-masjid-al-abrar`, `qr-scan-success`, `qr-scan-error-outside-radius`, `verification-status-masjid-al-abrar`, `verification-history`

**Deliverables:**
- One file per screen under `lib/features/verification/screens/`
- QR scanner uses `mobile_scanner` package; the mock decoder accepts any QR but routes to success/error based on a dev toggle (real QR validation lands in B3)
- Geofence simulation: dev menu toggle switches between "inside radius" and "outside radius" to render the error variant
- Verification status screen shows the 4-layer chain with progress bars (mock: layers 1-3 complete, layer 4 at 19/20)
- Verification history is a chronological list of mock events

**Acceptance:**
- Camera permission requested correctly; viewfinder + scanning animation render on a real device
- Both success and error states reachable through the dev toggle
- Verification status page renders the 4-layer chain visually identical to prototype

#### F7 — Frontend QA + design review (0.5 weeks)

**Goal:** Phase F ships with pixel parity against the prototype and owner sign-off.

**Deliverables:**
- Side-by-side comparison of every one of the 36 screens against the prototype HTML — bug list filed for any mismatches
- All Sev-1/Sev-2 visual bugs from the review are fixed
- Widget tests covering critical state transitions (sign-in, broadcast start/end, QR scan, language switch)
- Tagged demo build distributed via Firebase App Distribution or TestFlight for owner review
- Owner sign-off before Phase B begins

**Acceptance:**
- Owner reviews all 36 screens on a real device and approves visual fidelity
- All Sev-1/Sev-2 visual bugs from the review are fixed
- Demo build is reproducible from the tagged commit

---

### Phase B — Backend integration

Phase B replaces the mock repository implementations from F2 with real Firebase + AWS Chime + Cloud Functions backed implementations. **Screens themselves do not change** — only repository implementations swap.

#### B0 — Firebase project setup (0.5 weeks)

- Create `muslim-guider-pro-dev`, `-staging`, `-prod` Firebase projects
- Enable Auth (Email/Password, Google, Apple), Firestore, Cloud Functions, Cloud Messaging, Storage, Analytics, Crashlytics
- AWS account provisioned for Chime SDK; IAM service account with Chime + S3 (recording) permissions
- Flutter app reads `firebase_options.dart` per env via `--dart-define`
- `flutterfire configure` wired up; no manual Firebase Console edits

#### B1 — Auth + user profile (1 week)

- Swap `MockAuthRepository` → `FirebaseAuthRepository` and `MockUserRepository` → `FirestoreUserRepository`
- Implement `/users/{userId}` schema per §7
- Cloud Function for account deletion (soft + 30-day hard delete per GDPR)
- Email verification flow
- Custom claims: `platformRole`, `masjidRoles[]` set via admin Cloud Function

#### B2 — Masjid registry + proximity (1 week)

- Implement `/masjids/{masjidId}` schema per §7
- Geohash indexing via `geoflutterfire_plus`; replace `MockMasjidRepository` → `FirestoreMasjidRepository`
- Seed script: 50 sample Masjids in dev environment
- Real Masjid registration flow writes records with `status: PENDING_VERIFICATION`

#### B3 — Verification (full 4-Layer) backend (1.5 weeks)

- All four verification layers backed by Cloud Functions:
  - L1: triggered by Masjid registration
  - L2: admin endpoint (`certifyMasjid`) — sets status to `PENDING_MUADHIN_AUTH`
  - L3: admin endpoint (`nominateMuadhin`) — sets Muadhin status to `PENDING_COMMUNITY_VERIFICATION`
  - L4: `submitQrScan` Cloud Function with geofence validation (distance from Masjid coords) + token validation + unique-user dedup
- `/qrTokens` collection with TTL cleanup via scheduled Cloud Function
- `/verificationScans` collection with audit fields (`userId`, `coordinates`, `geohash`, `deviceFingerprint`, `at`)
- 20-scan threshold is a config doc in `/platformConfig` — adjustable without redeploy
- All state transitions write `/auditLog` entries

#### B4 — Streaming (AWS Chime + native platform channels) (2.5 weeks)

- Per §3 architecture diagram: Cloud Functions wrap AWS Chime API; Android Kotlin module + iOS Swift module wrap the native Chime SDKs; Flutter facade unifies them
- Cloud Functions: `createBroadcast(masjidId)`, `joinBroadcast(broadcastId)`, `endBroadcast(broadcastId)` — return signed join tokens
- `/streams/{streamId}` Firestore doc per §7 schema
- Android: `android/app/src/main/kotlin/.../StreamingPlugin.kt` wrapping `amazon-chime-sdk-android`
- iOS: `ios/Runner/StreamingPlugin.swift` wrapping `AmazonChimeSDK` pod
- Flutter facade `lib/data/streaming/chime_streaming_repository.dart` implements `stream_repository.dart`
- Listener UI swaps mock waveform for real Chime audio level (where SDK exposes amplitude; otherwise keep synthetic)
- Background audio via `audio_service` package
- Reconnect logic + `stream-reconnecting-state` screen become real

#### B5 — Prayer times + notifications (1 week)

- On-device `adhan` package calculation (no backend math needed)
- Cloud Function scheduled per region to dispatch prayer-time FCM topics
- `firebase_messaging` integration: foreground + background handlers, deep links
- Inbox reads real FCM notification history from `/notifications/{userId}/items`
- Hijri date via `hijri` package

#### B6 — Auxiliary backends (1 week)

- **Recording:** Chime SDK recording config → S3 bucket → `replayUrl` written to `/streams` doc; replay player streams from S3
- **Scheduled broadcasts:** Cloud Scheduler triggers Cloud Function at scheduled time → creates pending stream + notifies Muadhin
- **Smart TV pairing:** Cloud Function issues 6-digit pairing code with 5-minute TTL stored in `/tvPairings`; QR code on mobile encodes a pairing URL. The actual TV apps are Phase 1.x, but the API contract is in place

#### B7 — Backend integration testing (0.5 weeks)

- All repository swaps complete; no mock implementation referenced outside `test/`
- `firebase emulators:exec` integration tests for each repository
- Smoke test: full user journey from sign-up → Masjid registration → verification → broadcast → listen, end-to-end

---

### Phase L — Launch

#### L0 — Polish, analytics, monitoring (1 week)

- Firebase Analytics events on sign-up, Masjid registered, broadcast started/joined/ended, QR scan submitted, verification complete
- Crashlytics integrated + force-crash test
- Sentry (optional) for backend errors
- Manual QA pass against an exit-criteria checklist (one row per acceptance criterion in F0-F7 + B0-B7)
- Firestore Security Rules audit + `firebase emulators:exec` rule tests
- Cost monitoring + budget alerts at 50% / 80% / 100%

#### L1 — Store submissions + beta + bug bash (1 week)

- Apple App Store listing: screenshots, description, privacy nutrition label, age rating
- Google Play listing: screenshots, description, data safety form, content rating
- TestFlight + Google Play internal track distribution to ~20 beta testers
- 7-day pilot with 5 Masjids
- Bug bash + fix sprint
- Submit for review

---

## 7. Data model (Firestore schema)

All fields use camelCase. All timestamp fields are Firestore `Timestamp`. All IDs are document IDs unless suffixed `Id` (FK).

### 7.1 `/users/{userId}`

```ts
{
  // Core identity
  userId: string                      // mirrors doc ID
  email: string                       // also in Auth; mirrored for query convenience
  emailVerified: boolean
  phone: string | null                // E.164
  displayName: string
  profileImageUrl: string | null

  // Auth metadata
  authProviders: string[]             // ['password', 'google.com', 'apple.com']
  biometricEnabled: boolean
  lastLoginAt: Timestamp

  // Platform role
  platformRole: 'SUPER_ADMIN' | 'PLATFORM_ADMIN' | 'USER'
  masjidRoles: Array<{
    masjidId: string
    role: 'BOARD' | 'IMAM' | 'MUADHIN' | 'MEMBER'
    grantedBy: string
    grantedAt: Timestamp
    revokedAt: Timestamp | null
  }>

  // Geographic
  homeCoordinates: GeoPoint | null
  homeGeohash: string | null          // for proximity-relative queries on user too
  timezone: string                    // IANA: 'Asia/Riyadh'
  countryCode: string                 // ISO 3166-1 alpha-2
  preferredMasjidId: string | null
  preferredCalculationMethod:
    'UMM_AL_QURA' | 'ISNA' | 'MWL' | 'EGYPTIAN' | 'KARACHI' | 'MOONSIGHTING'

  // Verification state (Phase 1)
  verificationLevel: 0 | 1 | 2 | 3 | 4
  verificationLog: Array<{ event: string; at: Timestamp; by: string }>

  // Phase 2 reserved (Tazkiya)
  tazkiyaScore: number | null
  trustTier: 'BRONZE' | 'SILVER' | 'GOLD' | null

  // Phase 3 reserved (AnsApp)
  familyTreeId: string | null
  waliId: string | null
  nasabVerified: boolean

  // Phase 4 reserved (LocalMotion)
  communityMemberships: string[]      // masjidIds
  votingPower: number | null

  // Phase 7 reserved (Finance)
  walletAddress: string | null
  proofOfContributionScore: number | null

  // Consent
  gdprConsent: boolean
  gdprConsentAt: Timestamp | null
  dataProcessingConsent: boolean
  locationConsent: 'NEVER' | 'WHILE_IN_USE' | 'ALWAYS'
  shareToPhases: string[]             // ['athan'] for v1; later ['athan','tazkiya','ansapp',...]

  // Metadata
  createdAt: Timestamp
  updatedAt: Timestamp
  accountStatus: 'ACTIVE' | 'SUSPENDED' | 'DELETED'
  deletedAt: Timestamp | null
}
```

### 7.2 `/masjids/{masjidId}`

```ts
{
  masjidId: string
  name: string
  description: string
  photoUrl: string | null
  coordinates: GeoPoint
  geohash: string                     // for proximity queries
  address: { line1, line2, city, state, country, postalCode }
  countryCode: string                 // ISO 3166-1 alpha-2
  timezone: string                    // IANA

  status: 'PENDING_VERIFICATION' | 'ACTIVE' | 'SUSPENDED' | 'REJECTED'
  verificationLevel: 1 | 2 | 3 | 4    // current chain depth reached
  registeredBy: string                // userId
  approvedBy: string | null           // admin userId
  approvedAt: Timestamp | null

  // Prayer schedule (overrides on-device calculation if set)
  customSchedule: {
    fajr: string | null               // HH:mm local
    dhuhr: string | null
    asr: string | null
    maghrib: string | null
    isha: string | null
    jumuah: string | null             // HH:mm Friday only
  } | null

  // Broadcasting
  isBroadcasting: boolean             // denormalised for cheap "live" indicator
  currentStreamId: string | null
  authorisedMuadhins: string[]        // userIds with broadcast rights

  createdAt: Timestamp
  updatedAt: Timestamp
}
```

### 7.3 `/streams/{streamId}`

```ts
{
  streamId: string
  masjidId: string
  muadhinId: string
  chimeMeetingId: string              // AWS Chime meeting handle
  chimeRegion: string                 // e.g., 'us-east-1'

  status: 'STARTING' | 'LIVE' | 'ENDED' | 'FAILED'
  startedAt: Timestamp
  endedAt: Timestamp | null

  listenerCountPeak: number
  listenerCountCurrent: number        // updated by client heartbeat

  endReason: 'NORMAL' | 'NETWORK' | 'KILLED_BY_ADMIN' | 'ERROR' | null
}
```

### 7.4 Other collections (created in B3 / B5 / B6)

- `/auditLog/{eventId}` — append-only; security rules forbid update/delete
- `/qrTokens/{tokenId}` — created collection, used in Phase 1.x for Layer 4
- `/verificationScans/{scanId}` — same — reserved
- `/prayerTimes/{cacheKey}` — optional Firestore cache for offline-first delivery
- `/notifications/{notificationId}` — sent-notification history per user

---

## 8. Security & privacy

| Area | Approach | Notes vs RFQ |
|---|---|---|
| Auth tokens | Firebase ID tokens (RS256 JWTs, 1-hour TTL, auto-refresh by SDK) | Matches SEC-001 protocol requirement; TTL differs (RFQ wanted 15min — Firebase is 1h, acceptable for v1) |
| MFA | Biometric (`local_auth`) as primary; SMS OTP via Firebase Auth as fallback | RFQ wanted TOTP; we'll add TOTP in v2 if regulatory pressure requires |
| Data at rest | Firestore default AES-256 encryption (Google-managed keys) | RFQ specifies AWS KMS; deviation acceptable while on Firebase |
| Data in transit | TLS 1.2+ enforced by Firebase + AWS Chime | Matches SEC-008 |
| RBAC | Firestore Security Rules + custom claims (`role`, `masjidRoles[]`) | Matches SEC-009 role hierarchy |
| Audit log | `/auditLog` collection with security rules: create only, no update/delete | Matches SEC-010 intent |
| Rate limiting | Cloud Functions: per-IP + per-uid via `@google-cloud/api-gateway` quotas or in-function token-bucket | Matches SEC-006 |
| Penetration test | Deferred to pre-launch hardening (post-v1 beta) | Defers SEC-011; tracked in §11 |
| GDPR | Consent fields in user doc; account deletion endpoint; data export endpoint | Matches Appendix A compliance row |

**Firestore Security Rules (sketch — to be hardened in B1):**
```
match /users/{userId} {
  allow read: if request.auth.uid == userId
              || isAdmin(request.auth.uid);
  allow create: if request.auth.uid == userId;
  allow update: if request.auth.uid == userId
                && !affectsRestrictedFields(request.resource, resource);
  allow delete: if false;  // soft-delete only, via Cloud Function
}
match /auditLog/{eventId} {
  allow create: if isAuthed();
  allow read: if isAdmin(request.auth.uid);
  allow update, delete: if false;  // immutable
}
match /masjids/{masjidId} {
  allow read: if true;  // public
  allow create: if isAuthed();
  allow update: if isMasjidBoard(masjidId, request.auth.uid)
                || isAdmin(request.auth.uid);
  allow delete: if false;
}
```

---

## 9. RFQ requirement compliance map

A pragmatic mapping of every RFQ MUST HAVE to its v1 status. Anything labelled **DEFER** has an owner-acknowledged plan to address later.

| RFQ ID | Requirement | v1 Status | Notes |
|---|---|---|---|
| **Streaming** | | | |
| STR-001 | <500ms latency globally | **PARTIAL** | Target <1.5s in v1 single-region; <500ms global requires multi-region Chime + tuning — Phase 1.x |
| STR-002 | WebRTC mandatory | **MET** | AWS Chime is WebRTC under the hood |
| STR-003 | 10,000+ concurrent | **DEFER** | Chime scales architecturally; 10k load test is pre-launch hardening |
| STR-004 | Adaptive bitrate | **MET** | Chime handles adaptive bitrate natively |
| STR-005 | Opus codec | **MET** | Chime default |
| STR-006 | Health telemetry | **PARTIAL** | Listener count + duration in v1; richer per-stream metrics (jitter, packet loss) in pre-launch hardening |
| STR-007 | Auto-reconnect | **MET** | Chime SDK reconnect + Dart-side retry |
| STR-008 | CDN edge nodes | **MET** | Chime is multi-region; we'll start in one region (US-East) |
| STR-009 | TURN/STUN | **MET** | Chime handles NAT traversal |
| STR-010 | Stream recording | **MET** | Chime recording → S3 → replay player (B6) |
| **Android** | | | |
| AND-001 | Kotlin 100% | **DEVIATE** | Flutter (Dart). Owner override D2. |
| AND-002 | MVVM + Repository | **DEVIATE** | Riverpod + Repository in Dart equivalent |
| AND-003 | Min SDK 26 | **MET** | Flutter defaults; pin in `build.gradle` |
| AND-004 | Google WebRTC SDK | **DEVIATE** | Via AWS Chime SDK platform channels |
| AND-005 | MediaSession + bg audio | **MET** | `audio_service` package wraps MediaSession |
| AND-006 | Background location | **MET** | `geolocator` package |
| AND-007 | BiometricPrompt | **MET** | `local_auth` package |
| AND-008 | QR code scanning | **MET** | `mobile_scanner` package (F6 UI + B3 backend) |
| AND-009 | FCM push | **MET** | `firebase_messaging` |
| AND-010 | Offline support | **MET** | Firestore offline cache + cached prayer times |
| AND-011 | Hilt DI | **DEVIATE** | Riverpod for DI in Flutter |
| AND-012 | Room DB | **DEVIATE** | Firestore offline cache covers v1; `drift` if needed later |
| AND-013 | 80% test coverage | **TARGET** | Coverage gate in CI |
| **iOS** | | | |
| IOS-001 | Swift 100% | **DEVIATE** | Owner override D2. Streaming module is native Swift. |
| IOS-002 | MVVM-C | **DEVIATE** | Riverpod + go_router routing equivalent |
| IOS-003 | iOS 15+ | **MET** | Set in Podfile |
| IOS-004 | WebRTC SDK + AVAudioSession | **MET via native** | Chime SDK iOS wraps AVAudioSession |
| IOS-005 | Background audio | **MET** | `audio_service` |
| IOS-006 | Core Location bg | **MET** | `geolocator` (significant change API) |
| IOS-007 | LocalAuthentication | **MET** | `local_auth` |
| IOS-008 | QR scanning | **MET** | Same as AND-008 |
| IOS-009 | APNs critical alerts | **PARTIAL** | Standard APNs in v1; critical-alerts entitlement applied for separately |
| IOS-010 | Core Data | **DEVIATE** | Firestore offline cache |
| IOS-012 | XCTest + XCUITest 80% | **TARGET** | Flutter test coverage in CI |
| **Smart TV** | | | |
| §3.3 | Masjid + Home Mode (TV apps) | **PARTIAL** | Mobile-side pairing UI ships in v1 (F4); actual TV apps deferred to Phase 1.x per D3 |
| **Proximity** | | | |
| GEO-001 | Bg geolocation | **MET** | `geolocator` |
| GEO-002 | Proximity scoring | **PARTIAL** | Distance-only in v1; weighted scoring with trust score requires Phase 2 Tazkiya |
| GEO-003 | Auto-routing | **MET** | Default to nearest broadcasting Masjid |
| GEO-004 | PostGIS spatial indexing <100ms | **PARTIAL** | Firestore + geohash; migration to PostGIS in Phase 2 |
| GEO-005 | Geofencing | **MET** | Used in Layer 4 verification (B3 enforces geofence on QR scan) |
| GEO-006 | Privacy controls | **MET** | Granular consent on first run + settings |
| GEO-007 | On-device prayer time | **MET** | `adhan` package |
| **Security** | | | |
| SEC-001 | JWT RS256, 15min/7d | **PARTIAL** | Firebase ID tokens (RS256, 1h/refresh) |
| SEC-002 | Biometric 2nd factor | **MET** | `local_auth` |
| SEC-003 | OAuth 2.0 + OIDC IdP | **DEFER** | Firebase Auth covers Phase 1; Keycloak migration in Phase 2 |
| SEC-004 | TOTP MFA | **DEFER** | Biometric covers MFA for v1; TOTP Phase 1.x if regulatory pressure |
| SEC-005 | Session mgmt + geo-anomaly | **PARTIAL** | Firebase concurrent sessions; geo-anomaly detection in pre-launch hardening |
| SEC-006 | TLS 1.3 + CORS + rate limit | **PARTIAL** | TLS 1.2+ + CORS; rate limit in Cloud Functions |
| SEC-007 | AES-256 + KMS | **PARTIAL** | Firestore default encryption; KMS deferred |
| SEC-008 | TLS 1.3 in transit | **MET** | Firebase + Chime enforce TLS |
| SEC-009 | RBAC hierarchy | **MET** | Firebase custom claims |
| SEC-010 | Immutable audit log | **MET** | `/auditLog` with rules |
| SEC-011 | Pen test | **DEFER** | Pre-launch hardening |
| **SSO Hub** | | | |
| SSO-001..010 | Full OIDC IdP | **DEFER** | Firebase Auth covers v1; Keycloak migration when Phase 2 starts |
| **Verification** | | | |
| §4.1 Layer 1–3 | Multi-actor approval | **MET** | Full Imam-driven flow in B3 (Imam role can certify Masjid + nominate Muadhin) |
| §4.1 Layer 4 | 20 QR scans + geofence | **MET** | Full flow: QR scan UI (F6) + geofence-validating Cloud Function (B3) + configurable threshold |

**Bottom line:** Under decisions D2 (Flutter) and D8 (all 36 screens), the v1 plan **meets or partially meets every RFQ MUST HAVE** except infrastructure-scale items (10k load test, multi-region <500ms latency, third-party pen test) that are pre-launch hardening or Phase 1.x. Language-level MUST HAVEs (AND-001, IOS-001, etc.) are intentional deviations under owner authority. **No MUST HAVE is dropped from v1.**

---

## 10. Forward compatibility (the 7-pillar promise)

Phase 1 must not box Phases 2–7 into a corner. Three structural commitments make later phases possible without re-architecture:

1. **User schema reserves Phase 2–7 fields up front.** Every user document has `tazkiyaScore`, `familyTreeId`, `walletAddress`, etc. as nullable fields from day 1. When Phase 2 starts, we populate; we don't migrate.

2. **Firestore is acknowledged as transitional.** The plan is to migrate to Postgres + PostGIS (and optionally Neo4j or `pg_graphql` for AnsApp) **when Phase 2 onset triggers it**. We will write a migration script in B0 stub form and exercise it in CI at low fidelity, so we are not surprised when we run it for real.

3. **Auth is portable.** Firebase Auth issues standard OIDC ID tokens. When Keycloak replaces it, the user's `userId` remains stable (Firebase UID becomes the legacy ID, migration keeps the mapping). Apps continue to validate JWTs the same way.

**Triggers that force the Firebase → Postgres + Keycloak migration:**
- Active users exceeds ~100k (Firestore costs start to outpace Postgres)
- Phase 2 (Tazkiya) requires aggregate analytics queries Firestore can't do efficiently
- Phase 3 (AnsApp) requires graph traversal queries
- Any one of these triggers a 4-6 week migration sprint owned by the platform team.

---

## 11. Known risks & mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | AWS Chime + Flutter has no first-class SDK; community wrapper is unmaintained | High | High | Build our own thin platform-channel layer over the official native SDKs (Kotlin + Swift). Isolate to one Dart module so the audio gap doesn't bleed into the rest of the app. Budget for native-mobile help during B4. |
| R2 | Firestore + geohash cannot hit RFQ GEO-004 (<100ms PostGIS-grade) at scale | Medium | Medium | Acceptable for v1 at <10k Masjids. Migration to Postgres + PostGIS is a tracked Phase 2 trigger. Document threshold (active Masjid count) where migration becomes urgent. |
| R3 | <500ms latency requirement (RFQ STR-001) not met by single-region Chime | High | Medium | Multi-region Chime deployment + edge selection is Phase 1.x. v1 target is <1.5s, which is below the perceptual threshold for live broadcasts. |
| R4 | Apple App Store rejection for "broadcasting / streaming / location" — privacy and entitlements | Medium | High | Submit early in L1; have App Privacy and entitlement justifications written. Critical-alerts entitlement applied for separately and not blocking v1. |
| R5 | Religious/cultural review (terminology, scholarly endorsement) not in plan | Medium | High | Engage a subject-matter advisor before public beta. Glossary in RFQ §11 is a baseline; product copy and verification flow need scholar review. |
| R6 | Background audio behaviour differs across Android OEMs (battery optimisation kills services) | High | Medium | `audio_service` mitigates most; document supported Android device list at beta; flag OEMs (Xiaomi, Oppo, etc.) that aggressively kill background services. |
| R7 | Cost blow-out: Firebase + AWS Chime not free at 50k+ MAU | Medium | High | Set billing alerts at 50/80/100% of monthly budget. Track per-stream cost in B4. Have a self-host LiveKit OSS or Chime negotiated-rate plan ready as a Plan B if costs spike. |
| R8 | Full 4-Layer verification requires real Imams to nominate Muadhins — if no Imams are recruited, the verification chain stalls and no Masjid can broadcast | Medium | High | Onboard 3-5 Imams pre-launch as the seed chain. Document a fallback (platform admin can act as the Imam role for the first cohort of Masjids while the Imam network grows). |

---

## 12. Quality gates

Each module ships only when these are green:

- `flutter analyze` zero issues
- `flutter test` passes with ≥70% coverage on `lib/features/{module}/` (target 80% by L1)
- Manual smoke test on one Android device + one iOS device + one web browser
- New Firestore Security Rules pass `firebase emulators:exec` rule tests
- Cloud Functions covered by unit tests against the emulator
- No new lints introduced
- All new Dart files have a one-line header comment describing the file's purpose (per project convention)
- PR template checklist completed by author and reviewer

Pre-launch (L1 gate):
- Privacy policy and Terms of Service published and linked from the app
- App Privacy / Data Safety forms completed for both stores
- Firebase Crashlytics free of unhandled fatal crashes in 7-day pilot
- All F0-F7 + B0-B7 acceptance criteria reverified after polish work
- Beta tester feedback addressed (Sev-1 + Sev-2 only — Sev-3 deferred to post-launch backlog)

---

## 13. Open questions (owner decisions needed)

These do not block writing this doc, but must be resolved before the module that depends on them starts.

1. **Religious advisor / scholarly endorsement** — who is the named subject-matter authority for the platform? Needed before public beta. *Blocks B3 acceptance.*
2. **Default launch region(s)** — start in one country (e.g., UAE, Saudi, Indonesia, Malaysia, US) for the beta? *Affects B2 Masjid seeding and B4 Chime region.*
3. **Pricing** — free-forever, freemium, or per-Masjid SaaS for the institution side? *Affects F2 schema (subscription fields) and the admin dashboard.*
4. **Beta tester pool** — where do the first 50 testers come from? *Blocks L1 launch.*
5. **App Store accounts** — Apple Developer Program + Google Play Console enrolled under what entity (individual / metahealth.us / new entity)? *Blocks L1 submission.*
6. **Live-Athan content rights** — is the Muadhin's voice content owned by the platform, the Masjid, or the Muadhin themselves? *Affects Terms of Service and ownership of any future recordings.*

---

## 14. Sequencing & calendar (~21-week build)

```
              W1  W2  W3  W4  W5  W6  W7  W8  W9  W10 W11 W12 W13 W14 W15 W16 W17 W18 W19 W20 W21
═ PHASE F ════════════════════════════════════════
F0 Found.     ##
F1 Design         ##  ##
F2 Mocks              ##
F3 Onboard            ##  ##
F4 Listener               ##  ##  ##
F5 Broadcast                      ##  ##
F6 Verify                             ##
F7 FE QA                                  ##
═ PHASE B ════════════════════════════════════════
B0 FB proj                                    ##
B1 Auth                                       ##
B2 Masjid                                         ##
B3 Verify                                             ##  ##
B4 Stream                                             ##  ##  ##
B5 Prayer                                                     ##
B6 Aux                                                            ##
B7 BE QA                                                              ##
═ PHASE L ════════════════════════════════════════
L0 Polish                                                                 ##
L1 Stores                                                                     ##
```

**Phase F (weeks 1-10):** Frontend with no backend cost. Limited parallelism — F1 + F2 can overlap; F3-F6 each owns a prototype category and can run mostly sequentially. The end of F7 is the **owner sign-off gate** before Phase B starts.

**Phase B (weeks 11-19):** Backend integration. Heavier parallelism is possible — B3, B4, B5 can run in parallel after B2 lands. B4 (Chime + platform channels) is the longest single module and the highest risk; if it slips, B6 and B7 slip with it.

**Phase L (weeks 20-21):** Polish, analytics, store submission, beta. The shortest phase but the highest-stakes — App Store rejection on submit-day pushes everything.

Buffer: this is a 21-week plan with **no slack**. Realistic expectation is **24-26 weeks** including holidays, sick days, App Store back-and-forth, and unknown unknowns. Treat the 21-week number as a north star, not a commitment.

**Why frontend-first matters for the schedule:** by week 10 you have a clickable, demo-able Flutter app showing all 36 screens. That's a tangible halfway-point artifact you can show to advisors, beta testers, or investors before any backend cost is incurred. If priorities change after F7, the Flutter codebase is reusable; only the (unbuilt) backend plan would be discarded.

---

## 15. Next steps once this doc is approved

1. Resolve open questions in §13.
2. Create one implementation-plan doc per Phase F module (F0 → F1 → ...) — short, executable, test-first. Phase B and L plans get drafted near the end of Phase F.
3. Set up Firebase projects (`muslim-guider-pro-dev`, `-staging`, `-prod`).
4. Set up AWS account for Chime SDK; provision an IAM service account for Cloud Functions.
5. Begin F0 (the Phase F foundation — no backend dependencies, no Firebase setup yet).

---

**END OF BUILD PLAN**

This document supersedes the RFQ where they conflict, by owner authority. Where this doc is silent, the RFQ applies.

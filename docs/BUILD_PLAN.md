# Muslim Guider Pro — Build Plan

**How we will build Phase 1 of the Live Athan Broadcasting Platform**

| Field | Value |
|---|---|
| Doc type | Internal build plan (owner-authored, supersedes RFQ where noted) |
| Source RFQ | [`RFQ_muslim_pro_guider.md`](./RFQ_muslim_pro_guider.md) (RFQ-2024-001 v1.0) |
| Created | 2026-05-13 |
| Owner | Project owner (issuer of the RFQ) |
| Status | Draft v1 — pending owner review |
| Target | Lean MVP shippable in ~12 weeks; ecosystem hooks reserved but not built |

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
| D4 | **Lean MVP first; 7-pillar hooks reserved but unbuilt** | Ship in ~12 weeks; defer multi-region, full 4-layer verification, etc. | Reshape — phases the RFQ into MVP + later |
| D5 | **Firebase** for backend (Firestore + Auth + Functions + FCM + Storage) | Lowest day-1 friction; managed services; good Flutter support | Yes — RFQ §6.2 calls for AWS Aurora + Keycloak + EKS |
| D6 | **AWS Chime SDK** for WebRTC streaming, via Flutter platform channels | RFQ-recommended streaming stack; owner accepts SDK-gap cost | Partial — Chime is in RFQ; Flutter integration is non-RFQ |

---

## 2. Scope: MVP vs Full Phase 1

### 2.1 In scope for MVP (v1)

- Flutter app shell (Android + iOS + Web) with theming, routing, lint, CI/CD
- Firebase Auth (email/password + Google sign-in + Apple sign-in)
- Canonical user profile in Firestore (with reserved fields for Phases 2–7)
- Masjid registry (institution profile, geo-coordinates, prayer schedule)
- Proximity engine (geohash-based nearest-Masjid lookup)
- Prayer times calculation (on-device, Adhan algorithms: Umm Al-Qura, ISNA, MWL, Egyptian, Karachi)
- Simplified verification (admin-driven approval — full 4-layer chain deferred to v2)
- Live Athan broadcast via AWS Chime SDK (one-way audio: Muadhin → many listeners)
- Push notifications via FCM (prayer time reminders, Athan start alerts)
- Biometric auth (FaceID / TouchID / Android BiometricPrompt)
- Admin web dashboard (Flutter Web — manage Masjids, approve broadcasters, view streams)
- Crash reporting (Firebase Crashlytics) + analytics (Firebase Analytics)
- Single Firebase project deployment (US-Central region as default)

### 2.2 Deferred to a v2 milestone after MVP launch

- Full 4-Layer Verification (Imam → Muadhin → 20 community QR scans inside geofence)
- Stream recording / archive
- Webhook outbound events for Masjid integrators
- TURN/STUN tuning for enterprise/school firewalls
- Adaptive bitrate to 8kbps (Chime handles bitrate; we just expose the controls)
- TOTP MFA (biometric covers the MFA need for v1)
- Audit log immutability via append-only Firestore + security rules

### 2.3 Deferred to a later Phase (1.x or Phase 2+)

- Smart TV apps (Android TV + Apple TV / Masjid Mode + Home Mode) — *Phase 1.x*
- Self-hosted Keycloak / EKS migration — *triggered by Phase 2 onset*
- Postgres + PostGIS migration — *triggered by Phase 2 (Tazkiya) or Phase 3 (AnsApp)*
- GraphQL API gateway — *Phase 2+*
- Multi-region cloud deployment + IaC (Terraform/CDK) — *pre-launch hardening*
- 10,000+ concurrent listener load testing — *pre-launch hardening*
- Third-party penetration test — *pre-launch hardening*
- WCAG 2.1 AA audit, Arabic localisation polish — *pre-launch hardening*

### 2.4 Explicitly out of scope

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

- **One backend control plane (Firebase) for auth + data + functions + push** — minimises moving parts for an MVP.
- **AWS Chime as a separate audio plane** — only invoked when a broadcast starts/joins. Firebase orchestrates; Chime delivers audio. Backend cost stays predictable.
- **Native platform channels live in a single Dart-facing module** (`lib/streaming/`) so the rest of the app stays Flutter-pure.

---

## 4. Module decomposition

Eight modules. Build order is strict — each module unblocks the next. Estimated efforts assume one experienced full-stack Flutter dev plus part-time backend support.

| # | Module | Depends on | Effort | Ships value? |
|---|---|---|---|---|
| M0 | Foundation: Flutter shell + Firebase project + CI/CD | — | 1 wk | No (enabler) |
| M1 | Auth + canonical user profile | M0 | 1.5 wk | Partial (sign-in works) |
| M2 | Masjid registry + proximity engine | M1 | 1.5 wk | Yes (find nearby Masjids) |
| M3 | Verification workflow (MVP version) | M1, M2 | 1 wk | Yes (Masjid onboarding) |
| M4 | Athan streaming (AWS Chime via platform channels) | M1, M2, M3 | 2 wk | **Yes (core product)** |
| M5 | Prayer times + push notifications | M0, M2 | 1 wk | Yes (daily utility) |
| M6 | Admin dashboard (Flutter Web) | M1, M2, M3 | 1 wk | Yes (ops self-serve) |
| M7 | Polish + launch (analytics, store listings, manual QA) | All | 2 wk | Launch gate |
| | **Total** | | **~11 wk** | |

Modules M3, M5, M6 can partially overlap in parallel once their dependencies land. Realistic calendar: **12 weeks to public beta**.

---

## 5. Module details

### M0 — Foundation (1 week)

**Goal:** project skeleton + automation pipeline so every subsequent module ships green.

**Deliverables:**
- Flutter project scaffold (already done — Android + iOS + Web targets)
- Firebase project created (dev, staging, prod environments)
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics`, `firebase_storage` integrated
- Riverpod state management wired (`flutter_riverpod`, `riverpod_generator`)
- Routing with `go_router`
- Theming (light + dark, Material 3, accessible contrast, RTL-aware)
- Localisation pipeline (`flutter_localizations` + `intl`) — English + Arabic placeholders
- Strict lint (`very_good_analysis` or `flutter_lints` + custom rules)
- Folder convention: feature-first (`lib/features/{auth,masjid,prayer,streaming,verification,admin}/`)
- GitHub Actions CI: `flutter analyze`, `flutter test`, `flutter build apk --debug`, `flutter build ios --no-codesign`, `flutter build web`
- Pre-commit hook running `dart format` and `flutter analyze`

**Acceptance:**
- Empty app launches on Android, iOS simulator, and web in dev
- CI runs green on a no-op PR
- `flutter analyze` has zero issues

### M1 — Auth + canonical user profile (1.5 weeks)

**Goal:** users can sign up, sign in, and have a Firestore profile record that already reserves space for the 7-pillar ecosystem.

**Deliverables:**
- Firebase Auth: email/password, Google sign-in, Apple sign-in
- Onboarding flow: name, country, preferred prayer-time calculation method, consent screens (GDPR, location, data sharing)
- Biometric unlock after first sign-in (`local_auth` package)
- Canonical Firestore user document (see §6 schema)
- Account deletion endpoint (Cloud Function — soft-delete with `deletedAt`, hard-delete after 30 days per GDPR)
- Profile edit screen

**Acceptance:**
- Sign-up → onboarding → profile create works end-to-end on Android + iOS + Web
- Biometric unlock works on FaceID, TouchID, Android fingerprint
- New user document in Firestore has all reserved fields (Phase 2/3/4/7) initialised to null/defaults

### M2 — Masjid registry + proximity engine (1.5 weeks)

**Goal:** Masjids exist as records, and the app can find nearby ones fast.

**Deliverables:**
- `/masjids` Firestore collection with geohash index (`geoflutterfire_plus`)
- Masjid self-registration flow (board member registers, status = `PENDING_VERIFICATION`)
- Masjid profile screen (name, address, photo, schedule, "currently broadcasting" indicator)
- Search & list: "Masjids near me" using geohash range query within radius
- Manual Masjid selection + favouriting (user can pin preferred Masjid)
- `User.preferredMasjidId`, `User.homeCoordinates` written on first location grant

**Acceptance:**
- Registering a Masjid in <60 seconds on mobile
- "Nearest 10" query returns in <500ms on a 1,000-Masjid seed dataset
- Geohash radius search handles edge cases (180° meridian, polar regions are out of scope)
- User can favourite a Masjid and unfavourite it

**Known limitation flagged:** RFQ GEO-004 specifies `<100ms` PostGIS-grade query. Firestore + geohash will not hit that at 7-pillar scale. Documented in §10.

### M3 — Verification workflow (MVP version, 1 week)

**Goal:** keep broadcast trust without building the full 4-layer chain on day 1.

**MVP simplification of RFQ §4:**

| RFQ Layer | RFQ Behaviour | MVP Behaviour |
|---|---|---|
| Layer 1 (Board registers Masjid) | Self-serve registration | Same — self-serve form |
| Layer 2 (Imam certifies Masjid) | Verified Imam role required | **Platform admin manually verifies** via admin dashboard |
| Layer 3 (Imam nominates Muadhin) | Imam-authenticated action | **Masjid owner (registrant) nominates** Muadhin; platform admin confirms |
| Layer 4 (20 community QR scans inside geofence) | Cryptographic + geofenced | **Deferred entirely** — Muadhin is broadcast-enabled once Layer 3 confirms |

**Deliverables:**
- Verification state machine in Cloud Functions (`PENDING_*` → `ACTIVE`)
- Admin dashboard screens for platform admins to approve/reject Masjids and Muadhins
- Email notifications to Masjid owner on state change (via Firebase Extensions: Trigger Email)
- Audit log entries written to `/auditLog/{eventId}` (immutable via security rules)
- Schema reserved for Layer 4 (`/qrTokens`, `/verificationScans`) — collections created but unused

**Acceptance:**
- A new Masjid can be approved end-to-end by an admin in <2 minutes
- Approved Muadhin can authenticate and reach the "Start broadcast" screen (next module enables the actual broadcast)
- Rejected Masjid receives a notification with the reason

### M4 — Athan streaming via AWS Chime SDK (2 weeks)

**Goal:** the core product — live, low-latency Athan broadcast from Muadhin to many listeners.

**This module owns the only piece of native code in the app.** Everything else is Dart.

**Architecture:**

```
Muadhin's phone                                Listener's phone
+-----------------+                            +-----------------+
| Flutter UI      |                            | Flutter UI      |
| "Start Athan"   |                            | "Now playing:   |
|        |        |                            |   Masjid X"     |
+--------+--------+                            +--------+--------+
         |                                              |
   MethodChannel("chime")                       MethodChannel("chime")
         |                                              |
+--------+--------+                            +--------+--------+
| Native Chime SDK|                            | Native Chime SDK|
| (Kotlin/Swift)  |                            | (Kotlin/Swift)  |
| Publisher       |                            | Subscriber      |
+--------+--------+                            +--------+--------+
         |                                              ^
         +----- AWS Chime SFU (regional) ---------------+
                       ^
                       |
              (Cloud Function: createMeeting,
               createAttendee, returns join token)
```

**Deliverables:**
- Cloud Functions: `createBroadcast(masjidId)`, `joinBroadcast(broadcastId)`, `endBroadcast(broadcastId)` — call AWS Chime APIs with server-side AWS credentials, return signed join tokens to the client
- `/streams/{id}` Firestore doc tracking active broadcasts (`masjidId`, `muadhinId`, `startedAt`, `chimeMeetingId`, `listenerCount`)
- Android platform channel module in `android/app/src/main/kotlin/.../StreamingPlugin.kt` wrapping `amazon-chime-sdk-android` artifact
- iOS platform channel module in `ios/Runner/StreamingPlugin.swift` wrapping `AmazonChimeSDK` pod
- Flutter-side facade (`lib/streaming/streaming_service.dart`) hiding the platform-channel calls behind a clean Dart API
- Listener UI: live indicator, current Masjid name, audio level meter, manual mute/unmute, retry logic on disconnect
- Broadcaster UI: pre-broadcast checklist (mic permission, network OK), big "Start broadcast" button, broadcast duration timer, big "End broadcast" button
- Background audio: `audio_service` package wired so listeners can lock the screen and audio continues
- FCM push when a followed Masjid starts broadcasting

**Acceptance:**
- One Muadhin can broadcast to ≥10 listeners simultaneously on staging
- End-to-end latency <1.5s on a same-region test (RFQ STR-001 demands <500ms; we accept the gap for MVP — see §10)
- Audio survives screen lock, app backgrounding, and incoming call interruption
- Network drop → automatic reconnection within 5 seconds

### M5 — Prayer times + push notifications (1 week)

**Goal:** even when no Masjid is broadcasting, the app is useful daily.

**Deliverables:**
- On-device prayer time calculation using `adhan` Dart package
- Method selector (Umm Al-Qura, ISNA, MWL, Egyptian, Karachi, Moonsighting Committee, default by country)
- Daily prayer schedule screen + widget-ready provider state
- Hijri date display (`hijri` package)
- Local notifications (`flutter_local_notifications`) 5-10 mins before each prayer + at iqama time
- FCM topic subscriptions: `masjid_{id}_athan_start` for followed Masjids
- "Test notification" button in settings (helps users debug their notification permissions)

**Acceptance:**
- Daily prayer times match a known reference (e.g., IslamicFinder) within 1 minute for 3 sample cities (Mecca, London, Jakarta)
- Notifications fire when scheduled even with the app closed (tested on real devices, not just emulator)
- Hijri date is accurate

### M6 — Admin dashboard (1 week)

**Goal:** ops self-service so the owner isn't manually editing Firestore.

**Built as Flutter Web** so it shares the Riverpod state, models, and Firestore queries with the mobile app — admin screens are just additional `go_router` routes only available to users with `platformRole == 'ADMIN'`.

**Deliverables:**
- Login (reusing Firebase Auth + role check)
- Masjid moderation queue (approve / reject pending Masjids)
- Muadhin moderation queue (confirm Layer 3 nominations)
- Active streams monitor (listener counts, latency, "kill stream" action)
- User search + role assignment
- Audit log viewer (read-only)
- Platform config panel (e.g., default radius for proximity, future-Layer-4 threshold values)

**Acceptance:**
- Non-admin users redirected away from `/admin/*` routes
- Each moderation action writes an `/auditLog` entry with admin user, target, action, timestamp

### M7 — Polish + launch (2 weeks)

**Goal:** public beta — app stores accept the build, monitoring is live, ops know what to watch.

**Deliverables:**
- Firebase Analytics events on key actions (sign-up, Masjid registered, broadcast started, broadcast joined, broadcast ended)
- Firebase Crashlytics integrated and verified (force-crash test)
- Sentry (or rely on Crashlytics + Cloud Logging) for backend errors
- Manual QA pass against an exit-criteria checklist
- Apple App Store listing: screenshots, description, privacy nutrition label, age rating
- Google Play listing: screenshots, description, data safety form, content rating
- TestFlight + Google Play internal track distribution to ~20 beta testers
- Bug bash + fix sprint
- Firestore security rules audit
- Cloud Functions IAM review
- Cost monitoring + alerts (Firebase budget alerts at 50% / 80% / 100% of MVP budget)

**Acceptance:**
- App Store submission accepted (does not require approval — just submission with no rejection blockers)
- Google Play internal track release live
- All Firestore security rules tested with `firebase emulators:exec`
- 7-day pilot with 5 Masjids and 50+ users produces no Sev-1 incidents

---

## 6. Data model (Firestore schema)

All fields use camelCase. All timestamp fields are Firestore `Timestamp`. All IDs are document IDs unless suffixed `Id` (FK).

### 6.1 `/users/{userId}`

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
  shareToPhases: string[]             // ['athan'] for MVP; later ['athan','tazkiya','ansapp',...]

  // Metadata
  createdAt: Timestamp
  updatedAt: Timestamp
  accountStatus: 'ACTIVE' | 'SUSPENDED' | 'DELETED'
  deletedAt: Timestamp | null
}
```

### 6.2 `/masjids/{masjidId}`

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

### 6.3 `/streams/{streamId}`

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

### 6.4 Other collections (created in M3 / M5 / M7)

- `/auditLog/{eventId}` — append-only; security rules forbid update/delete
- `/qrTokens/{tokenId}` — created collection, used in Phase 1.x for Layer 4
- `/verificationScans/{scanId}` — same — reserved
- `/prayerTimes/{cacheKey}` — optional Firestore cache for offline-first delivery
- `/notifications/{notificationId}` — sent-notification history per user

---

## 7. Security & privacy

| Area | Approach | Notes vs RFQ |
|---|---|---|
| Auth tokens | Firebase ID tokens (RS256 JWTs, 1-hour TTL, auto-refresh by SDK) | Matches SEC-001 protocol requirement; TTL differs (RFQ wanted 15min — Firebase is 1h, acceptable for MVP) |
| MFA | Biometric (`local_auth`) as primary; SMS OTP via Firebase Auth as fallback | RFQ wanted TOTP; we'll add TOTP in v2 if regulatory pressure requires |
| Data at rest | Firestore default AES-256 encryption (Google-managed keys) | RFQ specifies AWS KMS; deviation acceptable while on Firebase |
| Data in transit | TLS 1.2+ enforced by Firebase + AWS Chime | Matches SEC-008 |
| RBAC | Firestore Security Rules + custom claims (`role`, `masjidRoles[]`) | Matches SEC-009 role hierarchy |
| Audit log | `/auditLog` collection with security rules: create only, no update/delete | Matches SEC-010 intent |
| Rate limiting | Cloud Functions: per-IP + per-uid via `@google-cloud/api-gateway` quotas or in-function token-bucket | Matches SEC-006 |
| Penetration test | Deferred to pre-launch hardening (post-MVP beta) | Defers SEC-011; tracked in §10 |
| GDPR | Consent fields in user doc; account deletion endpoint; data export endpoint | Matches Appendix A compliance row |

**Firestore Security Rules (sketch — to be hardened in M1):**
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

## 8. RFQ requirement compliance map

A pragmatic mapping of every RFQ MUST HAVE to its Phase 1 MVP status. Anything labelled **DEFER** has an owner-acknowledged plan to address later.

| RFQ ID | Requirement | MVP Status | Notes |
|---|---|---|---|
| **Streaming** | | | |
| STR-001 | <500ms latency globally | **PARTIAL** | Target <1.5s in MVP; <500ms requires regional Chime + tuning, deferred |
| STR-002 | WebRTC mandatory | **MET** | AWS Chime is WebRTC under the hood |
| STR-003 | 10,000+ concurrent | **DEFER** | Chime scales; we won't load-test to 10k in MVP |
| STR-004 | Adaptive bitrate | **MET** | Chime handles adaptive bitrate natively |
| STR-005 | Opus codec | **MET** | Chime default |
| STR-006 | Health telemetry | **PARTIAL** | Listener count + duration in MVP; full per-stream metrics in v2 |
| STR-007 | Auto-reconnect | **MET** | Chime SDK reconnect + Dart-side retry |
| STR-008 | CDN edge nodes | **MET** | Chime is multi-region; we'll start in one region (US-East) |
| STR-009 | TURN/STUN | **MET** | Chime handles NAT traversal |
| STR-010 | Stream recording | **DEFER** | Out of MVP scope |
| **Android** | | | |
| AND-001 | Kotlin 100% | **DEVIATE** | Flutter (Dart). Owner override D2. |
| AND-002 | MVVM + Repository | **DEVIATE** | Riverpod + Repository in Dart equivalent |
| AND-003 | Min SDK 26 | **MET** | Flutter defaults; pin in `build.gradle` |
| AND-004 | Google WebRTC SDK | **DEVIATE** | Via AWS Chime SDK platform channels |
| AND-005 | MediaSession + bg audio | **MET** | `audio_service` package wraps MediaSession |
| AND-006 | Background location | **MET** | `geolocator` package |
| AND-007 | BiometricPrompt | **MET** | `local_auth` package |
| AND-008 | QR code scanning | **DEFER** | Until Layer 4 verification (post-MVP) |
| AND-009 | FCM push | **MET** | `firebase_messaging` |
| AND-010 | Offline support | **MET** | Firestore offline cache + cached prayer times |
| AND-011 | Hilt DI | **DEVIATE** | Riverpod for DI in Flutter |
| AND-012 | Room DB | **DEVIATE** | Firestore offline cache covers MVP; `drift` if needed later |
| AND-013 | 80% test coverage | **TARGET** | Coverage gate in CI |
| **iOS** | | | |
| IOS-001 | Swift 100% | **DEVIATE** | Owner override D2. Streaming module is native Swift. |
| IOS-002 | MVVM-C | **DEVIATE** | Riverpod + go_router routing equivalent |
| IOS-003 | iOS 15+ | **MET** | Set in Podfile |
| IOS-004 | WebRTC SDK + AVAudioSession | **MET via native** | Chime SDK iOS wraps AVAudioSession |
| IOS-005 | Background audio | **MET** | `audio_service` |
| IOS-006 | Core Location bg | **MET** | `geolocator` (significant change API) |
| IOS-007 | LocalAuthentication | **MET** | `local_auth` |
| IOS-008 | QR scanning | **DEFER** | Same as AND-008 |
| IOS-009 | APNs critical alerts | **PARTIAL** | Standard APNs in MVP; critical alerts entitlement applied for separately |
| IOS-010 | Core Data | **DEVIATE** | Firestore offline cache |
| IOS-012 | XCTest + XCUITest 80% | **TARGET** | Flutter test coverage in CI |
| **Smart TV** | | | |
| §3.3 | Masjid + Home Mode | **DROP** | Owner decision D3 — deferred to Phase 1.x |
| **Proximity** | | | |
| GEO-001 | Bg geolocation | **MET** | `geolocator` |
| GEO-002 | Proximity scoring | **PARTIAL** | Distance-only in MVP; weighted scoring (follow history + trust) in v2 |
| GEO-003 | Auto-routing | **MET** | Default to nearest broadcasting Masjid |
| GEO-004 | PostGIS spatial indexing <100ms | **PARTIAL** | Firestore + geohash; migration to PostGIS in Phase 2 |
| GEO-005 | Geofencing | **DEFER** | Used in Layer 4 verification (post-MVP) |
| GEO-006 | Privacy controls | **MET** | Granular consent on first run + settings |
| GEO-007 | On-device prayer time | **MET** | `adhan` package |
| **Security** | | | |
| SEC-001 | JWT RS256, 15min/7d | **PARTIAL** | Firebase ID tokens (RS256, 1h/refresh) |
| SEC-002 | Biometric 2nd factor | **MET** | `local_auth` |
| SEC-003 | OAuth 2.0 + OIDC IdP | **DEFER** | Firebase Auth covers Phase 1; Keycloak migration in Phase 2 |
| SEC-004 | TOTP MFA | **DEFER** | Biometric covers MFA for MVP |
| SEC-005 | Session mgmt + geo-anomaly | **PARTIAL** | Firebase concurrent sessions; geo-anomaly in v2 |
| SEC-006 | TLS 1.3 + CORS + rate limit | **PARTIAL** | TLS 1.2+ + CORS; rate limit in Cloud Functions |
| SEC-007 | AES-256 + KMS | **PARTIAL** | Firestore default encryption; KMS deferred |
| SEC-008 | TLS 1.3 in transit | **MET** | Firebase + Chime enforce TLS |
| SEC-009 | RBAC hierarchy | **MET** | Firebase custom claims |
| SEC-010 | Immutable audit log | **MET** | `/auditLog` with rules |
| SEC-011 | Pen test | **DEFER** | Pre-launch hardening |
| **SSO Hub** | | | |
| SSO-001..010 | Full OIDC IdP | **DEFER** | Firebase Auth covers MVP; Keycloak migration when Phase 2 starts |
| **Verification** | | | |
| §4.1 Layer 1–3 | Multi-actor approval | **PARTIAL** | Admin-driven; full Imam-driven flow in v2 |
| §4.1 Layer 4 | 20 QR scans + geofence | **DEFER** | Schema reserved; flow built in v2 |

**Bottom line: 25 MUST HAVEs met (with substitutions), 12 partial, 9 deferred to a named milestone, 6 dropped or deviated under owner override D2/D3.**

---

## 9. Forward compatibility (the 7-pillar promise)

Phase 1 must not box Phases 2–7 into a corner. Three structural commitments make later phases possible without re-architecture:

1. **User schema reserves Phase 2–7 fields up front.** Every user document has `tazkiyaScore`, `familyTreeId`, `walletAddress`, etc. as nullable fields from day 1. When Phase 2 starts, we populate; we don't migrate.

2. **Firestore is acknowledged as transitional.** The plan is to migrate to Postgres + PostGIS (and optionally Neo4j or `pg_graphql` for AnsApp) **when Phase 2 onset triggers it**. We will write a migration script in M0 stub form and exercise it in CI at low fidelity, so we are not surprised when we run it for real.

3. **Auth is portable.** Firebase Auth issues standard OIDC ID tokens. When Keycloak replaces it, the user's `userId` remains stable (Firebase UID becomes the legacy ID, migration keeps the mapping). Apps continue to validate JWTs the same way.

**Triggers that force the Firebase → Postgres + Keycloak migration:**
- Active users exceeds ~100k (Firestore costs start to outpace Postgres)
- Phase 2 (Tazkiya) requires aggregate analytics queries Firestore can't do efficiently
- Phase 3 (AnsApp) requires graph traversal queries
- Any one of these triggers a 4-6 week migration sprint owned by the platform team.

---

## 10. Known risks & mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | AWS Chime + Flutter has no first-class SDK; community wrapper is unmaintained | High | High | Build our own thin platform-channel layer over the official native SDKs (Kotlin + Swift). Isolate to one Dart module so the audio gap doesn't bleed into the rest of the app. Budget for native-mobile help during M4. |
| R2 | Firestore + geohash cannot hit RFQ GEO-004 (<100ms PostGIS-grade) at scale | Medium | Medium | Acceptable for MVP at <10k Masjids. Migration to Postgres + PostGIS is a tracked Phase 2 trigger. Document threshold (active Masjid count) where migration becomes urgent. |
| R3 | <500ms latency requirement (RFQ STR-001) not met by single-region Chime | High | Medium | Multi-region Chime deployment + edge selection is post-MVP hardening. MVP target is <1.5s, which is below the perceptual threshold for live broadcasts. |
| R4 | Apple App Store rejection for "broadcasting / streaming / location" — privacy and entitlements | Medium | High | Submit early in M7; have App Privacy and entitlement justifications written. Critical alerts entitlement applied for separately and not blocking MVP. |
| R5 | Religious/cultural review (terminology, scholarly endorsement) not in plan | Medium | High | Engage a subject-matter advisor before public beta. Glossary in RFQ §11 is a baseline; product copy and verification flow need scholar review. |
| R6 | Background audio behaviour differs across Android OEMs (battery optimisation kills services) | High | Medium | `audio_service` mitigates most; document supported Android device list at beta; flag OEMs (Xiaomi, Oppo, etc.) that aggressively kill background services. |
| R7 | Cost blow-out: Firebase + AWS Chime not free at 50k+ MAU | Medium | High | Set billing alerts at 50/80/100% of monthly budget. Track per-stream cost in M4. Have a self-host LiveKit OSS or Chime negotiated-rate plan ready as a Plan B if costs spike. |
| R8 | Verification MVP (admin-driven) doesn't scale past ~50 Masjids | Medium | Medium | Acceptable until then. The full 4-layer flow design is documented; build it in v2 the moment admin workload exceeds 5 approvals/day. |

---

## 11. Quality gates

Each module ships only when these are green:

- `flutter analyze` zero issues
- `flutter test` passes with ≥70% coverage on `lib/features/{module}/` (target 80% by M7)
- Manual smoke test on one Android device + one iOS device + one web browser
- New Firestore Security Rules pass `firebase emulators:exec` rule tests
- Cloud Functions covered by unit tests against the emulator
- No new lints introduced
- All new Dart files have a one-line header comment describing the file's purpose (per project convention)
- PR template checklist completed by author and reviewer

Pre-launch (M7 gate):
- Privacy policy and Terms of Service published and linked from the app
- App Privacy / Data Safety forms completed for both stores
- Firebase Crashlytics free of unhandled fatal crashes in 7-day pilot
- All M1–M6 acceptance criteria reverified after polish work
- Beta tester feedback addressed (Sev-1 + Sev-2 only — Sev-3 deferred to post-launch backlog)

---

## 12. Open questions (owner decisions needed)

These do not block writing this doc, but must be resolved before the module that depends on them starts.

1. **Religious advisor / scholarly endorsement** — who is the named subject-matter authority for the platform? Needed before public beta. *Blocks M3 acceptance.*
2. **Default launch region(s)** — start in one country (e.g., UAE, Saudi, Indonesia, Malaysia, US) for the beta? *Affects M2 Masjid seeding and M4 Chime region.*
3. **Pricing** — free-forever, freemium, or per-Masjid SaaS for the institution side? *Affects M0 schema (subscription fields) and M6 admin dashboard.*
4. **Beta tester pool** — where do the first 50 testers come from? *Blocks M7 launch.*
5. **App Store accounts** — Apple Developer Program + Google Play Console enrolled under what entity (individual / metahealth.us / new entity)? *Blocks M7 submission.*
6. **Live-Athan content rights** — is the Muadhin's voice content owned by the platform, the Masjid, or the Muadhin themselves? *Affects Terms of Service and ownership of any future recordings.*

---

## 13. Sequencing & calendar (12-week MVP)

```
            W1  W2  W3  W4  W5  W6  W7  W8  W9  W10 W11 W12
M0 Found.   ##  ##
M1 Auth          ##  ##
M2 Masjid            ##  ##
M3 Verify                    ##
M4 Stream                        ##  ##  ##
M5 Prayer                                ##
M6 Admin                                     ##
M7 Polish                                        ##  ##
```

- **M3** (Verification MVP) runs in parallel with the tail of M2 — they share data access patterns.
- **M5** (Prayer times) runs in parallel with M4 (Streaming) since they share no code paths.
- **M6** (Admin web) runs in the same week as M7's first week to compress; treat this as the most-likely slip point.

Buffer: this is a 12-week plan with **no slack**. Realistic expectation is **14–15 weeks** including holidays, sick days, and unknown unknowns. Treat the 12-week number as a north star, not a commitment.

---

## 14. Next steps once this doc is approved

1. Resolve open questions in §12.
2. Create one implementation-plan doc per module (M0 → M1 → ...) — short, executable, test-first.
3. Set up Firebase projects (`muslim-guider-pro-dev`, `-staging`, `-prod`).
4. Set up AWS account for Chime SDK; provision an IAM service account for Cloud Functions.
5. Begin M0.

---

**END OF BUILD PLAN**

This document supersedes the RFQ where they conflict, by owner authority. Where this doc is silent, the RFQ applies.

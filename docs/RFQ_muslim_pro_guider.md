# REQUEST FOR QUOTATION

## Live Athan Broadcasting Platform & 7-Pillar Ecosystem SSO Foundation

**Software Requirements Specification (SRS) & Vendor RFQ**

**Document Ref:** RFQ-2024-001 | **Version:** 1.0 | **Classification:** Confidential

---

## Document Control

| Field | Value |
|---|---|
| Document Title | Live Athan Broadcasting Platform & Ecosystem SSO Foundation |
| Document Type | Request for Quotation (RFQ) / Software Requirements Specification (SRS) |
| Reference Number | RFQ-2024-001 |
| Version | 1.0 – Initial Release |
| Issue Date | 2024 |
| Classification | CONFIDENTIAL – Distribution to Pre-Qualified Vendors Only |
| Response Deadline | 28 calendar days from date of issue |
| Issuing Authority | Athan Platform Initiative – Project Steering Committee |
| Primary Contact | projects@athanplatform.io |
| Phase Scope | Phase 1 of 7: Live Athan Broadcasting + Ecosystem Database & SSO Hub |

> **!** This document constitutes the authoritative technical specification for all vendor proposals. Submissions that do not address every section herein will be deemed non-compliant and disqualified from evaluation.

---

## 1. Executive Summary

The Athan Platform Initiative is seeking a highly capable, enterprise-grade software development agency to design, build, and deliver Phase 1 of a global, seven-pillar digital ecosystem purpose-built for the worldwide Muslim community. This Phase 1 engagement is not a standalone application – it is the foundational cornerstone upon which six subsequent platforms will be built.

The selected vendor will be required to architect and deliver:

- A real-time, ultra-low latency Athan (Call to Prayer) live audio broadcasting mobile application for Android and iOS.
- A Smart TV application supporting institutional (Masjid Mode) and residential (Home Mode) use cases.
- A Zero-Trust, multi-layer Masjid and broadcaster verification engine.
- A globally scalable, API-first backend database and Single Sign-On (SSO) infrastructure designed from Day 1 to serve all seven future platform phases without re-architecture.

> **▶ STRATEGIC IMPERATIVE:** The vendor must understand that the database schema, SSO architecture, and API design delivered in Phase 1 are permanent infrastructure. Shortcuts or siloed thinking will create technical debt that blocks all subsequent phases. Only vendors with proven enterprise-scale SSO and distributed systems experience should respond.

---

## 2. Project Scope & Boundaries

### 2.1 In-Scope Deliverables

The following are explicitly within the scope of this engagement:

- Native Android Application (Kotlin, MVVM, WebRTC SDK)
- Native iOS Application (Swift, MVVM, WebRTC SDK)
- Smart TV Applications (Android TV / tvOS) – Masjid Mode & Home Mode
- Real-time audio streaming backend with sub-500ms latency SLA
- Intelligent Proximity Engine for automatic nearest-Masjid routing
- 4-Layer Zero-Trust Verification System for Masjid/broadcaster onboarding
- Central SSO Hub (OAuth 2.0 / OpenID Connect compliant) serving all 7 ecosystem phases
- Canonical User Profile Database (schema-designed for all 7 pillar integrations)
- RESTful + GraphQL API Gateway with full documentation (OpenAPI 3.0)
- Admin Dashboard (Web) for platform management and monitoring
- CI/CD pipeline, staging environment, and production deployment
- Complete technical documentation, architecture diagrams, and handover package

### 2.2 Explicitly Out of Scope

The following are NOT included in this Phase 1 engagement:

- Development of Phase 2 through Phase 7 platform features
- Ongoing production cloud infrastructure costs post-launch (to be separately procured by client)
- Content moderation or live monitoring of audio streams
- Payment processing integration (reserved for Phase 7)
- Third-party mosque management software integrations

---

## 3. Detailed Technical Requirements

### 3.1 Real-Time Audio Streaming Engine

The platform's core value proposition is delivering a pristine, near-instantaneous broadcast of the Athan to listeners worldwide. The streaming architecture must meet the following non-negotiable performance requirements.

| Requirement ID | Requirement | Specification | Priority |
|---|---|---|---|
| STR-001 | End-to-End Latency | < 500ms under normal network conditions globally | MUST HAVE |
| STR-002 | Protocol | WebRTC (mandatory); fallback to HLS/DASH for legacy clients | MUST HAVE |
| STR-003 | Concurrent Listeners | 10,000+ per stream without degradation; architecture must scale to 100,000+ | MUST HAVE |
| STR-004 | Adaptive Bitrate | Dynamic bitrate adjustment: 8kbps (poor) to 128kbps (excellent) based on network conditions | MUST HAVE |
| STR-005 | Audio Codec | Opus (primary), AAC (fallback); optimised for voice frequency (human vocal range) | MUST HAVE |
| STR-006 | Stream Health Monitoring | Real-time telemetry dashboard: listener count, latency, packet loss, jitter per stream | MUST HAVE |
| STR-007 | Reconnection Logic | Automatic reconnection with exponential backoff; resume from live position (not buffered start) | MUST HAVE |
| STR-008 | CDN Integration | WebRTC SFU integration with global CDN edge nodes (minimum: N. America, Europe, Middle East, SE Asia) | MUST HAVE |
| STR-009 | TURN/STUN Infrastructure | Vendor-configured; must traverse NAT/firewall in restricted corporate/school/enterprise networks | MUST HAVE |
| STR-010 | Recording | Optional stream recording capability for Masjid archive purposes (configurable per Masjid) | SHOULD HAVE |

### 3.2 Native Mobile Application Requirements

#### 3.2.1 Android Application

| Req ID | Requirement | Specification | Priority |
|---|---|---|---|
| AND-001 | Language | Kotlin (100% – no Java allowed) | MUST HAVE |
| AND-002 | Architecture Pattern | MVVM with Repository pattern; ViewModels must be unit-tested | MUST HAVE |
| AND-003 | Min SDK | Android 8.0 (API 26) minimum; target latest stable API | MUST HAVE |
| AND-004 | WebRTC Integration | Google WebRTC SDK (libwebrtc); peer-to-peer audio stream subscription | MUST HAVE |
| AND-005 | Background Audio | MediaSession API; audio persists through screen lock, notifications | MUST HAVE |
| AND-006 | Background Location | Background geo-location for Proximity Engine (with user permission flow per Android guidelines) | MUST HAVE |
| AND-007 | Biometric Auth | BiometricPrompt API for FaceID/fingerprint authentication | MUST HAVE |
| AND-008 | QR Code Scanning | Camera-based QR scan for community verification workflow | MUST HAVE |
| AND-009 | Push Notifications | FCM integration for Athan start alerts, schedule reminders | MUST HAVE |
| AND-010 | Offline Support | Cached prayer time schedules available without connectivity | MUST HAVE |
| AND-011 | DI Framework | Hilt (mandatory) for dependency injection | MUST HAVE |
| AND-012 | Local DB | Room database for persistent caching of Masjid profiles, user preferences | MUST HAVE |
| AND-013 | Testing | Unit tests (JUnit5 + Mockito), UI tests (Espresso), min 80% code coverage | MUST HAVE |

#### 3.2.2 iOS Application

| Req ID | Requirement | Specification | Priority |
|---|---|---|---|
| IOS-001 | Language | Swift 5.9+ (100% – no Objective-C) | MUST HAVE |
| IOS-002 | Architecture Pattern | MVVM-C (Coordinator pattern) for navigation | MUST HAVE |
| IOS-003 | Min iOS Version | iOS 15.0 minimum; support latest 3 major versions | MUST HAVE |
| IOS-004 | WebRTC Integration | Google WebRTC SDK; AVAudioSession management for background playback | MUST HAVE |
| IOS-005 | Background Audio | AVAudioSession with .playback category; Now Playing info center integration | MUST HAVE |
| IOS-006 | Background Location | Core Location; significant-change monitoring to conserve battery | MUST HAVE |
| IOS-007 | Biometric Auth | LocalAuthentication framework (Face ID + Touch ID with graceful fallback) | MUST HAVE |
| IOS-008 | QR Code Scanning | AVFoundation-based native QR scanner | MUST HAVE |
| IOS-009 | Push Notifications | APNs integration; critical alerts capability for Athan notifications (requires Apple entitlement) | MUST HAVE |
| IOS-010 | Offline Support | Core Data for prayer schedule caching; graceful offline UX | MUST HAVE |
| IOS-011 | DI Framework | Swinject or equivalent; clean injectable architecture | SHOULD HAVE |
| IOS-012 | Testing | XCTest unit tests + XCUITest UI tests; min 80% coverage on ViewModels/UseCases | MUST HAVE |

### 3.3 Smart TV Application

The Smart TV application serves two distinct user contexts with fundamentally different UX requirements. Both modes must be implemented within a single application binary.

| MASJID MODE (Institutional / Digital Signage) | HOME MODE (Residential / Auto-Wake) |
|---|---|
| Primary display: real-time prayer schedule countdown | Auto-wake TV from standby at Athan time (CEC protocol) |
| Live stream integration with active broadcast indicator | Auto-play live Athan stream; auto-return to standby after broadcast |
| Community announcements ticker | Linked to user account and preferred Masjid |
| Kiosk mode: screen-always-on, no sleep, no screensaver | Family-configurable which Salah times trigger auto-wake |
| Configurable via Admin Dashboard remotely (no on-device setup per-unit) | Volume settings independent of main TV volume |
| Target: Android TV (Fire TV, Chromecast with Google TV) | Target: Android TV + Apple TV (tvOS) |

### 3.4 Intelligent Proximity Engine

The proximity engine is a core differentiator of the platform, automating the discovery and connection of listeners to their nearest live-broadcasting Masjid without manual selection.

| Req ID | Requirement | Specification | Priority |
|---|---|---|---|
| GEO-001 | Background Geolocation | Continuous location monitoring in background (battery-optimised); significant-change API on iOS | MUST HAVE |
| GEO-002 | Masjid Proximity Scoring | Algorithm must weight: straight-line distance + user follow history + Masjid trust score (Tazkiya phase) | MUST HAVE |
| GEO-003 | Auto-Routing | Automatically switch listener to nearest broadcasting Masjid stream; user can override with explicit selection | MUST HAVE |
| GEO-004 | Geo-Indexed Database | Masjid coordinates stored with PostGIS spatial indexing; nearest-N query < 100ms | MUST HAVE |
| GEO-005 | Geofencing | Optional Masjid-radius geofencing for community verification QR scan validation | MUST HAVE |
| GEO-006 | Privacy Controls | Granular user consent; option to disable background location (degrades to manual-select mode only) | MUST HAVE |
| GEO-007 | Prayer Time Calculation | On-device calculation using recognised algorithm (Umm Al-Qura, ISNA, MWL, etc.) as fallback | MUST HAVE |

---

## 4. Zero-Trust Security & Role-Based Access Control

The authenticity of the Athan broadcast is of paramount religious and community importance. No individual must be able to broadcast the Athan without completing a full, multi-party verification chain. The following architecture is non-negotiable.

> **▶ CRITICAL:** The 4-Layer verification system is the core trust mechanism of the entire ecosystem. All 7 future phases rely on the verified identity anchors established here. This is not a feature – it is infrastructure.

### 4.1 4-Layer Broadcaster Verification Workflow

| Layer | Actor | Action Required | System State After |
|---|---|---|---|
| Layer 1 | Masjid Board Member | Registers Masjid institution on platform; provides legal documentation, coordinates, founding details | Masjid status: `PENDING_IMAM_VERIFICATION` |
| Layer 2 | Imam (Verified) | Reviews Masjid registration; certifies legitimacy of institution and board members via authenticated session | Masjid status: `PENDING_MUADHIN_AUTH` |
| Layer 3 | Imam (Verified) | Nominates and authorises specific individual(s) as Muadhin with broadcasting rights | Muadhin status: `PENDING_COMMUNITY_VERIFICATION` |
| Layer 4 | Community Members (20+ unique) | 20 or more distinct community members physically present at the Masjid scan unique per-profile QR codes inside the geofenced Masjid boundary | Muadhin status: `ACTIVE – BROADCASTING UNLOCKED` |

**System Rules & Business Logic:**

- Layer 4 QR scans must be geovalidated – each scan must occur within the Masjid's registered geofenced radius (max 100m by default, configurable).
- Scans must be from unique, verified user accounts. Duplicate account scans from same device fingerprint must be rejected.
- The 20-scan threshold is a configurable platform parameter (adjustable by platform Super Admins without code deployment).
- Each layer transition must trigger real-time notifications to all relevant parties.
- Full audit log of every verification action must be immutably stored with actor identity, timestamp, GPS coordinates, and device fingerprint.

### 4.2 Authentication & Session Security

| Req ID | Requirement | Specification | Priority |
|---|---|---|---|
| SEC-001 | Primary Auth | JWT (RS256 asymmetric signing); access token TTL: 15 minutes; refresh token TTL: 7 days with rotation | MUST HAVE |
| SEC-002 | Biometric Auth | FaceID / TouchID / Android BiometricPrompt as second factor for broadcaster actions | MUST HAVE |
| SEC-003 | SSO Protocol | OAuth 2.0 + OpenID Connect (OIDC); platform acts as Identity Provider (IdP) for all 7 phases | MUST HAVE |
| SEC-004 | MFA | TOTP (RFC 6238) as fallback MFA for users without biometric capability | MUST HAVE |
| SEC-005 | Session Management | Concurrent session limits; geo-anomaly detection; automatic revocation on suspicious activity | MUST HAVE |
| SEC-006 | API Security | All API endpoints: TLS 1.3 minimum; CORS policy enforced; rate limiting (per-user + per-IP) | MUST HAVE |
| SEC-007 | Data at Rest | AES-256 encryption for PII fields in database; separate encryption key management (AWS KMS or equivalent) | MUST HAVE |
| SEC-008 | Data in Transit | TLS 1.3 enforced on all WebRTC signalling, REST, and GraphQL channels | MUST HAVE |
| SEC-009 | RBAC | Role hierarchy: Super Admin > Platform Admin > Masjid Board > Imam > Muadhin > Community Member > Guest | MUST HAVE |
| SEC-010 | Audit Logging | Immutable append-only audit log for all authentication events, role changes, and verification actions | MUST HAVE |
| SEC-011 | Penetration Testing | Vendor must include a third-party pen test report (or budget for one) prior to production launch | MUST HAVE |

---

## 5. 7-Pillar Ecosystem Database & SSO Infrastructure

> **▶** This section defines the most strategically critical deliverable of Phase 1. The canonical database schema and SSO hub designed here will serve as the permanent backbone for all 7 platform phases. The selected vendor must demonstrate deep expertise in multi-tenant, federated identity systems and future-proof database design.

### 5.1 Overview of the 7-Pillar Ecosystem

| Phase | Platform Name | Core Function | Key DB Dependencies on Phase 1 |
|---|---|---|---|
| Phase 1 | Live Athan | Real-time Athan broadcasting | User, Masjid, Role, GeoLocation, VerificationChain tables |
| Phase 2 | Tazkiya | Sharia-compliant trust & reputation scoring | `User.trustScore`, VerificationChain, CommunityAction tables |
| Phase 3 | AnsApp | Family tree & Islamic lineage mapping | `User.familyId`, RelationshipGraph (Neo4j/graph extension), Wali linkage |
| Phase 4 | LocalMotion | Community-voted local commerce directory | `User.communityId`, MasjidCommunity, VoteRecord, LocalBusiness tables |
| Phase 5 | Sunnah Marriage | Islamic marriage vetting & facilitation | User (AnsApp Wali link), `User.tazkiyaScore`, PrivacyConsent, MatchPreference |
| Phase 6 | Hiring & Services | Verified job board & tradesmen marketplace | `User.verifiedSkills`, `User.tazkiyaScore`, ServiceListing, Review tables |
| Phase 7 | Decentralised Finance | Unified digital wallet, Zakat routing, inheritance calc | `User.walletId`, TokenBalance, ContributionProof, ZakatAllocation tables |

### 5.2 Canonical User Profile Schema Requirements

The User entity must be designed as a universal identity record that can progressively be enriched as users engage with each platform phase. The following fields must be included at Phase 1 as reserved/nullable columns:

- **Core Identity:** `userId` (UUID v4), `email` (encrypted), `phone` (encrypted, E.164 format), `displayName`, `profileImageUrl`
- **Authentication:** `passwordHash`, `biometricPublicKey`, `mfaSecret`, `oauthProviders[]`, `refreshTokens[]`
- **Platform Role:** `platformRole` (enum), `masjidRoles[]` (array of `{masjidId, role, grantedBy, grantedAt}`)
- **Geographic:** `homeCoordinates`, `timezone`, `countryCode`, `preferredMasjidId`
- **Verification State:** `verificationLevel` (0-4 integer), `verificationLog` (JSONB)
- **Phase 2 Reserved:** `tazkiyaScore` (nullable decimal), `trustTier` (nullable enum), `reputationHistory[]`
- **Phase 3 Reserved:** `familyTreeId` (nullable UUID FK), `waliId` (nullable UUID FK), `nasabVerified` (boolean)
- **Phase 4 Reserved:** `communityMemberships[]`, `votingPower` (integer)
- **Phase 7 Reserved:** `walletAddress` (nullable), `tokenBalance` (nullable decimal), `proofOfContributionScore` (nullable)
- **Privacy & Consent:** `gdprConsent` (boolean), `dataProcessingConsent` (boolean), `locationConsent` (enum), `shareToPhases[]`
- **Metadata:** `createdAt`, `updatedAt`, `lastLoginAt`, `accountStatus` (enum), `deletedAt` (soft delete)

### 5.3 Graph Database Requirements (AnsApp – Phase 3 Forward-Compatibility)

The database architecture must be designed from Day 1 to support graph-based relationship queries required for Phase 3 (AnsApp – family tree and lineage mapping). Vendors must propose one of the following approaches:

- **Option A (Preferred):** PostgreSQL primary database with a dedicated Neo4j instance for relationship graphs, connected via a unified API gateway abstraction layer.
- **Option B:** PostgreSQL with `pg_graphql` extension and adjacency list / closure table relationship schema.
- **Option C:** AWS Neptune or equivalent managed graph database service with documented migration path.

The Phase 1 implementation must include the foundational `UserRelationship` table with: `userId`, `relatedUserId`, `relationshipType` (enum: PARENT, CHILD, SIBLING, SPOUSE, WALI, etc.), `verifiedBy`, `verifiedAt`, `privacyLevel`.

### 5.4 SSO Hub Architecture Requirements

| Req ID | Requirement | Specification | Priority |
|---|---|---|---|
| SSO-001 | Protocol Compliance | Full OAuth 2.0 (RFC 6749) and OpenID Connect 1.0 (OIDC) compliance | MUST HAVE |
| SSO-002 | Identity Provider Role | Platform acts as the central IdP; all 7 phase applications are OAuth clients/relying parties | MUST HAVE |
| SSO-003 | Token Scope System | Granular scopes per platform phase: `athan:read`, `tazkiya:score:read`, `ansapp:family:read`, `wallet:balance:read`, etc. | MUST HAVE |
| SSO-004 | Consent Management | Per-phase explicit user consent screen; users control which data each phase can access | MUST HAVE |
| SSO-005 | Token Introspection | RFC 7662 token introspection endpoint for backend-to-backend validation | MUST HAVE |
| SSO-006 | JWKS Endpoint | Public JWKS endpoint for downstream services to validate JWTs independently | MUST HAVE |
| SSO-007 | Multi-Tenancy | SSO hub must support future white-label deployments for regional Masjid federations | SHOULD HAVE |
| SSO-008 | Social Login | Google, Apple Sign-In as optional account creation accelerators (identity merged, not siloed) | SHOULD HAVE |
| SSO-009 | SDK Provision | Vendor must deliver client SDK (TypeScript + Kotlin + Swift) for other development teams to integrate | MUST HAVE |
| SSO-010 | Load Testing | SSO endpoints must be load-tested to 50,000 concurrent authentication requests | MUST HAVE |

---

## 6. Cloud Infrastructure Requirements

The vendor must propose a cloud infrastructure architecture optimised for the unique technical demands of this platform: global WebRTC streaming, low-latency geo-queries, and horizontally scalable SSO. The following requirements govern the proposal.

### 6.1 Infrastructure Non-Negotiables

- All infrastructure must be deployable via Infrastructure-as-Code (Terraform or AWS CDK mandatory). No manual console configuration in production.
- Multi-region deployment from Day 1 (minimum: US East, EU West, Middle East, SE Asia).
- Zero-downtime deployment capability (Blue/Green or Canary deployment strategy).
- RPO (Recovery Point Objective): < 1 hour. RTO (Recovery Time Objective): < 4 hours.
- All data storage must be GDPR-compliant with regional data residency support.
- Vendor must document the estimated monthly infrastructure cost at three traffic tiers: 1,000 MAU, 50,000 MAU, 500,000 MAU.

> **▶ NOTE ON INFRASTRUCTURE COSTS:** Ongoing cloud infrastructure costs are NOT to be bundled into the development fee. The development proposal must quote only for engineering and delivery. Infrastructure cost documentation must be provided as a separate annex to enable the client to independently provision and control production environments.

### 6.2 Recommended Stack Evaluation Criteria

Vendors are invited to propose their recommended stack. The following have been pre-evaluated for suitability:

| Layer | Recommended Options | Rationale / Notes |
|---|---|---|
| Cloud Provider | AWS (Primary) / GCP (Secondary) | AWS preferred: Chime SDK for WebRTC, Route53 geo-routing, MediaConnect. GCP alternative acceptable with full justification. |
| WebRTC Infrastructure | AWS Chime SDK / Agora / LiveKit | Vendor must justify SFU scalability to 10,000+ concurrent per stream. Self-hosted SFU (Mediasoup, Janus) requires documented ops plan. |
| API Gateway | AWS API Gateway / Kong | Must support REST + GraphQL. Kong preferred for multi-phase rate limiting and plugin ecosystem. |
| Primary Database | AWS Aurora PostgreSQL (Multi-AZ) | PostGIS extension required for geo-queries. Read replicas mandatory for production. |
| Graph Database | Amazon Neptune / Neo4j Aura | Required for Phase 3 forward-compatibility. Must be provisioned in Phase 1 even if unused by features. |
| Cache Layer | Amazon ElastiCache (Redis) | Session storage, rate limiting counters, prayer time schedule caching. |
| SSO / Auth | Keycloak (self-hosted on EKS) / Auth0 | Keycloak preferred for cost at scale and full OIDC control. Auth0 acceptable for Phase 1 if migration plan to self-hosted is documented. |
| Container Orchestration | Amazon EKS (Kubernetes) | Mandatory for Phase 1 to ensure portability across future phases. |
| CI/CD | GitHub Actions + ArgoCD | GitOps model required. All infrastructure changes via Pull Request. |
| Observability | Datadog / AWS CloudWatch + OpenTelemetry | Distributed tracing mandatory across all services from Day 1. |
| CDN / Edge | AWS CloudFront + Lambda@Edge | For global static asset delivery and edge-based geo-routing. |

---

## 7. API Design & Integration Standards

### 7.1 API Architecture

- **API-First Design:** All features must be API-first. No server-side rendered pages; mobile and TV applications consume the same APIs.
- **Dual Interface:** RESTful API (OpenAPI 3.0 specification) + GraphQL API (for complex relationship queries in later phases). Both must be fully documented.
- **Versioning:** URL-based versioning (`/v1/`, `/v2/`) mandatory from Day 1. No breaking changes without version increment.
- **Documentation:** Interactive API documentation (Swagger UI + GraphQL Playground) must be deployed in the staging environment.
- **Webhook Support:** Outbound webhook capability for Masjid-integrators to receive stream start/end events.

### 7.2 Core API Endpoints Required (Phase 1)

| Domain | Endpoint Group | Key Operations | Notes |
|---|---|---|---|
| Authentication | `/v1/auth/*` | register, login, refresh, logout, biometric-challenge, revoke | OIDC well-known endpoint required |
| User Profiles | `/v1/users/*` | CRUD profile, update-preferences, get-verification-status, consent-management | Phase-scoped data access enforced |
| Masjid | `/v1/masjids/*` | register, verify (layer 1-4), search-nearby, get-profile, update-schedule | All mutations require role check |
| Broadcasting | `/v1/streams/*` | start-broadcast, end-broadcast, get-active-streams, get-stream-token, get-health | WebRTC signalling handshake |
| Proximity | `/v1/proximity/*` | find-nearest, update-location, get-recommended | PostGIS spatial query backed |
| Verification | `/v1/verification/*` | generate-qr, submit-scan, get-verification-status, get-audit-log | QR tokens expire after 24h |
| Admin | `/v1/admin/*` | platform-stats, user-management, masjid-management, config-management | Super Admin RBAC only |
| SSO | `/.well-known/*`, `/oauth/*`, `/connect/*` | authorization, token, introspect, userinfo, jwks, revocation | Full OIDC provider endpoints |

---

## 8. Project Delivery & Timeline Requirements

### 8.1 Required Project Phases

The vendor's proposal must include a detailed timeline broken down into the following minimum phases. The client reserves the right to negotiate milestone-based payment gates at each phase boundary.

| Phase | Name | Key Deliverables | Suggested Duration |
|---|---|---|---|
| D | Discovery & Architecture | Finalized architecture diagrams, DB schema (ERD), API spec (OpenAPI 3.0), SSO architecture doc, Infrastructure-as-Code plan, Sprint plan | 2–3 weeks |
| U | UX/UI Design | Wireframes (all screens), High-fidelity Figma prototypes (Android, iOS, TV), Design system / component library, Client sign-off gate | 3–4 weeks |
| B | Backend & Infrastructure | All API endpoints live (staging), SSO hub deployed, Database provisioned, WebRTC SFU configured, 4-Layer verification system, CI/CD pipeline | 8–10 weeks |
| M | Mobile Development | Android (Kotlin) + iOS (Swift) apps feature-complete, TV applications (both modes), All API integrations, Biometric auth, Proximity engine | 8–10 weeks |
| Q | QA & Security | Full regression test suite, Penetration test (scoped), Performance/load testing (10k+ concurrent), Bug fix sprint, Staging UAT with client | 3–4 weeks |
| L | Launch Preparation | Production deployment, App Store submissions (Google Play + Apple App Store), Monitoring dashboard live, Documentation handover, 30-day hyper-care support | 2–3 weeks |

> **▶** Total estimated duration: **26–34 weeks** from contract execution to App Store launch. Vendors proposing timelines shorter than 20 weeks must provide a detailed resource plan demonstrating how quality standards will be maintained at accelerated pace.

### 8.2 Quality Gates & Acceptance Criteria

- All phase boundaries require formal client sign-off before proceeding to the next phase.
- Minimum 80% unit test code coverage on all backend services and mobile ViewModels/UseCases.
- Load test must demonstrate < 500ms stream latency at 10,000 concurrent listeners on staging environment.
- Security: No Critical or High severity findings from penetration test unresolved at launch.
- API documentation must be 100% complete (all endpoints, request/response schemas, error codes).
- Both apps must achieve App Store approval prior to final payment milestone.
- Full source code must be delivered to client's Git repository with complete commit history.

---

## 9. Vendor Proposal Requirements

Vendors must submit a comprehensive proposal addressing every point in this section. Incomplete proposals will be disqualified. All submissions must be in English in PDF or DOCX format.

### 9.1 Required Proposal Sections

- **Executive Summary** – Your understanding of the strategic vision and how your agency is uniquely positioned to deliver it.
- **Technical Architecture Proposal** – Detailed architecture diagram, technology stack justification, WebRTC SFU selection rationale, database design approach, SSO architecture.
- **Cloud Infrastructure Stack** – Chosen provider(s), services, region topology, estimated monthly costs at 3 traffic tiers, IaC tooling.
- **Security Architecture** – Zero-trust implementation approach, JWT/OIDC configuration, penetration testing plan, GDPR compliance approach.
- **7-Pillar Ecosystem Readiness** – Explicit section demonstrating how your Phase 1 design anticipates and enables Phases 2–7 without re-architecture.
- **Project Timeline** – Phase-by-phase Gantt chart or sprint plan; dedicated milestones and payment gates; risk register with mitigation.
- **Team Composition** – Named senior engineers (LinkedIn profiles required), roles, and percentage allocation to this project. Bench-swapping after project start without client approval is not permitted.
- **Relevant Portfolio** – Minimum 3 case studies of comparable complexity: real-time streaming platforms, SSO/identity systems, or enterprise mobile applications with 50,000+ MAU.
- **Fixed-Cost Quote for Phase 1** – Itemised by phase (Discovery, Design, Backend, Mobile, QA, Launch). Infrastructure costs excluded and documented separately.
- **Post-Launch Support Proposal** – Scope and cost of ongoing maintenance, bug-fix SLA, and feature development retainer options.

### 9.2 Evaluation Criteria

| Criteria | Weight | What We're Looking For | Disqualifier? |
|---|---|---|---|
| Technical Architecture Quality | 30% | Depth of understanding of WebRTC at scale, SSO design, and 7-pillar forward-compatibility | YES – generic proposals auto-disqualify |
| Relevant Experience | 25% | Proven delivery of real-time streaming OR enterprise SSO OR large-scale mobile applications | YES – no relevant portfolio = disqualified |
| Team Seniority & Continuity | 20% | Named senior engineers with verifiable experience; clear anti-bench-swap commitment | YES – anonymous teams disqualified |
| Timeline Realism | 10% | Credible, detailed breakdown; not artificially shortened to win bid | NO |
| Fixed-Cost Quote | 10% | Competitive pricing with clear itemisation; value for money vs. quality | NO |
| Post-Launch Support | 5% | Structured maintenance proposal with defined SLAs | NO |

---

## 10. Contractual & Commercial Terms

| Commercial Term | Requirement |
|---|---|
| IP Ownership | 100% of all source code, designs, databases, and intellectual property transfers to the client upon final payment. |
| Source Code | Full Git repository access granted to client from Sprint 1. No black-box delivery at any stage. |
| Key Person Clause | Named senior engineers must not be replaced without 30-day written notice and explicit client approval. |
| NDA | Mutual NDA to be executed prior to detailed technical discussions or formal proposal submission. |
| Payment Structure | 20% on contract execution / 20% architecture sign-off / 20% backend completion / 20% mobile completion / 20% on App Store launch. |
| Security Liability | Vendor liable for critical security vulnerabilities introduced by vendor code for 12 months post-launch. |
| Governing Law | To be agreed. Client preference: English law or UAE law given global platform audience. |

---

## 11. Glossary of Terms

| Term | Definition | Context |
|---|---|---|
| Athan | The Islamic call to prayer (also: Adhan). Recited five times daily to announce prayer time. | Religious / Core Feature |
| Muadhin | The individual appointed to deliver the Athan (Call to Prayer) within a Masjid. | Role / Verification |
| Imam | The religious leader of a Masjid community, responsible for validating broadcaster authenticity. | Role / Verification |
| Masjid | Islamic place of worship (mosque). The institutional broadcaster unit in this platform. | Core Entity |
| Wali | A male guardian (father, brother, or paternal relative) in Islamic jurisprudence; critical for Sunnah Marriage phase. | Phase 5 / AnsApp |
| Tazkiya | Arabic: purification / recommendation. Used here as a Sharia-compliant trust scoring system. | Phase 2 |
| Nasab | Arabic: lineage, ancestry. The verified biological/family lineage chain tracked in AnsApp. | Phase 3 |
| Zakat | Obligatory Islamic charitable giving (2.5% of qualifying wealth). One of the Five Pillars of Islam. | Phase 7 / Finance |
| SFU | Selective Forwarding Unit. A WebRTC server architecture for scalable multi-participant audio/video. | Streaming Architecture |
| OIDC | OpenID Connect. Authentication layer built on top of OAuth 2.0 used for SSO. | Security / SSO |
| JWT | JSON Web Token. A compact, self-contained token format for securely transmitting claims. | Security |
| PostGIS | A PostgreSQL extension adding geospatial data types and spatial indexing capabilities. | Database / Geo |
| CEC | Consumer Electronics Control. HDMI protocol enabling one device to control another (TV wake). | Smart TV |

---

## 12. Submission Instructions

| Field | Value |
|---|---|
| Submission Deadline | 28 calendar days from date of document issue |
| Submission Email | rfq@athanplatform.io |
| Subject Line | RFQ-2024-001 \| [Your Agency Name] \| Live Athan Platform Proposal |
| Format | PDF or DOCX. Max 50MB. Architecture diagrams may be submitted as separate image files. |
| Clarification Window | Technical Q&A calls available during weeks 2–3 of the submission window. Email to book a 60-minute briefing session. |
| Shortlisting | Top 3 vendors will be invited to a 2-hour technical deep-dive presentation within 14 days of proposal deadline. |

> **★** We recognise this is an ambitious and strategically complex engagement. We are seeking a genuine long-term technical partner, not merely a vendor. The agency selected for Phase 1 will have a significant commercial and reputational advantage when Phase 2–7 development commences.

---

## Appendix A: Non-Functional Requirements Summary

| NFR Category | Requirement | Target Metric | Test Method |
|---|---|---|---|
| Performance | API response time (p95) | < 200ms for all REST endpoints | Load test: k6 / Locust |
| Performance | Stream connection time | < 3 seconds from tap to audio | Device testing (10 regions) |
| Performance | WebRTC latency | < 500ms end-to-end | Automated E2E latency test |
| Scalability | Concurrent listeners | 10,000+ per stream; 500,000+ total platform | Load simulation |
| Scalability | SSO throughput | 50,000 auth requests/minute peak | Stress testing |
| Availability | Platform uptime SLA | 99.9% (< 8.76 hrs downtime/year) | Monitoring + SLA report |
| Availability | Streaming uptime | 99.95% during Salah windows | Uptime monitoring |
| Security | Pen test severity | Zero unresolved Critical/High at launch | Third-party pen test |
| Security | OWASP compliance | OWASP Mobile Top 10 + OWASP API Top 10 addressed | Security audit |
| Accessibility | WCAG compliance | WCAG 2.1 AA for web admin dashboard | Automated + manual audit |
| Localisation | Language support | Arabic + English minimum at launch; RTL layout support mandatory | QA testing |
| Compliance | GDPR | Full compliance: consent, data export, right to deletion | Legal audit |

---

## Appendix B: Definitions of Priority Levels

| Priority Label | Definition |
|---|---|
| **MUST HAVE** | Non-negotiable. Absence of this requirement constitutes a failed delivery. No exceptions. |
| **SHOULD HAVE** | High importance. Must be present at launch unless extraordinary technical constraint is documented and approved by client in writing. |
| **COULD HAVE** | Desirable enhancement. Can be deferred to a post-launch sprint if timeline constraints require prioritisation. |
| **WON'T HAVE** | Explicitly excluded from this engagement scope. Documented to prevent scope creep. |

---

**END OF DOCUMENT**

RFQ-2024-001 | Version 1.0 | Confidential
Athan Platform Initiative | projects@athanplatform.io

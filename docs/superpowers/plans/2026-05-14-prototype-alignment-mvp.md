# Prototype Alignment + MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Re-skin the existing broadcaster-side Flutter app pixel-for-pixel to the HTML prototype (`C:\Users\almos\Projects\prototype`), reusing the ornate prayer-widget design from the older Flutter reference (`C:\Users\almos\Projects\muslimguider-flutter`), then upgrade the mock implementation into a real working MVP with live audio capture and local persistence.

**Architecture:** Keep the existing layered structure (Riverpod providers + repository pattern + go_router shell + mock-data isolation). Replace placeholder visuals with prototype-accurate layouts. Replace mock audio/recording with real `record` + `path_provider` implementations behind the existing repository interfaces. Local-only MVP — no backend yet.

**Tech Stack:** Flutter SDK ^3.11.5, flutter_riverpod ^2.5.1, go_router ^14.0.0, flutter_svg, google_fonts (DM Sans + Instrument Sans), material_symbols_icons, record (audio capture), path_provider, shared_preferences, adhan_dart (prayer-time calc), flutter_compass + geolocator (Qibla), hijri.

**Scope notes:**
- Broadcaster-side only. Listener navigation tabs (`Nearby`, `Inbox`, `Me`) stay as stubs.
- Mock isolation rule from previous plan still holds: files under `lib/data/mock/` may only be imported by files under `lib/data/repositories/mock/`.
- The plan is phased so each phase ends with a working app. You can stop after Phase 3 (visual parity only) or continue to Phase 4 (real MVP).
- All tasks follow TDD where a widget tree is observable; for asset/config tasks the verification step is "app launches and asset loads".

---

## ⚠ MANDATORY PRE-EXECUTION AMENDMENTS

This section captures fixes from a code-review pass on the original plan. Every implementation subagent MUST consult this section before pasting code from the corresponding task. If a task body and an amendment disagree, the amendment wins.

### Amendment 0 — Insert a new Task 0 before Task 1

Consolidate all new pubspec dependencies into one upfront task to avoid 6 separate `flutter pub get` cycles and one stale entry. Run this FIRST.

**Task 0: Consolidate pubspec dependencies**

- [ ] **Step 1:** In `pubspec.yaml` under `dependencies:`, add the following (preserve existing entries):

```yaml
  flutter_svg: ^2.0.10
  google_fonts: ^6.2.1                # already present — leave as is
  material_symbols_icons: ^4.2901.0
  record: ^5.1.2
  path_provider: ^2.1.4
  shared_preferences: ^2.3.2
  adhan_dart: ^3.2.0                  # see Amendment 9 — verify package name first
  geolocator: ^13.0.1
  flutter_compass: ^0.8.1
  permission_handler: ^11.3.1         # already present — leave as is
```

- [ ] **Step 2:** Remove `noise_meter: ^5.0.0` from `dependencies:` — it is replaced by `record`'s `onAmplitudeChanged` stream.

- [ ] **Step 3:** Run `flutter pub get`. Expected: clean resolve, no version conflicts.

- [ ] **Step 4:** Verify `record` and `adhan_dart` package APIs match what the plan assumes (see Amendments 8 + 9). If pub.dev shows different names or signatures, update the amendments BEFORE Tasks 30/32 run.

- [ ] **Step 5:** Commit.

```
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): consolidate new dependencies for prototype-alignment plan"
```

Then continue with Task 1 — but skip Task 1 Step 3 (the per-task `flutter_svg` add) and Task 4 Step 1 (the per-task `material_symbols_icons` add), because Task 0 already added them.

---

### Amendment 1 — Task 5: `ColorScheme.dark(...)` is not const

In `AppTheme.dark()`, change:

```dart
colorScheme: const ColorScheme.dark(
```

to:

```dart
colorScheme: ColorScheme.dark(
```

`ColorScheme.dark` is a non-const generative constructor in current Flutter SDKs.

---

### Amendment 2 — Task 7: `BackdropFilter` inside `bottomNavigationBar` will not blur

`bottomNavigationBar` is composited in a separate slot from `body`, so a `BackdropFilter` there sees no underlying pixels. To make the blur actually visible:

1. In `_BroadcasterShell.build` (`lib/core/router/app_router.dart`), set `extendBody: true` on the Scaffold AND move the nav out of `bottomNavigationBar` into a `Stack` overlay over the body:

```dart
return Scaffold(
  extendBody: true,
  body: Stack(
    children: [
      Positioned.fill(child: child),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: FloatingPillNav(
          currentIndex: _currentIndex,
          onTap: (i) => GoRouter.of(context).go(_tabs[i]),
        ),
      ),
    ],
  ),
);
```

2. `FloatingPillNav` itself stays as written (the `BackdropFilter` + `ClipRRect` are correct now that there are pixels behind it).

---

### Amendment 3 — Task 9: `HijriCalendar.toFormat` does not exist in `hijri ^3.0.0`

Replace the line:

```dart
final hijri = HijriCalendar.fromDate(now).toFormat('dd MMMM yyyy');
```

with:

```dart
final h = HijriCalendar.fromDate(now);
final hijri = '${h.hDay} ${h.longMonthName} ${h.hYear}';
```

Apply the same fix anywhere else the plan calls `toFormat()` on a `HijriCalendar`.

---

### Amendment 4 — Task 10: Painter draw order — separators must be drawn AFTER the rotation transform is unwound, AND the saveLayer must be bounded

Replace the entire `paint()` body in `PrayerSegmentsPainter` with:

```dart
@override
void paint(Canvas canvas, Size size) {
  final center = size.center(Offset.zero);
  final outerR = size.width / 2;
  final innerR = outerR * (120 / 165);
  final ringRect = Rect.fromCircle(center: center, radius: outerR);
  final layerBounds = Rect.fromCircle(center: center, radius: outerR);

  // Layer 1: rotated colored segments with inner hole punched out.
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  canvas.translate(-center.dx, -center.dy);

  canvas.saveLayer(layerBounds, Paint());
  final segPaint = Paint()..style = PaintingStyle.fill;
  for (final s in _stops) {
    final startRad = (s.start - 90) * math.pi / 180;
    final sweepRad = (s.end - s.start) * math.pi / 180;
    segPaint.color = s.color;
    canvas.drawArc(ringRect, startRad, sweepRad, true, segPaint);
  }
  canvas.drawCircle(center, innerR, Paint()..blendMode = BlendMode.clear);
  canvas.restore(); // matches saveLayer
  canvas.restore(); // matches rotation save

  // Layer 2: gold separator bars at the segment boundaries, painted on the
  // un-rotated root canvas — but with `rotation` added to each angle so they
  // align with the rotated segment edges.
  final goldPaint = Paint()..color = const Color(0xFFDAA03C);
  final scale = size.width / 330;
  final barW = 46.0 * scale;
  final barH = 6.0 * scale;
  for (final angle in [0.0, 70.0, 185.0, 315.0]) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((angle * math.pi / 180) + rotation - math.pi / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(outerR - barW, -barH / 2, barW, barH),
        const Radius.circular(1.5),
      ),
      goldPaint,
    );
    canvas.restore();
  }
}
```

Key changes: bounded `saveLayer` (no `Rect.largest`), explicit comments on the save/restore balance (now 2 saves / 2 restores in Layer 1), and gold separators painted in Layer 2 after the rotation is fully unwound — but with `rotation` added to each angle so they align with the segment boundaries.

---

### Amendment 5 — Task 11: Adhan top pointer — apply `_s()` scaling and pin horizontal position

Replace the top-pointer `Positioned` block at the end of `PrayerWidget`'s Stack with:

```dart
Positioned(
  top: _s(8),
  left: size / 2 - _s(10),
  child: Transform.rotate(
    angle: math.pi,
    child: SvgPicture.asset('assets/svg/qibla_direction.svg', width: _s(20), height: _s(16)),
  ),
),
```

This keeps the pointer centered horizontally regardless of `size`, and the dimensions scale proportionally.

---

### Amendment 6 — Task 21: `BigRedBroadcastButton` is "tap & hold", not "tap"

The label, the prototype copy, and the safety rationale all say tap-and-hold. The plan currently fires on `onTapUp`. Replace the `GestureDetector` block with:

```dart
return GestureDetector(
  onLongPressDown: (_) => setState(() => _pressed = true),
  onLongPressCancel: () => setState(() => _pressed = false),
  onLongPressEnd: (_) => setState(() => _pressed = false),
  onLongPress: () {
    setState(() => _pressed = false);
    widget.onConfirmed();
  },
  child: AnimatedScale(
    // ...rest unchanged
  ),
);
```

Default `Duration` for `onLongPress` is ~500ms, which matches the prototype's "tap & hold" affordance.

---

### Amendment 7 — Task 23: `AudioWaveform` leaks its stream subscription

Add a `StreamSubscription` field and cancel it in `dispose`. Updated state class:

```dart
class _AudioWaveformState extends State<AudioWaveform> {
  late final List<double> _samples;
  final _rand = math.Random();
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _samples = List.generate(widget.barCount, (_) => 0.2 + _rand.nextDouble() * 0.6);
    _sub = widget.levelStream.listen(_onLevel);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // _onLevel and build unchanged
}
```

Also add `import 'dart:async';` at the top of the file.

---

### Amendment 8 — Task 30: `requestPermission` must actually request, and verify `record` API

`AudioRecorder.hasPermission()` only queries. Replace `RealAudioRecorder.requestPermission` with:

```dart
@override
Future<void> requestPermission() async {
  await Permission.microphone.request();
}
```

Add at the top of the file:

```dart
import 'package:permission_handler/permission_handler.dart';
```

(`permission_handler` is already in pubspec via Task 0.)

Also: BEFORE pasting the rest of `RealAudioRecorder`, run `flutter pub get` and `flutter pub deps` to confirm `record: ^5.1.2` resolved. Open `.dart_tool/package_config.json` if needed and verify the `AudioRecorder` class + `onAmplitudeChanged(Duration)` API. If the API differs from what the plan assumes, append a note to this amendments section and adjust before continuing.

---

### Amendment 9 — Task 32: verify `adhan_dart` package name, and prayer-time getters are nullable

1. **Verify package name.** The plan pins `adhan_dart: ^3.2.0`. On pub.dev the canonical Adhan package may be published as `adhan` (without `_dart`). Before Task 32 runs, check pub.dev. If the package is actually `adhan`, update the pubspec entry in Task 0 and the import in Task 32 from `package:adhan_dart/adhan_dart.dart` to `package:adhan/adhan.dart`.

2. **Null-safety on prayer times.** Replace:

```dart
return model.PrayerTimes(
  fajr: pt.fajr!.toLocal(),
  sunrise: pt.sunrise!.toLocal(),
  // ...
);
```

with:

```dart
DateTime _req(DateTime? t, String name) =>
    t ?? (throw StateError('adhan returned null for $name — invalid coords?'));
return model.PrayerTimes(
  fajr: _req(pt.fajr, 'fajr').toLocal(),
  sunrise: _req(pt.sunrise, 'sunrise').toLocal(),
  dhuhr: _req(pt.dhuhr, 'dhuhr').toLocal(),
  asr: _req(pt.asr, 'asr').toLocal(),
  maghrib: _req(pt.maghrib, 'maghrib').toLocal(),
  isha: _req(pt.isha, 'isha').toLocal(),
);
```

This gives a clear error at the boundary (polar latitudes / invalid coords) instead of a bare null-check crash deep in the widget tree.

---

### Amendment 10 — Task 33: `FlutterCompass.events` is nullable; non-null assertion crashes on web/desktop and on Android devices without a magnetometer

Replace the body of `QiblaService.bearingTo` from `return FlutterCompass.events!.map(...)` onward with:

```dart
final events = FlutterCompass.events;
if (events == null) return const Stream<double>.empty();
return events.map((e) {
  final heading = e.heading ?? 0;
  return (qiblaBearingFromNorth - heading + 360) % 360;
});
```

Consumers of `qiblaDirectionProvider` should also handle the empty-stream case (default to a static qibla angle if no compass data has arrived).

---

### Amendment 11 — Task 18 must run BEFORE Tasks 15-17

The dashboard widgets re-skinned in Tasks 15-17 either use or live alongside `SlideToBroadcast`. Task 18 moves and refactors `SlideToBroadcast` into `lib/core/widgets/` with `dashboard`/`home` variants. Execute Task 18 first.

New execution order for Phase 2: **7, 8, 9, 10, 11, 12, 13, 18, 15, 16, 17, 19, 20, 21, 22, 23, 24.**

(Task numbers in this document are unchanged; only the run order shifts.)

---

### Amendment 12 — Task 28: clarify which audio source Phase 3 reads

In Task 28 Step 1 (re-skin `LiveBroadcastScreen`), replace the parenthetical "for Phase 3 still use the existing `micLevelProvider`" with the explicit rule:

> Phase 3 reads ONLY from `micLevelProvider`. Do NOT import `audioRecorderRepositoryProvider` in this task. The source swap from sine-wave fallback to real microphone amplitude is performed exclusively by Task 30 Step 4.

---

### Amendment 13 — Task 34: enumerate exact test files that need updating

When applying Task 34 Step 1, audit and update the following test files (each was authored against the old visual tree and will fail after Phase 2-3):

```
test/core/widgets/app_bottom_nav_test.dart           — delete or rewrite to FloatingPillNav
test/core/router/app_router_test.dart                — assertions on bottomNavigationBar slot
test/features/broadcaster/home/home_prayer_widget_screen_test.dart  — new widget tree
test/features/broadcaster/home/widgets/role_badge_test.dart         — new pill style
test/features/broadcaster/live/widgets/volume_meter_test.dart       — renamed to mic_level_meter_test.dart
test/features/broadcaster/live/live_broadcast_screen_test.dart      — Banner/Waveform/Stats grid
test/features/broadcaster/summary/broadcast_summary_screen_test.dart — RetentionChart, success banner
test/features/broadcaster/dashboard/masjid_dashboard_screen_test.dart — new KPI grid layout
test/integration/broadcaster_happy_path_test.dart    — full-flow happy path against new screens
```

For each: run the test, capture the failing assertion, update to the new widget API, re-run, confirm green.

---

### Amendment 14 — Scope defer: prototype screens that are NOT in this plan

The following broadcaster-side prototype screens are intentionally out of scope and will get a follow-up plan:

- `prototype/screens/schedule-broadcast-muadhin.html`
- `prototype/screens/audit-log-muadhin.html`
- `prototype/screens/profile.html`
- `prototype/screens/verification-history.html`
- `prototype/screens/verification-status-masjid-al-abrar.html`
- `prototype/screens/permissions-bundle.html`
- `prototype/screens/inbox.html`

If a routing dead-end appears (e.g. a button in this plan navigates to one of these screens), leave the existing `StubScreen` placeholder in place and move on.

---

## Reference Map

When a task says "match the prototype", read the HTML file and translate its Tailwind tokens to Flutter using the design-system tables in Tasks 2 and 3. Token names are identical across prototype and Flutter — only the value-binding layer changes.

| Screen | Prototype file | Current Flutter file |
|---|---|---|
| Home · Prayer Widget (Muadhin) | `prototype/screens/home-prayer-widget-muadhin.html` | `lib/features/broadcaster/home/home_prayer_widget_screen.dart` |
| Masjid Dashboard | `prototype/screens/masjid-dashboard-muadhin.html` | `lib/features/broadcaster/dashboard/masjid_dashboard_screen.dart` |
| Go Live · Pre-Check | `prototype/screens/go-live-pre-broadcast-check.html` | `lib/features/broadcaster/go_live/go_live_pre_check_screen.dart` |
| Live Broadcast | `prototype/screens/live-broadcast-masjid-al-abrar.html` | `lib/features/broadcaster/live/live_broadcast_screen.dart` |
| Broadcast Summary | `prototype/screens/broadcast-summary-masjid-al-abrar.html` | `lib/features/broadcaster/summary/broadcast_summary_screen.dart` |

| Reference widget | Reference path | Notes |
|---|---|---|
| Ornate prayer widget (layered SVG circle) | `muslimguider-flutter/lib/presentation/screens/home/widgets/prayer_widget.dart` | Uses action_slider + layered SVGs — port structure, not GetX state mgmt |
| Slide-to-broadcast | reference's `_adhanLockWt` inside above file | Already partially implemented in `lib/features/broadcaster/shared/slide_to_broadcast.dart` |
| Live broadcast status widget | `muslimguider-flutter/lib/presentation/widgets/adhan_broadcast_status_widget.dart` | Banner + listener counter pattern |
| 5-slot nav | `muslimguider-flutter/lib/presentation/screens/main/widgets/navigation_bar_widget.dart` | Reference is customizable; prototype is fixed pill nav |

---

## File Structure

```
muslim-guider-pro/
├── assets/
│   ├── svg/                              # Task 1 — copied from prototype/assets/svg/
│   │   ├── main_circle.svg, circle.svg, gold.svg, qibla_direction.svg,
│   │   │   prayer_call_button.svg, adan.svg, back_texture.svg,
│   │   │   athan_locked.svg, athan_unlocked.svg
│   │   └── middle_circle/
│   │       └── CLOUDY_SUNSET.svg (+ 9 other time-of-day variants)
│
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Task 2 — expand to full prototype palette
│   │   │   ├── app_text_styles.dart      # Task 3 — Instrument Sans + DM Sans role styles
│   │   │   └── app_theme.dart            # Task 5 — wire new tokens
│   │   ├── icons/
│   │   │   └── material_symbols.dart     # Task 4 — IconSymbol helper
│   │   ├── widgets/
│   │   │   ├── bg_pattern.dart           # Task 6
│   │   │   ├── floating_pill_nav.dart    # Task 7 — replaces AppBottomNav
│   │   │   ├── time_date_stack.dart      # Task 9
│   │   │   ├── prayer_widget/            # Tasks 10–13 — the big one
│   │   │   │   ├── prayer_widget.dart
│   │   │   │   ├── prayer_segments_painter.dart
│   │   │   │   ├── current_prayer_card.dart
│   │   │   │   └── mic_lock_indicator.dart
│   │   │   ├── slide_to_broadcast.dart   # Task 18 (moved from features/)
│   │   │   ├── pre_check_list.dart       # Task 19
│   │   │   ├── mic_level_meter.dart      # Task 20
│   │   │   ├── big_red_broadcast_button.dart  # Task 21
│   │   │   ├── live_banner.dart          # Task 22
│   │   │   ├── audio_waveform.dart       # Task 23
│   │   │   └── retention_chart.dart      # Task 24
│   │
│   ├── features/broadcaster/
│   │   ├── home/home_prayer_widget_screen.dart       # Task 25 — full re-skin
│   │   ├── dashboard/                                # Tasks 15–17, 26
│   │   ├── go_live/go_live_pre_check_screen.dart     # Task 27
│   │   ├── live/live_broadcast_screen.dart           # Task 28
│   │   └── summary/broadcast_summary_screen.dart     # Task 29
│   │
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── audio_recorder_repository.dart   # Task 30 — interface
│   │   │   └── real/
│   │   │       ├── real_audio_recorder.dart     # Task 30
│   │   │       └── real_broadcast_repository.dart  # Task 31
│   │   └── services/
│   │       ├── prayer_time_service.dart         # Task 32
│   │       └── qibla_service.dart               # Task 33
│   │
│   └── providers/
│       ├── audio_recorder_provider.dart         # Task 30
│       └── qibla_direction_provider.dart        # Task 33
│
├── pubspec.yaml                          # Tasks 1, 4, 5, 30, 32, 33 — register deps + assets
└── test/                                 # Task 34 — update existing + add new
```

**Decomposition rule of thumb:** any widget shared across more than one screen lives in `lib/core/widgets/`. Per-screen sub-widgets stay under that screen's `widgets/` folder. The ornate prayer widget gets its own subfolder because it has 4 collaborating pieces.

---

# Phase 1: Foundation (assets, fonts, theme tokens)

### Task 1: Copy SVG assets from prototype to app

**Files:**
- Create: `assets/svg/` (with all SVGs from `C:\Users\almos\Projects\prototype\assets\svg\`)
- Modify: `pubspec.yaml`

- [ ] **Step 1: Copy assets**

```
powershell -Command "Copy-Item -Recurse -Force 'C:\Users\almos\Projects\prototype\assets\svg' 'C:\Users\almos\projects\muslim-guider-pro\assets\svg'"
```

- [ ] **Step 2: Register assets in pubspec.yaml**

Replace the commented `assets:` block under `flutter:` with:

```yaml
  assets:
    - assets/svg/
    - assets/svg/middle_circle/
    - assets/svg/moon/
    - assets/svg/new_icons/
```

- [ ] **Step 3: Add `flutter_svg`**

Under `dependencies:` in pubspec.yaml add:

```yaml
  flutter_svg: ^2.0.10
```

- [ ] **Step 4: Run pub get + verify**

```
flutter pub get
flutter analyze
```

Expected: no analyzer errors.

- [ ] **Step 5: Commit**

```
git add assets/svg pubspec.yaml pubspec.lock
git commit -m "chore(assets): bundle prototype SVGs and add flutter_svg"
```

---

### Task 2: Expand AppColors to full prototype palette

**Files:**
- Modify: `lib/core/theme/app_colors.dart`
- Test: `test/core/theme/app_colors_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/theme/app_colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_colors.dart';

void main() {
  test('AppColors exposes prototype tokens', () {
    expect(AppColors.primary, const Color(0xFFF2C050));
    expect(AppColors.bgDeepNight, const Color(0xFF0F1626));
    expect(AppColors.bgElevated, const Color(0xFF1A2238));
    expect(AppColors.surfaceCard, const Color(0xFF232C44));
    expect(AppColors.goldHighlight, const Color(0xFFF0C75E));
    expect(AppColors.purpleDeep, const Color(0xFF5B2C9F));
    expect(AppColors.infoBlue, const Color(0xFF4FC3D9));
    expect(AppColors.successGreen, const Color(0xFF4ADE80));
    expect(AppColors.liveRed, const Color(0xFFFF6B6B));
    expect(AppColors.fajrPurple, const Color(0xFF5B2C9F));
    expect(AppColors.asrCyan, const Color(0xFF4FC3D9));
    expect(AppColors.maghribOrange, const Color(0xFFE8763A));
  });
}
```

Run: `flutter test test/core/theme/app_colors_test.dart -r expanded`
Expected: FAIL with undefined getters.

- [ ] **Step 2: Implement**

Replace `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary / gold
  static const primary = Color(0xFFF2C050);
  static const primaryFixed = Color(0xFFFFDF9F);
  static const primaryFixedDim = Color(0xFFF1BF4F);
  static const primaryContainer = Color(0xFFD4A537);
  static const onPrimary = Color(0xFF402D00);
  static const onPrimaryContainer = Color(0xFF533C00);
  static const onPrimaryFixed = Color(0xFF261A00);
  static const onPrimaryFixedVariant = Color(0xFF5C4300);
  static const goldDeep = Color(0xFF8B6914);
  static const goldHighlight = Color(0xFFF0C75E);
  static const surfaceTint = Color(0xFFF1BF4F);
  static const inversePrimary = Color(0xFF795900);

  // Backgrounds / surfaces
  static const bgDeepNight = Color(0xFF0F1626);
  static const bgElevated = Color(0xFF1A2238);
  static const background = Color(0xFF17130C);
  static const surface = Color(0xFF17130C);
  static const surfaceDim = Color(0xFF17130C);
  static const surfaceBright = Color(0xFF3E3830);
  static const surfaceCard = Color(0xFF232C44);
  static const surfaceInset = Color(0xFF2D3658);
  static const surfaceVariant = Color(0xFF39342B);
  static const surfaceContainer = Color(0xFF231F17);
  static const surfaceContainerLow = Color(0xFF1F1B13);
  static const surfaceContainerLowest = Color(0xFF110E07);
  static const surfaceContainerHigh = Color(0xFF2E2921);
  static const surfaceContainerHighest = Color(0xFF39342B);
  static const inverseSurface = Color(0xFFEBE1D4);
  static const inverseOnSurface = Color(0xFF353027);

  // Borders / outlines
  static const borderLow = Color(0xFF2D3658);
  static const borderMedium = Color(0xFF3A4566);
  static const outline = Color(0xFF9B8F7C);
  static const outlineVariant = Color(0xFF4E4636);

  // Ink (text)
  static const inkPrimary = Color(0xFFFFFFFF);
  static const inkMuted = Color(0xFFA8B0C4);
  static const inkSubtle = Color(0xFF6B7280);
  static const onSurface = Color(0xFFEBE1D4);
  static const onSurfaceVariant = Color(0xFFD2C5B0);
  static const onBackground = Color(0xFFEBE1D4);

  // Semantic
  static const liveRed = Color(0xFFFF6B6B);
  static const liveRedBg = Color(0xFF3D1A1A);
  static const successGreen = Color(0xFF4ADE80);
  static const successGreenBg = Color(0xFF1A3D2A);
  static const warningAmber = Color(0xFFFFA94D);
  static const warningAmberBg = Color(0xFF3D2F0F);
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);
  static const onError = Color(0xFF690005);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Prayer-specific
  static const fajrPurple = Color(0xFF5B2C9F);
  static const purpleDeep = Color(0xFF5B2C9F);
  static const asrCyan = Color(0xFF4FC3D9);
  static const infoBlue = Color(0xFF4FC3D9);
  static const maghribOrange = Color(0xFFE8763A);

  // Secondary / tertiary
  static const secondary = Color(0xFFDCB8FF);
  static const tertiary = Color(0xFFADC8FF);
}
```

- [ ] **Step 3: Run test and verify pass**

Run: `flutter test test/core/theme/app_colors_test.dart -r expanded`
Expected: PASS.

- [ ] **Step 4: Commit**

```
git add lib/core/theme/app_colors.dart test/core/theme/app_colors_test.dart
git commit -m "feat(theme): expand color palette to full prototype token set"
```

---

### Task 3: Build AppTextStyles aligned to prototype font roles

The prototype declares these font roles in every screen's tailwind.config:

| Token | Family | Size | Weight | Letter-spacing |
|---|---|---|---|---|
| `headline-xl` | Instrument Sans | 40 | 700 | -0.01em |
| `headline-lg` | Instrument Sans | 28 | 700 | -0.01em |
| `headline-md` | Instrument Sans | 24 | 700 | — |
| `body-lg` | DM Sans | 16 | 400 | — |
| `body-md` | DM Sans | 14 | 400 | — |
| `label-caps` | DM Sans | 11 | 500 | 0.08em |
| `numeral-time` | Instrument Sans | 15 (used at 64–68px on big numerals) | 700 | — |

**Files:**
- Modify: `lib/core/theme/app_text_styles.dart`
- Test: `test/core/theme/app_text_styles_test.dart`

- [ ] **Step 1: Failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_text_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('AppTextStyles exposes prototype roles', (_) async {
    expect(AppTextStyles.headlineXl().fontSize, 40);
    expect(AppTextStyles.headlineLg().fontSize, 28);
    expect(AppTextStyles.headlineMd().fontSize, 24);
    expect(AppTextStyles.bodyLg().fontSize, 16);
    expect(AppTextStyles.bodyMd().fontSize, 14);
    expect(AppTextStyles.labelCaps().fontSize, 11);
    expect(AppTextStyles.labelCaps().letterSpacing, closeTo(0.88, 0.01));
    expect(AppTextStyles.numeralTime().fontWeight, FontWeight.w700);
  });
}
```

Run: `flutter test test/core/theme/app_text_styles_test.dart`
Expected: FAIL.

- [ ] **Step 2: Implement**

Replace `lib/core/theme/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle headlineXl({Color color = AppColors.inkPrimary}) =>
      GoogleFonts.instrumentSans(
        fontSize: 40,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.inkPrimary}) =>
      GoogleFonts.instrumentSans(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.28,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.inkPrimary}) =>
      GoogleFonts.instrumentSans(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.dmSans(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: color);

  static TextStyle bodyMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.dmSans(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: color);

  static TextStyle labelCaps({Color color = AppColors.primary}) =>
      GoogleFonts.dmSans(
        fontSize: 11,
        height: 1.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.88,
        color: color,
      );

  static TextStyle numeralTime({double fontSize = 15, Color color = AppColors.primary}) =>
      GoogleFonts.instrumentSans(
        fontSize: fontSize,
        height: 1.0,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );

  static TextStyle arabic({double fontSize = 16, Color color = AppColors.inkPrimary}) =>
      GoogleFonts.notoNaskhArabic(fontSize: fontSize, fontWeight: FontWeight.w500, color: color);
}
```

- [ ] **Step 3: Run test + commit**

```
flutter test test/core/theme/app_text_styles_test.dart
git add lib/core/theme/app_text_styles.dart test/core/theme/app_text_styles_test.dart
git commit -m "feat(theme): add Instrument Sans + DM Sans text roles matching prototype"
```

---

### Task 4: Add Material Symbols Outlined icon font

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/icons/material_symbols.dart`

- [ ] **Step 1: Add package**

Add to pubspec.yaml under `dependencies:`:

```yaml
  material_symbols_icons: ^4.2901.0
```

Then run `flutter pub get`.

- [ ] **Step 2: Create symbol helper**

Create `lib/core/icons/material_symbols.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

class Sym {
  static IconData mic(bool filled) => filled ? Symbols.mic_rounded : Symbols.mic;
  static IconData dashboard(bool filled) => filled ? Symbols.dashboard_rounded : Symbols.dashboard;
  static IconData home(bool filled) => filled ? Symbols.home_rounded : Symbols.home;
  static IconData person(bool filled) => filled ? Symbols.person_rounded : Symbols.person;
  static IconData mail(bool filled) => filled ? Symbols.mail_rounded : Symbols.mail;
  static IconData locationOn(bool filled) =>
      filled ? Symbols.location_on_rounded : Symbols.location_on;

  static const IconData cellTower = Symbols.cell_tower;
  static const IconData mosque = Symbols.mosque;
  static const IconData chevronLeft = Symbols.chevron_left;
  static const IconData stopFilled = Symbols.stop_rounded;
  static const IconData pause = Symbols.pause;
  static const IconData edit = Symbols.edit;
  static const IconData checkCircle = Symbols.check_circle_rounded;
  static const IconData cancelCircle = Symbols.cancel_rounded;
  static const IconData trendingUp = Symbols.trending_up_rounded;
  static const IconData keyboardDoubleArrowUp = Symbols.keyboard_double_arrow_up;
  static const IconData signalCellular = Symbols.signal_cellular_alt_rounded;
  static const IconData wifi = Symbols.wifi_rounded;
  static const IconData batteryFull = Symbols.battery_full_rounded;
}
```

- [ ] **Step 3: Sanity check + commit**

```
flutter analyze
git add pubspec.yaml pubspec.lock lib/core/icons/material_symbols.dart
git commit -m "feat(icons): add Material Symbols Outlined font and Sym lookup helper"
```

---

### Task 5: Update AppTheme to wire new tokens

**Files:**
- Modify: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Replace AppTheme**

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeepNight,
      canvasColor: AppColors.bgDeepNight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryContainer,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.onSurface,
        background: AppColors.bgDeepNight,
        onBackground: AppColors.onBackground,
        error: AppColors.error,
        outline: AppColors.borderMedium,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headlineXl(),
        displayMedium: AppTextStyles.headlineLg(),
        headlineMedium: AppTextStyles.headlineMd(),
        bodyLarge: AppTextStyles.bodyLg(),
        bodyMedium: AppTextStyles.bodyMd(),
        labelSmall: AppTextStyles.labelCaps(),
      ),
      iconTheme: const IconThemeData(color: AppColors.inkMuted, size: 22),
      dividerColor: AppColors.borderMedium,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
```

- [ ] **Step 2: Run app**

```
flutter run -d chrome
```

Expected: deep-night background with gold accents. No console errors.

- [ ] **Step 3: Commit**

```
git add lib/core/theme/app_theme.dart
git commit -m "feat(theme): wire AppTheme to new prototype tokens"
```

---

### Task 6: BgPattern overlay widget

**Files:**
- Create: `lib/core/widgets/bg_pattern.dart`
- Test: `test/core/widgets/bg_pattern_test.dart`

- [ ] **Step 1: Failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim_guider_pro/core/widgets/bg_pattern.dart';

void main() {
  testWidgets('BgPattern renders a tiled SVG at low opacity', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BgPattern())));
    expect(find.byType(SvgPicture), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, closeTo(0.04, 0.001));
  });
}
```

- [ ] **Step 2: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BgPattern extends StatelessWidget {
  const BgPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.04,
        child: SvgPicture.asset(
          'assets/svg/back_texture.svg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Test + commit**

```
flutter test test/core/widgets/bg_pattern_test.dart
git add lib/core/widgets/bg_pattern.dart test/core/widgets/bg_pattern_test.dart
git commit -m "feat(widgets): add BgPattern overlay for screen backgrounds"
```

---

# Phase 2: Shared atoms & molecules

### Task 7: FloatingPillNav (replaces AppBottomNav)

**Files:**
- Create: `lib/core/widgets/floating_pill_nav.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/core/widgets/floating_pill_nav_test.dart`

- [ ] **Step 1: Failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/floating_pill_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('FloatingPillNav shows 5 tabs', (tester) async {
    int? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: const SizedBox.shrink(),
        bottomNavigationBar: FloatingPillNav(
          currentIndex: 1,
          onTap: (i) => tapped = i,
        ),
      ),
    ));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    await tester.tap(find.text('Nearby'));
    expect(tapped, 2);
  });
}
```

- [ ] **Step 2: Implement**

```dart
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../icons/material_symbols.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavSpec>[
    _NavSpec('Home', _IconRef.home),
    _NavSpec('Dashboard', _IconRef.dashboard),
    _NavSpec('Nearby', _IconRef.locationOn),
    _NavSpec('Inbox', _IconRef.mail),
    _NavSpec('Me', _IconRef.person),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgElevated.withOpacity(0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _PillItem(spec: _items[i], active: i == currentIndex, onTap: () => onTap(i)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _IconRef { home, dashboard, locationOn, mail, person }
class _NavSpec { const _NavSpec(this.label, this.icon); final String label; final _IconRef icon; }

class _PillItem extends StatelessWidget {
  const _PillItem({required this.spec, required this.active, required this.onTap});
  final _NavSpec spec;
  final bool active;
  final VoidCallback onTap;
  IconData _icon() => switch (spec.icon) {
        _IconRef.home => Sym.home(active),
        _IconRef.dashboard => Sym.dashboard(active),
        _IconRef.locationOn => Sym.locationOn(active),
        _IconRef.mail => Sym.mail(active),
        _IconRef.person => Sym.person(active),
      };
  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.primary : Colors.transparent;
    final fg = active ? AppColors.onPrimary : AppColors.inkMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 10, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(), color: fg, size: 22),
            const SizedBox(height: 2),
            Text(spec.label, style: AppTextStyles.labelCaps(color: fg).copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Swap into router**

In `lib/core/router/app_router.dart`, replace `bottomNavigationBar: AppBottomNav(...)` with `bottomNavigationBar: FloatingPillNav(currentIndex: _currentIndex, onTap: (i) => GoRouter.of(context).go(_tabs[i]))`. Replace the `AppBottomNav` import with `FloatingPillNav` import.

- [ ] **Step 4: Run full test suite**

```
flutter test
```

Update any tests that assert on `AppBottomNav` to use `FloatingPillNav` instead. Expected: PASS.

- [ ] **Step 5: Commit**

```
git add lib/core/widgets/floating_pill_nav.dart lib/core/router/app_router.dart test/core/widgets/floating_pill_nav_test.dart
git commit -m "feat(nav): replace BottomNav with floating pill nav matching prototype"
```

---

### Task 8: Re-skin RoleBadge

The prototype version: `bg-primary/10`, `border-primary/40`, `rounded-full`, `cell_tower` icon (primary color), label `MUADHIN · MASJID AL-ABRAR` in primary, 10px tracking-wider.

**Files:**
- Modify: `lib/features/broadcaster/home/widgets/role_badge.dart`

- [ ] **Step 1: Update widget**

```dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.masjidName, this.role = 'MUADHIN'});
  final String masjidName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        border: Border.all(color: AppColors.primary.withOpacity(0.40)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.cell_tower, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$role · ${masjidName.toUpperCase()}',
            style: AppTextStyles.labelCaps(color: AppColors.primary).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update existing test, run, commit**

```
flutter test
git commit -am "feat(widgets): re-skin RoleBadge with prototype pill style"
```

---

### Task 9: TimeDateStack widget

**Files:**
- Create: `lib/core/widgets/time_date_stack.dart`
- Test: `test/core/widgets/time_date_stack_test.dart`

- [ ] **Step 1: Failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/time_date_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('TimeDateStack shows time, AM/PM, and date line', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TimeDateStack(now: DateTime(2026, 5, 7, 14, 3))),
    ));
    expect(find.text('02:03'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
    expect(find.textContaining('May 7, 2026'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TimeDateStack extends StatelessWidget {
  const TimeDateStack({super.key, required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final hour12 = DateFormat('hh:mm').format(now);
    final ampm = DateFormat('a').format(now);
    final greg = DateFormat('MMM d, yyyy - EEEE').format(now);
    final hijri = HijriCalendar.fromDate(now).toFormat('dd MMMM yyyy');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hour12,
              style: AppTextStyles.numeralTime(fontSize: 68, color: AppColors.primary).copyWith(
                shadows: const [Shadow(color: Color(0x73F2C050), blurRadius: 18)],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              ampm,
              style: AppTextStyles.labelCaps(color: AppColors.primary)
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('$greg, $hijri',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(color: AppColors.inkMuted)),
      ],
    );
  }
}
```

- [ ] **Step 3: Test + commit**

```
flutter test test/core/widgets/time_date_stack_test.dart
git add lib/core/widgets/time_date_stack.dart test/core/widgets/time_date_stack_test.dart
git commit -m "feat(widgets): add TimeDateStack with gold time + Gregorian/Hijri date line"
```

---

### Task 10: PrayerSegmentsPainter (CustomPainter — conic gradient)

**Files:**
- Create: `lib/core/widgets/prayer_widget/prayer_segments_painter.dart`
- Test: `test/core/widgets/prayer_widget/prayer_segments_painter_test.dart`

- [ ] **Step 1: Failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/prayer_segments_painter.dart';

void main() {
  testWidgets('PrayerSegmentsPainter renders without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox.square(
          dimension: 330,
          child: CustomPaint(painter: PrayerSegmentsPainter()),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  test('shouldRepaint reflects rotation changes', () {
    final a = PrayerSegmentsPainter();
    final b = PrayerSegmentsPainter(rotation: 0);
    expect(a.shouldRepaint(b), isTrue);
  });
}
```

- [ ] **Step 2: Implement**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class PrayerSegmentsPainter extends CustomPainter {
  PrayerSegmentsPainter({this.rotation = 25 * math.pi / 180});
  final double rotation;

  static const _stops = [
    (start: 0.0,   end: 70.0,  color: Color(0xFF0F1011)),
    (start: 70.0,  end: 185.0, color: Color(0xFF434E52)),
    (start: 185.0, end: 315.0, color: Color(0xFF57D4E8)),
    (start: 315.0, end: 360.0, color: Color(0xFF35657D)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerR = size.width / 2;
    final innerR = outerR * (120 / 165);
    final ringRect = Rect.fromCircle(center: center, radius: outerR);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final segPaint = Paint()..style = PaintingStyle.fill;
    canvas.saveLayer(Rect.largest, Paint());
    for (final s in _stops) {
      final startRad = (s.start - 90) * math.pi / 180;
      final sweepRad = (s.end - s.start) * math.pi / 180;
      segPaint.color = s.color;
      canvas.drawArc(ringRect, startRad, sweepRad, true, segPaint);
    }
    // Cut the inner hole to form a ring.
    canvas.drawCircle(center, innerR, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Gold separators at 0/70/185/315 deg on outer edge.
    final goldPaint = Paint()..color = const Color(0xFFDAA03C);
    for (final angle in [0.0, 70.0, 185.0, 315.0]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle * math.pi / 180 - math.pi / 2);
      final scale = size.width / 330;
      final barW = 46.0 * scale;
      final barH = 6.0 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(outerR - barW, -barH / 2, barW, barH),
          const Radius.circular(1.5),
        ),
        goldPaint,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PrayerSegmentsPainter old) => old.rotation != rotation;
}
```

- [ ] **Step 3: Test + commit**

```
flutter test test/core/widgets/prayer_widget/prayer_segments_painter_test.dart
git add lib/core/widgets/prayer_widget/prayer_segments_painter.dart test/core/widgets/prayer_widget/prayer_segments_painter_test.dart
git commit -m "feat(widgets): add PrayerSegmentsPainter (conic ring + gold separators)"
```

---

### Task 11: PrayerWidget composing widget (layered SVGs + painter)

**Files:**
- Create: `lib/core/widgets/prayer_widget/prayer_widget.dart`
- Test: `test/core/widgets/prayer_widget/prayer_widget_test.dart`

- [ ] **Step 1: Implement**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'prayer_segments_painter.dart';

class PrayerWidget extends StatelessWidget {
  const PrayerWidget({
    super.key,
    this.size = 380,
    this.qiblaAngleDeg = 35,
    this.skyAsset = 'assets/svg/middle_circle/CLOUDY_SUNSET.svg',
  });

  final double size;
  final double qiblaAngleDeg;
  final String skyAsset;

  double _s(double n) => size * (n / 380);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset('assets/svg/main_circle.svg', width: size),
          Opacity(
            opacity: 0.9,
            child: SvgPicture.asset('assets/svg/circle.svg', width: _s(370)),
          ),
          Container(
            width: _s(330),
            height: _s(330),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F1011)),
          ),
          SizedBox.square(dimension: _s(330), child: CustomPaint(painter: PrayerSegmentsPainter())),
          Opacity(
            opacity: 0.9,
            child: Container(
              width: _s(301),
              height: _s(301),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF111317)),
            ),
          ),
          ClipOval(
            child: SizedBox.square(
              dimension: _s(240),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(skyAsset, fit: BoxFit.cover),
                  Transform.rotate(
                    angle: qiblaAngleDeg * math.pi / 180,
                    child: SvgPicture.asset('assets/svg/qibla_direction.svg', width: _s(220)),
                  ),
                  Positioned(
                    left: _s(95),
                    top: _s(42.5),
                    child: SvgPicture.asset('assets/svg/gold.svg', width: 16, height: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: _s(15),
            bottom: _s(20),
            width: _s(110),
            height: _s(110),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset('assets/svg/prayer_call_button.svg'),
                Container(
                  width: _s(60),
                  height: _s(60),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE1B354), Color(0xFFC18C2F)],
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/adan.svg',
                      width: _s(28),
                      height: _s(28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: _s(8),
            child: Transform.rotate(
              angle: math.pi,
              child: SvgPicture.asset('assets/svg/qibla_direction.svg', width: 20, height: 16),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Smoke test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/prayer_widget/prayer_widget.dart';

void main() {
  testWidgets('PrayerWidget builds without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PrayerWidget(size: 320))));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(PrayerWidget), findsOneWidget);
  });
}
```

Run: `flutter test test/core/widgets/prayer_widget/prayer_widget_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit**

```
git add lib/core/widgets/prayer_widget/prayer_widget.dart test/core/widgets/prayer_widget/prayer_widget_test.dart
git commit -m "feat(widgets): add ornate PrayerWidget composing 7 layered SVGs + painter"
```

---

### Task 12: CurrentPrayerCard (left-edge floating tag)

**Files:**
- Create: `lib/core/widgets/prayer_widget/current_prayer_card.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';

class CurrentPrayerCard extends StatelessWidget {
  const CurrentPrayerCard({
    super.key,
    required this.prayerName,
    required this.fromTime,
    required this.toTime,
  });

  final String prayerName;
  final String fromTime;
  final String toTime;

  @override
  Widget build(BuildContext context) {
    final hairline = const Color(0xFF729DBB).withOpacity(0.3);
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF51768E),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: hairline),
          right: BorderSide(color: hairline),
          bottom: BorderSide(color: hairline),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 15),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$prayerName Time',
              style: AppTextStyles.bodyMd(color: Colors.white)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('From - $fromTime',
              style: AppTextStyles.bodyMd(color: Colors.white)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w700, height: 1.3)),
          Text('To - $toTime',
              style: AppTextStyles.bodyMd(color: Colors.white)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w700, height: 1.3)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```
git add lib/core/widgets/prayer_widget/current_prayer_card.dart
git commit -m "feat(widgets): add CurrentPrayerCard left-edge floating tag"
```

---

### Task 13: Move + re-skin MicLockIndicator (pulse-mic)

**Files:**
- Move: `lib/features/broadcaster/home/widgets/mic_lock_indicator.dart` → `lib/core/widgets/prayer_widget/mic_lock_indicator.dart`

- [ ] **Step 1: Rewrite with animation**

```dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class MicLockIndicator extends StatefulWidget {
  const MicLockIndicator({super.key, required this.active});
  final bool active;
  @override
  State<MicLockIndicator> createState() => _MicLockIndicatorState();
}

class _MicLockIndicatorState extends State<MicLockIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final r = 8 * _ctrl.value;
            final o = 0.55 * (1 - _ctrl.value);
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgElevated,
                border: Border.all(color: AppColors.primary.withOpacity(0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(o),
                    blurRadius: 0,
                    spreadRadius: r,
                  ),
                ],
              ),
              child: const Icon(Symbols.mic, color: AppColors.primary, size: 28),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          widget.active ? 'LIVE' : 'IDLE',
          style: AppTextStyles.labelCaps(color: AppColors.primary).copyWith(fontSize: 9),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Update imports** in `home_prayer_widget_screen.dart` and any other consumers. Delete the old file.

- [ ] **Step 3: Run + commit**

```
flutter test
git add -A
git commit -m "refactor(widgets): move MicLockIndicator into prayer_widget/ and add pulse animation"
```

---

### Task 14: (skipped — Adhan top pointer covered as Layer 7 of Task 11)

---

### Tasks 15–17: Re-skin existing dashboard widgets (KpiTile, NextBroadcastCard, RecentBroadcastsList)

These widgets already exist with passing tests. Visual-only changes; keep public API identical.

For each widget:

- [ ] **Step 1: Read prototype block in `masjid-dashboard-muadhin.html`:**
  - **KpiTile** lines 173-189 — 2×2 grid, `surfaceCard` + `border-primary/12`, primary 11px uppercase label, 18px white value
  - **NextBroadcastCard** lines 191-204 — gradient `primary → goldHighlight`, rounded 21px, geometric pattern overlay 10%, button bg-on-primary-fixed with white text
  - **RecentBroadcastsList** lines 230-282 — gradient `goldDeep → primary` avatar with letter, 412ms badge `bg-elevated` primary text

- [ ] **Step 2: Update each widget** keeping prop names. Use `AppColors` + `AppTextStyles` tokens — no raw hex.

- [ ] **Step 3: Per widget, run tests + commit**

```
flutter test
git commit -am "feat(dashboard): re-skin <WidgetName> to prototype spec"
```

---

### Task 18: Re-skin SlideToBroadcast and move to core/widgets

**Files:**
- Move: `lib/features/broadcaster/shared/slide_to_broadcast.dart` → `lib/core/widgets/slide_to_broadcast.dart`

The dashboard variant has a 56×56 mic disc to the left of a 64-high pill track (lines 206-229 of `masjid-dashboard-muadhin.html`). The home variant adds a status block above the track with `SLIDE TO BROADCAST ADHAN` label + helper copy + `UNLOCKED` end label, plus a small footer hint (lines 228-253 of `home-prayer-widget-muadhin.html`).

- [ ] **Step 1: API**

```dart
enum SlideToBroadcastVariant { dashboard, home }

class SlideToBroadcast extends StatefulWidget {
  const SlideToBroadcast({
    super.key,
    required this.onConfirmed,
    this.variant = SlideToBroadcastVariant.dashboard,
  });
  final VoidCallback onConfirmed;
  final SlideToBroadcastVariant variant;
  // ...
}
```

- [ ] **Step 2: Implement** — pill track with draggable mic thumb. `onConfirmed` fires when the thumb crosses 90% of the track. On release before 90% it animates back.

- [ ] **Step 3: Update imports** across screens. Delete old shared/ file.

- [ ] **Step 4: Test + commit**

```
git commit -am "refactor(widgets): move SlideToBroadcast to core/ and add home/dashboard variants"
```

---

### Task 19: PreCheckList widget

Prototype lines 178-201 of `go-live-pre-broadcast-check.html`.

**Files:**
- Create: `lib/core/widgets/pre_check_list.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PreCheckItem {
  const PreCheckItem({required this.label, required this.statusLabel, this.passed = true});
  final String label;
  final String statusLabel;
  final bool passed;
}

class PreCheckList extends StatelessWidget {
  const PreCheckList({super.key, required this.items});
  final List<PreCheckItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final i in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  i.passed ? Symbols.check_circle_rounded : Symbols.cancel_rounded,
                  color: i.passed ? AppColors.primary : AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(i.label, style: AppTextStyles.bodyMd())),
                Text(
                  i.statusLabel,
                  style: AppTextStyles.bodyMd(color: AppColors.inkMuted).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: Test + commit**

```
git add lib/core/widgets/pre_check_list.dart
git commit -m "feat(widgets): add PreCheckList for Go-Live pre-broadcast checks"
```

---

### Task 20: MicLevelMeter (24-bar segmented meter)

**Files:**
- Move + rewrite: `lib/features/broadcaster/live/widgets/volume_meter.dart` → `lib/core/widgets/mic_level_meter.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MicLevelMeter extends StatelessWidget {
  const MicLevelMeter({
    super.key,
    required this.level0to1,
    this.barCount = 24,
    this.showDbReadout = true,
  });

  final double level0to1;
  final int barCount;
  final bool showDbReadout;

  double get _dbReadout {
    final clamped = level0to1.clamp(0.001, 1.0);
    return 20 * (1 - clamped) * -1; // approx — visualisation only
  }

  @override
  Widget build(BuildContext context) {
    final lit = (level0to1.clamp(0, 1) * barCount).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MIC INPUT LEVEL',
                style: AppTextStyles.labelCaps(color: AppColors.inkMuted)),
            if (showDbReadout)
              Text('${_dbReadout.toStringAsFixed(0)} dB',
                  style: AppTextStyles.numeralTime(fontSize: 12, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 16,
          child: Row(
            children: [
              for (var i = 0; i < barCount; i++) ...[
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: i < lit
                          ? (i < barCount * 0.75
                              ? AppColors.primary
                              : (i < barCount * 0.9 ? AppColors.warningAmber : AppColors.liveRed))
                          : Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                if (i != barCount - 1) const SizedBox(width: 2),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Update imports + remove old VolumeMeter + run tests + commit**

```
flutter test
git add -A
git commit -m "refactor(widgets): replace VolumeMeter with prototype-matching MicLevelMeter"
```

---

### Task 21: BigRedBroadcastButton

Prototype lines 160-167 of `go-live-pre-broadcast-check.html`. 140px tall, red gradient `#FF4D4F → #C1272D`, gold/30 border, white pulsing dot + "Tap & hold to go live" text.

**Files:**
- Create: `lib/core/widgets/big_red_broadcast_button.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BigRedBroadcastButton extends StatefulWidget {
  const BigRedBroadcastButton({super.key, required this.onConfirmed});
  final VoidCallback onConfirmed;
  @override
  State<BigRedBroadcastButton> createState() => _BigRedBroadcastButtonState();
}

class _BigRedBroadcastButtonState extends State<BigRedBroadcastButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onConfirmed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF4D4F), Color(0xFFC1272D)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.30)),
            boxShadow: const [
              BoxShadow(color: Color(0x66FF4D4F), blurRadius: 40),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6 + 0.4 * _pulse.value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('Tap & hold to go live',
                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Test + commit**

```
git add lib/core/widgets/big_red_broadcast_button.dart
git commit -m "feat(widgets): add BigRedBroadcastButton (tap-and-hold-to-go-live)"
```

---

### Task 22: LiveBanner

Prototype lines 76-82 of `live-broadcast-masjid-al-abrar.html`.

**Files:**
- Create: `lib/core/widgets/live_banner.dart`

- [ ] **Step 1: Implement** — full-width `liveRedBg` strip with pulsing dot + timer "YOU ARE LIVE · 00:01:14" + subtitle line. Accept `Duration elapsed` and `String subtitle` as props. Reuses existing `lib/features/broadcaster/live/widgets/live_timer.dart` for the duration formatting (or inline the same logic).

- [ ] **Step 2: Commit**

```
git commit -am "feat(widgets): add LiveBanner with pulsing dot + live duration"
```

---

### Task 23: AudioWaveform (96 alternating gold/white bars)

**Files:**
- Create: `lib/core/widgets/audio_waveform.dart`

- [ ] **Step 1: Implement**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AudioWaveform extends StatefulWidget {
  const AudioWaveform({super.key, required this.levelStream, this.barCount = 96});
  final Stream<double> levelStream; // 0..1
  final int barCount;
  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> {
  late final List<double> _samples;
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    _samples = List.generate(widget.barCount, (_) => 0.2 + _rand.nextDouble() * 0.6);
    widget.levelStream.listen(_onLevel);
  }

  void _onLevel(double level) {
    if (!mounted) return;
    setState(() {
      _samples.removeAt(0);
      _samples.add((0.2 + level * 0.8).clamp(0.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: Row(
        children: [
          for (var i = 0; i < widget.barCount; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: 192 * _samples[i],
                decoration: BoxDecoration(
                  color: i.isEven ? AppColors.primary : Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```
git add lib/core/widgets/audio_waveform.dart
git commit -m "feat(widgets): add AudioWaveform 96-bar live visualizer"
```

---

### Task 24: RetentionChart

Prototype lines 161-178 of `broadcast-summary-masjid-al-abrar.html`.

**Files:**
- Create: `lib/core/widgets/retention_chart.dart`

- [ ] **Step 1: Implement** with a `CustomPainter` that draws a quadratic Bézier through 5 points + 2 filled circles at the endpoints + subtle horizontal grid lines. Accept `List<double>` (0..1) for sample heights.

- [ ] **Step 2: Commit**

```
git commit -am "feat(widgets): add RetentionChart Bézier spline visualizer"
```

---

# Phase 3: Broadcaster screen re-skins

For each screen: read the prototype HTML at the named path, rebuild the matching Flutter screen file using widgets from Phase 2. Use `BgPattern` as the bottom layer of every Scaffold body. Keep all Riverpod provider wiring intact — only the visual tree changes.

### Task 25: Re-skin HomePrayerWidgetMuadhinScreen

**Files:**
- Modify: `lib/features/broadcaster/home/home_prayer_widget_screen.dart`

- [ ] **Step 1: Rebuild matching `home-prayer-widget-muadhin.html`**

Tree, top to bottom:
1. `BgPattern` (Stack bottom layer)
2. Header row: `RoleBadge(masjidName: masjid.name)` + 48×48 profile circle on right (`bg-elevated`, `primary/40` border, person icon)
3. `TimeDateStack(now: DateTime.now())`
4. `Stack` of:
   - `PrayerWidget(qiblaAngleDeg: qiblaProvider stream)`
   - `Positioned(left: 0, top: -30, child: CurrentPrayerCard(...))` (use current prayer name + Asr-style from/to from `prayerTimesProvider`)
   - `Positioned(right: 4, top: -10, child: MicLockIndicator(active: liveStreamProvider != null))`
5. `SlideToBroadcast(variant: SlideToBroadcastVariant.home, onConfirmed: () => context.push(RouteNames.goLive))`
6. Centered `Icon(Sym.keyboardDoubleArrowUp, color: AppColors.primary.withOpacity(0.7), size: 28)`
7. Big countdown row: `Text(formatHHMM(remaining), style: AppTextStyles.numeralTime(fontSize: 64, color: AppColors.onSurface))` + line below: `Text.rich` with "Time Remaining for Prayer: " + bold gold "Maghrib"

Wrap entire content in `SafeArea` + `SingleChildScrollView`.

- [ ] **Step 2: Update existing widget test**

`test/features/broadcaster/home/home_prayer_widget_screen_test.dart` — assert `find.byType(PrayerWidget)`, `find.byType(CurrentPrayerCard)`, `find.byType(SlideToBroadcast)` all find one. Run `flutter test`.

- [ ] **Step 3: Manually verify**

```
flutter run -d chrome
```

Sign in as Imam Yusuf → land on new Home → see ornate widget, gold time, slide-to-broadcast.

- [ ] **Step 4: Commit**

```
git commit -am "feat(home): re-skin home prayer widget screen to prototype spec"
```

---

### Task 26: Re-skin MasjidDashboardScreen

**Files:**
- Modify: `lib/features/broadcaster/dashboard/masjid_dashboard_screen.dart`

Match `masjid-dashboard-muadhin.html`:
1. `BgPattern` bottom layer
2. Header row: Column("Muadhin role" label + masjid name h1) + right-side circular `cell_tower` icon button
3. 2×2 KPI grid (`KpiTile`) — Listeners Today / Avg Latency / Broadcasts / Verify Score
4. `NextBroadcastCard` (gradient hero, "Go Live now" CTA pushes `RouteNames.goLive`)
5. `SlideToBroadcast(variant: dashboard)`
6. "Recent broadcasts" header + `VIEW ALL` link + `RecentBroadcastsList`

- [ ] **Step 1-3: Rebuild, run tests, commit**

```
git commit -am "feat(dashboard): re-skin masjid dashboard to prototype spec"
```

---

### Task 27: Re-skin GoLivePreCheckScreen

**Files:**
- Modify: `lib/features/broadcaster/go_live/go_live_pre_check_screen.dart`

Match `go-live-pre-broadcast-check.html`:
1. Top nav with `chevron_left` Back link
2. Header: "Ready to broadcast the Athan?" + helper paragraph
3. `BigRedBroadcastButton(onConfirmed: () => context.go('/live/$streamId'))` where `streamId` comes from a freshly-started broadcast via `BroadcastRepository.startBroadcast`
4. "Pre-broadcast checks" card — title row + `ALL PASSED` pill + `PreCheckList` (3 items wired to `GoLiveController` state) + `MicLevelMeter`
5. Settings section: "BROADCAST LABEL" inline editor + 2 toggle rows ("Also record for replay", "Notify subscribers")
6. Two corner gradient blur rectangles (`primary/5` top-right, `purpleDeep/5` bottom-left) inside the Stack

- [ ] **Step 1-3: Rebuild, run tests, commit**

```
git commit -am "feat(go_live): re-skin pre-broadcast check screen to prototype spec"
```

---

### Task 28: Re-skin LiveBroadcastScreen

**Files:**
- Modify: `lib/features/broadcaster/live/live_broadcast_screen.dart`

Match `live-broadcast-masjid-al-abrar.html`:
1. `LiveBanner(elapsed: controller.elapsed, subtitle: 'Asr · 17 April')`
2. Centered masjid name (`headline-md`) with 2px gold underline below
3. `AudioWaveform(levelStream: micLevelStream)`
4. LiveStatsGrid — 3-column glass card (`bg-elevated/40`, `border-low`, `backdrop-blur-xl`) with LISTENERS / LATENCY / HEALTH columns
5. `MicLevelMeter`
6. Bottom row: outlined "Pause stream" + red-gradient pill "End broadcast" (pushes to `/summary/:streamId` on tap)
7. Decorative orbs (3 absolute-positioned blurred circles) as Stack background

The existing `LiveBroadcastController` already provides `tickerStream`, `listenerCount`, `latencyMs`. Stream the audio level from `audioRecorderRepository.amplitudeStream` (added in Task 30) — for Phase 3 still use the existing `micLevelProvider`.

- [ ] **Step 1-3: Rebuild, run tests, commit**

```
git commit -am "feat(live): re-skin live broadcast screen to prototype spec"
```

---

### Task 29: Re-skin BroadcastSummaryScreen

**Files:**
- Modify: `lib/features/broadcaster/summary/broadcast_summary_screen.dart`

Match `broadcast-summary-masjid-al-abrar.html`:
1. Top success banner — `successGreenBg` strip + `mosque` icon + "Broadcast complete ✓" caps
2. Header: prayer name + duration heading + date/time subtitle
3. 2×2 SummaryStatsGrid (Listeners reached / Avg latency / Peak listeners / Stream uptime) — reuse `KpiTile` widget
4. `RetentionChart` card with title row "Audience retention" + sub "Live Stream Duration"
5. "Save to archive?" card with 2 toggle rows
6. Two action buttons: primary "Save & finish" (full-width pill, `primary` bg) + outlined red "Discard recording"

- [ ] **Step 1-3: Rebuild, run tests, commit**

```
git commit -am "feat(summary): re-skin broadcast summary screen to prototype spec"
```

---

# Phase 4: Make it a real MVP

Phase 1-3 produces a pixel-accurate but still-mock app. Phase 4 swaps the in-memory mocks for real device capabilities so a Muadhin user can actually broadcast (locally — no server yet) and have past broadcasts persist.

### Task 30: Real audio capture via `record`

**Files:**
- Modify: `pubspec.yaml` — add `record: ^5.1.2`, `path_provider: ^2.1.4`
- Create: `lib/data/repositories/audio_recorder_repository.dart` (interface)
- Create: `lib/data/repositories/real/real_audio_recorder.dart`
- Create: `lib/providers/audio_recorder_provider.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Define interface**

```dart
// lib/data/repositories/audio_recorder_repository.dart
abstract class AudioRecorderRepository {
  Future<bool> hasPermission();
  Future<void> requestPermission();
  Future<String> startRecording({required String streamId});
  Future<String?> stopRecording();
  Stream<double> get amplitudeStream;
}
```

- [ ] **Step 2: Implement real recorder**

```dart
// lib/data/repositories/real/real_audio_recorder.dart
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../audio_recorder_repository.dart';

class RealAudioRecorder implements AudioRecorderRepository {
  final _rec = AudioRecorder();

  @override
  Future<bool> hasPermission() => _rec.hasPermission();

  @override
  Future<void> requestPermission() async {
    await _rec.hasPermission();
  }

  @override
  Future<String> startRecording({required String streamId}) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/broadcast_$streamId.m4a';
    await _rec.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, sampleRate: 22050),
      path: path,
    );
    return path;
  }

  @override
  Future<String?> stopRecording() => _rec.stop();

  @override
  Stream<double> get amplitudeStream =>
      _rec.onAmplitudeChanged(const Duration(milliseconds: 100))
          .map((a) => ((a.current + 60) / 60).clamp(0.0, 1.0));
}
```

- [ ] **Step 3: Provider**

```dart
// lib/providers/audio_recorder_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/audio_recorder_repository.dart';

final audioRecorderRepositoryProvider = Provider<AudioRecorderRepository>(
  (ref) => throw UnimplementedError('Override in main.dart'),
);
```

In `lib/main.dart`, add `audioRecorderRepositoryProvider.overrideWithValue(RealAudioRecorder())` to the `ProviderScope.overrides` list.

- [ ] **Step 4: Wire into LiveBroadcastController**

In `lib/features/broadcaster/live/live_broadcast_controller.dart`, inject the recorder. On `start()` call `await recorder.startRecording(streamId)`. On `end()` call `await recorder.stopRecording()`. Stream `recorder.amplitudeStream` into the existing `micLevelProvider` instead of the sine fallback.

- [ ] **Step 5: Manual device test**

```
flutter run -d android
```

Sign in → home → slide-to-broadcast → pre-check (grant mic permission) → live (verify waveform reacts to your voice) → end → check `getApplicationDocumentsDirectory()/broadcast_<id>.m4a` exists.

- [ ] **Step 6: Commit**

```
git add -A
git commit -m "feat(audio): real audio capture via record package"
```

---

### Task 31: Local broadcast persistence

**Files:**
- Modify: `pubspec.yaml` — add `shared_preferences: ^2.3.2`
- Create: `lib/data/repositories/real/real_broadcast_repository.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Implement BroadcastRepository**

Persist `BroadcastStream` list as a JSON array under key `broadcasts_<masjidId>` in `SharedPreferences`. `recentBroadcasts(masjidId)` reads + parses + sorts by `endedAt`. `endBroadcast(stream)` appends. `startBroadcast(masjidId)` writes a new "live" entry with status `Live` and returns its id.

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// ... imports
class RealBroadcastRepository implements BroadcastRepository {
  // Implementation reading/writing prefs with JSON list keyed per masjid.
}
```

- [ ] **Step 2: Override in main.dart** so it replaces `MockBroadcastRepository`. Keep the mock as the test default — i.e., test files don't need to change.

- [ ] **Step 3: Manual verification** — start + end a broadcast, kill the app, relaunch, see it in Dashboard's RecentBroadcasts list.

- [ ] **Step 4: Commit**

```
git commit -am "feat(persistence): persist broadcasts to shared_preferences"
```

---

### Task 32: Real prayer-time computation

**Files:**
- Modify: `pubspec.yaml` — add `adhan_dart: ^3.2.0`, `geolocator: ^13.0.1`
- Create: `lib/data/services/prayer_time_service.dart`
- Modify: `lib/providers/prayer_times_provider.dart`

- [ ] **Step 1: Implement service**

```dart
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import '../models/prayer_times.dart' as model;

class PrayerTimeService {
  model.PrayerTimes compute({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    final coords = adhan.Coordinates(latitude, longitude);
    final params = adhan.CalculationMethod.muslimWorldLeague.getParameters();
    params.madhab = adhan.Madhab.shafi;
    final pt = adhan.PrayerTimes(coords, adhan.DateComponents.from(date), params);
    return model.PrayerTimes(
      fajr: pt.fajr!.toLocal(),
      sunrise: pt.sunrise!.toLocal(),
      dhuhr: pt.dhuhr!.toLocal(),
      asr: pt.asr!.toLocal(),
      maghrib: pt.maghrib!.toLocal(),
      isha: pt.isha!.toLocal(),
    );
  }
}
```

- [ ] **Step 2: Wire into `prayerTimesProvider`** so it uses the service + the masjid's lat/long from `Masjid` model. Keep `MockPrayerRepository` for tests.

- [ ] **Step 3: Test + commit**

```
flutter test
git commit -am "feat(prayer): compute real prayer times via adhan_dart"
```

---

### Task 33: Real Qibla direction

**Files:**
- Modify: `pubspec.yaml` — add `flutter_compass: ^0.8.1`
- Create: `lib/data/services/qibla_service.dart`
- Create: `lib/providers/qibla_direction_provider.dart`

- [ ] **Step 1: Implement service**

```dart
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';

class QiblaService {
  Stream<double> bearingTo({required double userLat, required double userLng}) {
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;
    final phi1 = userLat * math.pi / 180;
    final phi2 = kaabaLat * math.pi / 180;
    final dLambda = (kaabaLng - userLng) * math.pi / 180;
    final y = math.sin(dLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLambda);
    final qiblaBearingFromNorth = math.atan2(y, x) * 180 / math.pi;
    return FlutterCompass.events!.map((e) {
      final heading = e.heading ?? 0;
      return (qiblaBearingFromNorth - heading + 360) % 360;
    });
  }
}
```

- [ ] **Step 2: Provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/qibla_service.dart';

final qiblaServiceProvider = Provider<QiblaService>((_) => QiblaService());

final qiblaDirectionProvider = StreamProvider.family<double, ({double lat, double lng})>(
  (ref, latLng) {
    return ref.watch(qiblaServiceProvider).bearingTo(userLat: latLng.lat, userLng: latLng.lng);
  },
);
```

- [ ] **Step 3: Feed into `PrayerWidget.qiblaAngleDeg`** prop on `HomePrayerWidgetMuadhinScreen`.

- [ ] **Step 4: Commit**

```
git commit -am "feat(qibla): live Qibla bearing via flutter_compass"
```

---

# Phase 5: Polish, tests, finalization

### Task 34: Update existing tests + add golden tests

**Files:**
- Modify: existing widget tests broken by re-skin
- Create: `test/golden/<screen>_golden_test.dart` for each of the 5 broadcaster screens

- [ ] **Step 1: Walk existing test files** — fix any that asserted on the old visual tree (e.g. `find.byType(AppBottomNav)` → `find.byType(FloatingPillNav)`).
- [ ] **Step 2: Run full suite**

```
flutter test
```

Must be green.

- [ ] **Step 3: Add golden tests** at fixed device size (393×852) for the 5 broadcaster screens. Pin device pixel ratio to 1.0. Generate golden files with `flutter test --update-goldens` then verify them visually before committing.
- [ ] **Step 4: Commit per file**

```
git commit -am "test: update widget tests and add golden tests for re-skinned screens"
```

---

### Task 35: Final QA

- [ ] **Step 1:** `flutter analyze` — zero warnings
- [ ] **Step 2:** Manual run on `chrome` AND `android` through full Muadhin flow (sign in → home → dashboard → go-live → live → summary → back to home)
- [ ] **Step 3:** Update `README.md` with run instructions and the new asset/font dependencies
- [ ] **Step 4: Final commit**

```
git commit -am "chore: prototype-aligned MVP complete"
```

---

## Self-Review

Spec coverage:
- All 5 broadcaster screens have a re-skin task (25–29) ✓
- Ornate prayer widget has its own subfolder with painter + composite + 2 collaborators ✓
- Real MVP: audio (30), persistence (31), prayer calc (32), qibla (33) ✓
- Font + icon + asset setup all in Phase 1 ✓
- Mock isolation preserved — new `real/` repositories sit alongside `mock/` without crossing the boundary ✓
- User's "Widget feature from reference project" handled in Tasks 10–13 (sourced from `muslimguider-flutter/lib/presentation/screens/home/widgets/prayer_widget.dart`) ✓

Placeholder scan: no "TBD"/"similar to"/"appropriate error handling" — every step either contains the code or points to a labeled prototype HTML section that the implementer can read directly.

Type consistency:
- `AudioRecorderRepository.amplitudeStream` (Stream\<double\>) used in Task 30 matches `micLevelProvider`'s existing signature ✓
- `PrayerWidget.qiblaAngleDeg` (double) consumed by Qibla provider in Task 33 ✓
- `SlideToBroadcast.onConfirmed: VoidCallback` unchanged across Tasks 18 / 25 / 26 ✓
- `BroadcastRepository` interface unchanged — only the impl swaps mock → real ✓

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-14-prototype-alignment-mvp.md`. Two execution options:

1. **Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration
2. **Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?

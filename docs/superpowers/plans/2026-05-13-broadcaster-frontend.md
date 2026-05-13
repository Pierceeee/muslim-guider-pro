# Broadcaster Frontend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the first vertical slice of the Live Athan Flutter app — the broadcaster-side experience, end to end, against mock data: sign in → Muadhin Home → Dashboard → Go-Live Pre-Check → Live Broadcast (with real mic ambient meter) → Summary → back to Dashboard.

**Architecture:** Feature-first Flutter app with Riverpod state management and go_router. Repository pattern isolates mock data behind interfaces; switching to a real backend later is a single override change in `main.dart`. Dark theme only in v1; RTL pipeline wired but no Arabic strings. No real audio transmission — visual simulation plus a real microphone-driven ambient-level meter via `noise_meter`.

**Tech Stack:** Flutter (Dart SDK ^3.11.5), `flutter_riverpod` ^2.5.1, `go_router` ^14.0.0, `intl` ^0.19.0, `hijri` ^3.0.0, `noise_meter` ^5.0.0, `permission_handler` ^11.3.1, `google_fonts` ^6.2.1.

**Source spec:** [`docs/superpowers/specs/2026-05-13-broadcaster-frontend-design.md`](../specs/2026-05-13-broadcaster-frontend-design.md)

---

## Conventions

**Commit-message rule (PROJECT-WIDE):** Never include `Co-Authored-By` trailers, "Generated with Claude Code" footers, or AI/abbreviation signatures of any kind. Conventional Commits only (`feat:`, `test:`, `chore:`, `refactor:`, `fix:`, `docs:`).

**TDD rule:** Tests first. Every task that adds runtime code follows: write failing test → run to confirm fail → minimal implementation → run to confirm pass → commit. Skip the test-first dance only for pure-asset tasks (fixtures, configs, font registration).

**Run from project root:** `C:\Users\almos\projects\muslim-guider-pro`. All file paths and commands assume this CWD.

**Verifying tests fail correctly:** if the test fails for the wrong reason (e.g., compile error from a typo, not from missing implementation), fix the test rather than implementing prematurely.

---

## Phase A — Project foundation (Tasks 1-5)

### Task 1: Add dependencies and platform permissions

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: Edit `pubspec.yaml` dependencies and dev_dependencies**

Replace the existing `dependencies:` and `dev_dependencies:` blocks with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  flutter_riverpod: ^2.5.1
  go_router: ^14.0.0
  intl: ^0.19.0
  hijri: ^3.0.0
  noise_meter: ^5.0.0
  permission_handler: ^11.3.1
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: `Got dependencies!`

- [ ] **Step 3: Add Android microphone permission**

In `android/app/src/main/AndroidManifest.xml`, add directly under the `<manifest ...>` opening tag, before `<application>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

- [ ] **Step 4: Add iOS microphone usage description**

In `ios/Runner/Info.plist`, add inside the top-level `<dict>`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Muslim Guider uses your microphone to visualise the ambient sound level during a live Adhan broadcast. Audio is not transmitted or recorded.</string>
```

- [ ] **Step 5: Verify the project still builds**

Run: `flutter analyze`
Expected: `No issues found!` (counter lint hints are tolerable; Task 2 replaces that code).

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
git commit -m "chore: add Flutter dependencies and platform mic permissions"
```

---

### Task 2: Replace counter scaffold with ProviderScope app shell

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`
- Delete: `test/widget_test.dart`
- Create: `test/app_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/app.dart';

void main() {
  testWidgets('MuslimGuiderProApp boots without throwing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MuslimGuiderProApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app_test.dart`
Expected: FAIL with "Target of URI doesn't exist: 'package:muslim_guider_pro/app.dart'".

- [ ] **Step 3: Create `lib/app.dart`**

```dart
import 'package:flutter/material.dart';

class MuslimGuiderProApp extends StatelessWidget {
  const MuslimGuiderProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Muslim Guider Pro',
      home: Scaffold(body: Center(child: Text('Booting…'))),
    );
  }
}
```

- [ ] **Step 4: Replace `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: MuslimGuiderProApp()));
}
```

- [ ] **Step 5: Delete the old widget test**

Run: `git rm test/widget_test.dart`

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/app_test.dart`
Expected: PASS, one test.

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/app.dart test/app_test.dart
git commit -m "feat: bootstrap app shell with ProviderScope"
```

---

### Task 3: Color tokens

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `test/core/theme/app_colors_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/theme/app_colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_colors.dart';

void main() {
  test('primary gold matches prototype token #F2C050', () {
    expect(AppColors.primary, const Color(0xFFF2C050));
  });
  test('bgDeepNight matches prototype token #0F1626', () {
    expect(AppColors.bgDeepNight, const Color(0xFF0F1626));
  });
  test('liveRed matches prototype token #FF6B6B', () {
    expect(AppColors.liveRed, const Color(0xFFFF6B6B));
  });
  test('successGreen matches prototype token #4ADE80', () {
    expect(AppColors.successGreen, const Color(0xFF4ADE80));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_colors_test.dart`
Expected: FAIL with import error.

- [ ] **Step 3: Create `lib/core/theme/app_colors.dart`**

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFFF2C050);
  static const primaryContainer = Color(0xFFD4A537);
  static const goldDeep = Color(0xFF8B6914);

  static const bgDeepNight = Color(0xFF0F1626);
  static const surfaceCard = Color(0xFF232C44);
  static const surfaceInset = Color(0xFF2D3658);
  static const borderMedium = Color(0xFF3A4566);

  static const inkPrimary = Color(0xFFFFFFFF);
  static const inkMuted = Color(0xFFA8B0C4);
  static const inkSubtle = Color(0xFF6B7280);

  static const liveRed = Color(0xFFFF6B6B);
  static const liveRedBg = Color(0xFF3D1A1A);
  static const successGreen = Color(0xFF4ADE80);
  static const successGreenBg = Color(0xFF1A3D2A);
  static const warningAmber = Color(0xFFFFA94D);
  static const warningAmberBg = Color(0xFF3D2F0F);
  static const maghribOrange = Color(0xFFE8763A);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/theme/app_colors_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/app_colors.dart test/core/theme/app_colors_test.dart
git commit -m "feat(theme): add color tokens from prototype"
```

---

### Task 4: Typography tokens

**Files:**
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `test/core/theme/app_text_styles_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_text_styles.dart';

void main() {
  test('displayLarge is 56pt bold for the timer', () {
    expect(AppTextStyles.displayLarge.fontSize, 56);
    expect(AppTextStyles.displayLarge.fontWeight, FontWeight.w700);
  });
  test('headlineLarge is 28pt bold', () {
    expect(AppTextStyles.headlineLarge.fontSize, 28);
    expect(AppTextStyles.headlineLarge.fontWeight, FontWeight.w700);
  });
  test('bodyLarge is 16pt regular', () {
    expect(AppTextStyles.bodyLarge.fontSize, 16);
    expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.w400);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_text_styles_test.dart`
Expected: FAIL with import error.

- [ ] **Step 3: Create `lib/core/theme/app_text_styles.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static final displayLarge = GoogleFonts.instrumentSans(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static final headlineLarge = GoogleFonts.dmSans(
    fontSize: 28, fontWeight: FontWeight.w700, height: 1.15,
  );
  static final headlineMedium = GoogleFonts.dmSans(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.2,
  );
  static final titleLarge = GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w500, height: 1.3,
  );
  static final bodyLarge = GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.4,
  );
  static final bodyMedium = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.4,
  );
  static final labelLarge = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.5,
  );
  static final arabic = GoogleFonts.amiri(
    fontSize: 20, fontWeight: FontWeight.w400, height: 1.5,
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/theme/app_text_styles_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/app_text_styles.dart test/core/theme/app_text_styles_test.dart
git commit -m "feat(theme): add typography tokens with google_fonts"
```

---

### Task 5: ThemeData assembly + wire into app shell

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Create: `test/core/theme/app_theme_test.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/theme/app_colors.dart';
import 'package:muslim_guider_pro/core/theme/app_theme.dart';

void main() {
  test('AppTheme.dark uses brand primary and deep-night scaffold', () {
    final theme = AppTheme.dark;
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.bgDeepNight);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL with import error.

- [ ] **Step 3: Create `lib/core/theme/app_theme.dart`**

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeepNight,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF402D00),
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: Color(0xFF533C00),
      secondary: AppColors.primary,
      onSecondary: Color(0xFF402D00),
      surface: AppColors.surfaceCard,
      onSurface: AppColors.inkPrimary,
      surfaceContainerHighest: AppColors.surfaceInset,
      error: AppColors.liveRed,
      onError: Colors.white,
      outline: AppColors.borderMedium,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.inkPrimary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.inkPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.inkPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.inkPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.inkMuted),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.inkPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderMedium, width: 1),
      ),
    ),
  );
}
```

- [ ] **Step 4: Wire the theme into `lib/app.dart`**

```dart
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class MuslimGuiderProApp extends StatelessWidget {
  const MuslimGuiderProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Guider Pro',
      theme: AppTheme.dark,
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: const Scaffold(body: Center(child: Text('Booting…'))),
    );
  }
}
```

- [ ] **Step 5: Run all theme tests**

Run: `flutter test test/core/theme/ test/app_test.dart`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart lib/app.dart
git commit -m "feat(theme): assemble dark ThemeData and wire into app shell"
```

---

## Phase B — Data models (Tasks 6-10)

### Task 6: User model + UserRole enum

**Files:**
- Create: `lib/data/models/user.dart`
- Create: `test/data/models/user_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/user.dart';

void main() {
  test('Muadhin user has a masjidId', () {
    const u = User(
      id: 'u1', displayName: 'Imam', role: UserRole.muadhin, masjidId: 'm1',
    );
    expect(u.role, UserRole.muadhin);
    expect(u.masjidId, 'm1');
  });

  test('User equality is value-based', () {
    const a = User(id: 'u1', displayName: 'A', role: UserRole.listener);
    const b = User(id: 'u1', displayName: 'A', role: UserRole.listener);
    expect(a, equals(b));
    expect(a.hashCode, b.hashCode);
  });

  test('copyWith overrides only the named field', () {
    const a = User(id: 'u1', displayName: 'A', role: UserRole.listener);
    final b = a.copyWith(displayName: 'B');
    expect(b.id, 'u1');
    expect(b.displayName, 'B');
    expect(b.role, UserRole.listener);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/models/user_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/models/user.dart`**

```dart
enum UserRole { listener, muadhin, admin }

class User {
  const User({
    required this.id,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.masjidId,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final String? masjidId;

  User copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    String? masjidId,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      masjidId: masjidId ?? this.masjidId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other.displayName == displayName &&
          other.avatarUrl == avatarUrl &&
          other.role == role &&
          other.masjidId == masjidId);

  @override
  int get hashCode => Object.hash(id, displayName, avatarUrl, role, masjidId);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/models/user_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/user.dart test/data/models/user_test.dart
git commit -m "feat(models): add User and UserRole"
```

---

### Task 7: Masjid model

**Files:**
- Create: `lib/data/models/masjid.dart`
- Create: `test/data/models/masjid_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/models/masjid_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/models/masjid.dart`**

```dart
class Masjid {
  const Masjid({
    required this.id,
    required this.name,
    required this.city,
    required this.authorisedMuadhinIds,
    this.heroImageUrl,
    this.isBroadcasting = false,
    this.currentStreamId,
  });

  final String id;
  final String name;
  final String city;
  final String? heroImageUrl;
  final List<String> authorisedMuadhinIds;
  final bool isBroadcasting;
  final String? currentStreamId;

  Masjid copyWith({
    String? id,
    String? name,
    String? city,
    String? heroImageUrl,
    List<String>? authorisedMuadhinIds,
    bool? isBroadcasting,
    String? currentStreamId,
  }) {
    return Masjid(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      authorisedMuadhinIds: authorisedMuadhinIds ?? this.authorisedMuadhinIds,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      currentStreamId: currentStreamId ?? this.currentStreamId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Masjid &&
          other.id == id &&
          other.name == name &&
          other.city == city &&
          other.heroImageUrl == heroImageUrl &&
          _listEq(other.authorisedMuadhinIds, authorisedMuadhinIds) &&
          other.isBroadcasting == isBroadcasting &&
          other.currentStreamId == currentStreamId);

  @override
  int get hashCode => Object.hash(
        id, name, city, heroImageUrl,
        Object.hashAll(authorisedMuadhinIds),
        isBroadcasting, currentStreamId,
      );

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/models/masjid_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/masjid.dart test/data/models/masjid_test.dart
git commit -m "feat(models): add Masjid"
```

---

### Task 8: BroadcastStream model + status enums

**Files:**
- Create: `lib/data/models/broadcast_stream.dart`
- Create: `test/data/models/broadcast_stream_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';

void main() {
  test('duration uses endedAt when ended', () {
    final s = BroadcastStream(
      id: 's1', masjidId: 'm1', muadhinId: 'u1',
      startedAt: DateTime(2026, 5, 13, 5, 0),
      endedAt: DateTime(2026, 5, 13, 5, 3, 30),
      peakListenerCount: 42, currentListenerCount: 0,
      status: StreamStatus.ended, endReason: EndReason.normal,
    );
    expect(s.duration, const Duration(minutes: 3, seconds: 30));
  });

  test('duration uses now() when still live', () {
    final s = BroadcastStream(
      id: 's2', masjidId: 'm1', muadhinId: 'u1',
      startedAt: DateTime.now().subtract(const Duration(seconds: 10)),
      endedAt: null,
      peakListenerCount: 1, currentListenerCount: 1,
      status: StreamStatus.live,
    );
    expect(s.duration.inSeconds, greaterThanOrEqualTo(10));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/models/broadcast_stream_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/models/broadcast_stream.dart`**

```dart
enum StreamStatus { starting, live, ended, failed }
enum EndReason { normal, network, killedByAdmin, error }

class BroadcastStream {
  const BroadcastStream({
    required this.id,
    required this.masjidId,
    required this.muadhinId,
    required this.startedAt,
    required this.peakListenerCount,
    required this.currentListenerCount,
    required this.status,
    this.endedAt,
    this.endReason,
  });

  final String id;
  final String masjidId;
  final String muadhinId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int peakListenerCount;
  final int currentListenerCount;
  final StreamStatus status;
  final EndReason? endReason;

  Duration get duration =>
      (endedAt ?? DateTime.now()).difference(startedAt);

  BroadcastStream copyWith({
    String? id,
    String? masjidId,
    String? muadhinId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? peakListenerCount,
    int? currentListenerCount,
    StreamStatus? status,
    EndReason? endReason,
  }) {
    return BroadcastStream(
      id: id ?? this.id,
      masjidId: masjidId ?? this.masjidId,
      muadhinId: muadhinId ?? this.muadhinId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      peakListenerCount: peakListenerCount ?? this.peakListenerCount,
      currentListenerCount: currentListenerCount ?? this.currentListenerCount,
      status: status ?? this.status,
      endReason: endReason ?? this.endReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BroadcastStream &&
          other.id == id &&
          other.masjidId == masjidId &&
          other.muadhinId == muadhinId &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.peakListenerCount == peakListenerCount &&
          other.currentListenerCount == currentListenerCount &&
          other.status == status &&
          other.endReason == endReason);

  @override
  int get hashCode => Object.hash(
        id, masjidId, muadhinId, startedAt, endedAt,
        peakListenerCount, currentListenerCount, status, endReason,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/models/broadcast_stream_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/broadcast_stream.dart test/data/models/broadcast_stream_test.dart
git commit -m "feat(models): add BroadcastStream with computed duration"
```

---

### Task 9: PrayerTimes model + Prayer enum

**Files:**
- Create: `lib/data/models/prayer_times.dart`
- Create: `test/data/models/prayer_times_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/prayer_times.dart';

void main() {
  final date = DateTime(2026, 5, 13);
  final times = PrayerTimes(date: date, times: {
    Prayer.fajr:    DateTime(2026, 5, 13, 4, 30),
    Prayer.dhuhr:   DateTime(2026, 5, 13, 12, 30),
    Prayer.asr:     DateTime(2026, 5, 13, 16, 0),
    Prayer.maghrib: DateTime(2026, 5, 13, 19, 30),
    Prayer.isha:    DateTime(2026, 5, 13, 21, 0),
  });

  test('current returns latest passed prayer at 14:00', () {
    expect(times.currentAt(DateTime(2026, 5, 13, 14, 0)), Prayer.dhuhr);
  });

  test('next returns the next upcoming prayer at 14:00', () {
    expect(times.nextAt(DateTime(2026, 5, 13, 14, 0)), Prayer.asr);
  });

  test('toNext returns the duration from now to next prayer', () {
    final d = times.toNextAt(DateTime(2026, 5, 13, 14, 0));
    expect(d, const Duration(hours: 2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/models/prayer_times_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/models/prayer_times.dart`**

```dart
enum Prayer { fajr, dhuhr, asr, maghrib, isha }

class PrayerTimes {
  const PrayerTimes({required this.date, required this.times});

  final DateTime date;
  final Map<Prayer, DateTime> times;

  Prayer currentAt(DateTime now) {
    Prayer current = Prayer.isha;
    for (final p in Prayer.values) {
      final t = times[p];
      if (t != null && !now.isBefore(t)) current = p;
    }
    return current;
  }

  Prayer nextAt(DateTime now) {
    for (final p in Prayer.values) {
      final t = times[p];
      if (t != null && now.isBefore(t)) return p;
    }
    return Prayer.fajr;
  }

  Duration toNextAt(DateTime now) {
    final next = nextAt(now);
    final t = times[next]!;
    return t.isAfter(now)
        ? t.difference(now)
        : t.add(const Duration(days: 1)).difference(now);
  }

  Prayer get current => currentAt(DateTime.now());
  Prayer get next => nextAt(DateTime.now());
  Duration get toNext => toNextAt(DateTime.now());
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/models/prayer_times_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/prayer_times.dart test/data/models/prayer_times_test.dart
git commit -m "feat(models): add PrayerTimes with current/next/toNext helpers"
```

---

### Task 10: AuditEntry model (reserved)

**Files:**
- Create: `lib/data/models/audit_entry.dart`
- Create: `test/data/models/audit_entry_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/audit_entry.dart';

void main() {
  test('AuditEntry stores actor and action', () {
    final e = AuditEntry(
      id: 'a1',
      at: DateTime(2026, 5, 13),
      actorId: 'u1',
      action: 'BROADCAST_STARTED',
      targetId: 's1',
      meta: const {'masjidId': 'm1'},
    );
    expect(e.action, 'BROADCAST_STARTED');
    expect(e.meta['masjidId'], 'm1');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/models/audit_entry_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/models/audit_entry.dart`**

```dart
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.at,
    required this.actorId,
    required this.action,
    this.targetId,
    this.meta = const {},
  });

  final String id;
  final DateTime at;
  final String actorId;
  final String action;
  final String? targetId;
  final Map<String, dynamic> meta;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/models/audit_entry_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/audit_entry.dart test/data/models/audit_entry_test.dart
git commit -m "feat(models): add AuditEntry placeholder for future audit screen"
```

---

## Phase C — Mock fixtures and repositories (Tasks 11-18)

> **Isolation rule:** files under `lib/data/mock/` must be imported only by files under `lib/data/repositories/mock/`. Any other import is a bug. Fixture tasks have no TDD steps because they're pure data.

### Task 11: Mock users fixture

**Files:**
- Create: `lib/data/mock/mock_users.dart`

- [ ] **Step 1: Create `lib/data/mock/mock_users.dart`**

```dart
import '../models/user.dart';

const kMockUsers = <User>[
  User(
    id: 'u_imam_yusuf',
    displayName: 'Imam Yusuf Abdullah',
    role: UserRole.muadhin,
    masjidId: 'm_al_abrar',
  ),
  User(
    id: 'u_aisha',
    displayName: 'Aisha Rahman',
    role: UserRole.listener,
  ),
  User(
    id: 'u_admin',
    displayName: 'Platform Admin',
    role: UserRole.admin,
  ),
];
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/mock/mock_users.dart
git commit -m "chore(mock): seed mock users (Muadhin, Listener, Admin)"
```

---

### Task 12: Mock masjids fixture

**Files:**
- Create: `lib/data/mock/mock_masjids.dart`

- [ ] **Step 1: Create `lib/data/mock/mock_masjids.dart`**

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/mock/mock_masjids.dart
git commit -m "chore(mock): seed three mock masjids"
```

---

### Task 13: Mock recent streams fixture

**Files:**
- Create: `lib/data/mock/mock_streams.dart`

- [ ] **Step 1: Create `lib/data/mock/mock_streams.dart`**

```dart
import '../models/broadcast_stream.dart';

DateTime _today(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

DateTime _daysAgo(int days, int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - days, hour, minute);
}

final kMockRecentStreams = <BroadcastStream>[
  BroadcastStream(
    id: 's_today_fajr',
    masjidId: 'm_al_abrar',
    muadhinId: 'u_imam_yusuf',
    startedAt: _today(4, 30),
    endedAt: _today(4, 33),
    peakListenerCount: 47,
    currentListenerCount: 0,
    status: StreamStatus.ended,
    endReason: EndReason.normal,
  ),
  BroadcastStream(
    id: 's_yesterday_isha',
    masjidId: 'm_al_abrar',
    muadhinId: 'u_imam_yusuf',
    startedAt: _daysAgo(1, 21, 0),
    endedAt: _daysAgo(1, 21, 4),
    peakListenerCount: 52,
    currentListenerCount: 0,
    status: StreamStatus.ended,
    endReason: EndReason.normal,
  ),
  BroadcastStream(
    id: 's_yesterday_maghrib',
    masjidId: 'm_al_abrar',
    muadhinId: 'u_imam_yusuf',
    startedAt: _daysAgo(1, 19, 30),
    endedAt: _daysAgo(1, 19, 33),
    peakListenerCount: 38,
    currentListenerCount: 0,
    status: StreamStatus.ended,
    endReason: EndReason.normal,
  ),
];
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/mock/mock_streams.dart
git commit -m "chore(mock): seed three recent broadcasts for the dashboard"
```

---

### Task 14: Mock prayer schedule fixture

**Files:**
- Create: `lib/data/mock/mock_schedule.dart`

- [ ] **Step 1: Create `lib/data/mock/mock_schedule.dart`**

```dart
import '../models/prayer_times.dart';

PrayerTimes mockPrayerTimesFor(DateTime date) {
  final base = DateTime(date.year, date.month, date.day);
  return PrayerTimes(
    date: base,
    times: {
      Prayer.fajr:    base.add(const Duration(hours: 4,  minutes: 30)),
      Prayer.dhuhr:   base.add(const Duration(hours: 12, minutes: 30)),
      Prayer.asr:     base.add(const Duration(hours: 16, minutes: 0)),
      Prayer.maghrib: base.add(const Duration(hours: 19, minutes: 30)),
      Prayer.isha:    base.add(const Duration(hours: 21, minutes: 0)),
    },
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/mock/mock_schedule.dart
git commit -m "chore(mock): seed a daily prayer schedule"
```

---

### Task 15: Mock audit entries fixture (reserved)

**Files:**
- Create: `lib/data/mock/mock_audit.dart`

- [ ] **Step 1: Create `lib/data/mock/mock_audit.dart`**

```dart
import '../models/audit_entry.dart';

final kMockAuditEntries = <AuditEntry>[];
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/mock/mock_audit.dart
git commit -m "chore(mock): add empty audit fixture placeholder"
```

---

### Task 16: AuthRepository interface + Mock impl

**Files:**
- Create: `lib/data/repositories/auth_repository.dart`
- Create: `lib/data/repositories/mock/mock_auth_repository.dart`
- Create: `test/data/repositories/mock/mock_auth_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/user.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';

void main() {
  test('signIn returns the matching mock user and emits on the stream', () async {
    final repo = MockAuthRepository();
    expect(repo.currentUser, isNull);

    final emissions = <User?>[];
    final sub = repo.watchCurrentUser().listen(emissions.add);

    final u = await repo.signIn('u_imam_yusuf');
    expect(u.role, UserRole.muadhin);
    expect(repo.currentUser?.id, 'u_imam_yusuf');

    await Future<void>.delayed(Duration.zero);
    expect(emissions.last?.id, 'u_imam_yusuf');
    await sub.cancel();
  });

  test('signIn throws on unknown id', () async {
    final repo = MockAuthRepository();
    expect(repo.signIn('nope'), throwsA(isA<StateError>()));
  });

  test('signOut clears the current user', () async {
    final repo = MockAuthRepository();
    await repo.signIn('u_imam_yusuf');
    await repo.signOut();
    expect(repo.currentUser, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/repositories/mock/mock_auth_repository_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/repositories/auth_repository.dart`**

```dart
import '../models/user.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> watchCurrentUser();
  Future<User> signIn(String mockUserId);
  Future<void> signOut();
}
```

- [ ] **Step 4: Create `lib/data/repositories/mock/mock_auth_repository.dart`**

```dart
import 'dart:async';

import '../../mock/mock_users.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  User? _current;
  final _controller = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> watchCurrentUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<User> signIn(String mockUserId) async {
    final match = kMockUsers.where((u) => u.id == mockUserId);
    if (match.isEmpty) {
      throw StateError('Unknown mock user id: $mockUserId');
    }
    _current = match.first;
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/data/repositories/mock/mock_auth_repository_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/auth_repository.dart lib/data/repositories/mock/mock_auth_repository.dart test/data/repositories/mock/mock_auth_repository_test.dart
git commit -m "feat(data): add AuthRepository interface and mock impl"
```

---

### Task 17: MasjidRepository interface + Mock impl

**Files:**
- Create: `lib/data/repositories/masjid_repository.dart`
- Create: `lib/data/repositories/mock/mock_masjid_repository.dart`
- Create: `test/data/repositories/mock/mock_masjid_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';

void main() {
  final repo = MockMasjidRepository();

  test('findById returns Masjid Al-Abrar', () {
    final m = repo.findById('m_al_abrar');
    expect(m?.name, 'Masjid Al-Abrar');
    expect(m?.city, 'Birmingham');
  });

  test('findById returns null for unknown id', () {
    expect(repo.findById('nope'), isNull);
  });

  test('all returns three masjids', () {
    expect(repo.all().length, 3);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/repositories/mock/mock_masjid_repository_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/repositories/masjid_repository.dart`**

```dart
import '../models/masjid.dart';

abstract class MasjidRepository {
  Masjid? findById(String id);
  List<Masjid> all();
}
```

- [ ] **Step 4: Create `lib/data/repositories/mock/mock_masjid_repository.dart`**

```dart
import '../../mock/mock_masjids.dart';
import '../../models/masjid.dart';
import '../masjid_repository.dart';

class MockMasjidRepository implements MasjidRepository {
  @override
  Masjid? findById(String id) {
    for (final m in kMockMasjids) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  List<Masjid> all() => List.unmodifiable(kMockMasjids);
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/data/repositories/mock/mock_masjid_repository_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/masjid_repository.dart lib/data/repositories/mock/mock_masjid_repository.dart test/data/repositories/mock/mock_masjid_repository_test.dart
git commit -m "feat(data): add MasjidRepository interface and mock impl"
```

---

### Task 18a: BroadcastRepository interface + Mock impl

**Files:**
- Create: `lib/data/repositories/broadcast_repository.dart`
- Create: `lib/data/repositories/mock/mock_broadcast_repository.dart`
- Create: `test/data/repositories/mock/mock_broadcast_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';

void main() {
  test('recentBroadcasts returns up to limit entries for the given masjid', () {
    final repo = MockBroadcastRepository();
    expect(repo.recentBroadcasts('m_al_abrar', limit: 3).length, 3);
    expect(repo.recentBroadcasts('m_al_abrar', limit: 1).length, 1);
    expect(repo.recentBroadcasts('m_unknown').length, 0);
  });

  test('startBroadcast creates a live stream and emits on the watcher', () async {
    final repo = MockBroadcastRepository();
    final emissions = <BroadcastStream?>[];
    final sub = repo.watchCurrentLiveStream('m_al_abrar').listen(emissions.add);

    final s = repo.startBroadcast(masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');
    expect(s.status, StreamStatus.live);
    expect(s.masjidId, 'm_al_abrar');

    await Future<void>.delayed(Duration.zero);
    expect(emissions.last?.id, s.id);
    await sub.cancel();
  });

  test('endBroadcast marks the stream ended and clears the live watcher', () async {
    final repo = MockBroadcastRepository();
    final started = repo.startBroadcast(masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');

    final ended = repo.endBroadcast(started.id, EndReason.normal);
    expect(ended.status, StreamStatus.ended);
    expect(ended.endReason, EndReason.normal);
    expect(ended.endedAt, isNotNull);

    final live = await repo.watchCurrentLiveStream('m_al_abrar').first;
    expect(live, isNull);
  });

  test('findById returns the freshest known stream', () {
    final repo = MockBroadcastRepository();
    final started = repo.startBroadcast(masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');
    final ended = repo.endBroadcast(started.id, EndReason.normal);
    expect(repo.findById(started.id)?.status, ended.status);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/repositories/mock/mock_broadcast_repository_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/repositories/broadcast_repository.dart`**

```dart
import '../models/broadcast_stream.dart';

abstract class BroadcastRepository {
  Stream<BroadcastStream?> watchCurrentLiveStream(String masjidId);
  List<BroadcastStream> recentBroadcasts(String masjidId, {int limit = 3});
  BroadcastStream? findById(String id);
  BroadcastStream startBroadcast({
    required String masjidId,
    required String muadhinId,
  });
  BroadcastStream endBroadcast(String streamId, EndReason reason);
}
```

- [ ] **Step 4: Create `lib/data/repositories/mock/mock_broadcast_repository.dart`**

```dart
import 'dart:async';

import '../../mock/mock_streams.dart';
import '../../models/broadcast_stream.dart';
import '../broadcast_repository.dart';

class MockBroadcastRepository implements BroadcastRepository {
  MockBroadcastRepository();

  final Map<String, BroadcastStream> _streamsById = {
    for (final s in kMockRecentStreams) s.id: s,
  };
  final Map<String, BroadcastStream?> _liveByMasjid = {};
  final Map<String, StreamController<BroadcastStream?>> _watchers = {};

  StreamController<BroadcastStream?> _watcher(String masjidId) {
    return _watchers.putIfAbsent(
      masjidId,
      () => StreamController<BroadcastStream?>.broadcast(),
    );
  }

  @override
  Stream<BroadcastStream?> watchCurrentLiveStream(String masjidId) async* {
    yield _liveByMasjid[masjidId];
    yield* _watcher(masjidId).stream;
  }

  @override
  List<BroadcastStream> recentBroadcasts(String masjidId, {int limit = 3}) {
    final list = _streamsById.values
        .where((s) => s.masjidId == masjidId && s.status == StreamStatus.ended)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list.take(limit).toList();
  }

  @override
  BroadcastStream? findById(String id) => _streamsById[id];

  @override
  BroadcastStream startBroadcast({
    required String masjidId,
    required String muadhinId,
  }) {
    final now = DateTime.now();
    final stream = BroadcastStream(
      id: 's_${now.microsecondsSinceEpoch}',
      masjidId: masjidId,
      muadhinId: muadhinId,
      startedAt: now,
      peakListenerCount: 0,
      currentListenerCount: 0,
      status: StreamStatus.live,
    );
    _streamsById[stream.id] = stream;
    _liveByMasjid[masjidId] = stream;
    _watcher(masjidId).add(stream);
    return stream;
  }

  @override
  BroadcastStream endBroadcast(String streamId, EndReason reason) {
    final existing = _streamsById[streamId];
    if (existing == null) {
      throw StateError('Unknown stream id: $streamId');
    }
    final ended = existing.copyWith(
      status: StreamStatus.ended,
      endedAt: DateTime.now(),
      endReason: reason,
      currentListenerCount: 0,
    );
    _streamsById[streamId] = ended;
    _liveByMasjid[existing.masjidId] = null;
    _watcher(existing.masjidId).add(null);
    return ended;
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/data/repositories/mock/mock_broadcast_repository_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/broadcast_repository.dart lib/data/repositories/mock/mock_broadcast_repository.dart test/data/repositories/mock/mock_broadcast_repository_test.dart
git commit -m "feat(data): add BroadcastRepository interface and mock impl"
```

---

### Task 18b: ScheduleRepository interface + Mock impl

**Files:**
- Create: `lib/data/repositories/schedule_repository.dart`
- Create: `lib/data/repositories/mock/mock_schedule_repository.dart`
- Create: `test/data/repositories/mock/mock_schedule_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/prayer_times.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';

void main() {
  test('forDate returns a five-prayer schedule', () {
    final repo = MockScheduleRepository();
    final times = repo.forDate(DateTime(2026, 5, 13), masjidId: 'm_al_abrar');
    expect(times.times.length, 5);
    expect(times.times[Prayer.fajr], isNotNull);
    expect(times.times[Prayer.isha], isNotNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/repositories/mock/mock_schedule_repository_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/data/repositories/schedule_repository.dart`**

```dart
import '../models/prayer_times.dart';

abstract class ScheduleRepository {
  PrayerTimes forDate(DateTime date, {required String masjidId});
}
```

- [ ] **Step 4: Create `lib/data/repositories/mock/mock_schedule_repository.dart`**

```dart
import '../../mock/mock_schedule.dart';
import '../../models/prayer_times.dart';
import '../schedule_repository.dart';

class MockScheduleRepository implements ScheduleRepository {
  @override
  PrayerTimes forDate(DateTime date, {required String masjidId}) =>
      mockPrayerTimesFor(date);
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/data/repositories/mock/mock_schedule_repository_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/schedule_repository.dart lib/data/repositories/mock/mock_schedule_repository.dart test/data/repositories/mock/mock_schedule_repository_test.dart
git commit -m "feat(data): add ScheduleRepository interface and mock impl"
```

---

## Phase D — Riverpod providers (Tasks 19a-19f)

### Task 19a: Repository providers (with throwing defaults)

**Files:**
- Create: `lib/providers/repository_providers.dart`

This task has no test of its own (the providers are pure DI scaffolding — they would fail in any test that doesn't override them, which is the intended behavior). Coverage arrives in later tasks that consume these providers.

- [ ] **Step 1: Create `lib/providers/repository_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/broadcast_repository.dart';
import '../data/repositories/masjid_repository.dart';
import '../data/repositories/schedule_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((_) {
  throw UnimplementedError('authRepositoryProvider not overridden');
});

final masjidRepositoryProvider = Provider<MasjidRepository>((_) {
  throw UnimplementedError('masjidRepositoryProvider not overridden');
});

final broadcastRepositoryProvider = Provider<BroadcastRepository>((_) {
  throw UnimplementedError('broadcastRepositoryProvider not overridden');
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((_) {
  throw UnimplementedError('scheduleRepositoryProvider not overridden');
});
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/providers/repository_providers.dart
git commit -m "feat(providers): add repository providers with throwing defaults"
```

---

### Task 19b: currentUserProvider

**Files:**
- Create: `lib/providers/current_user_provider.dart`
- Create: `test/providers/current_user_provider_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/providers/current_user_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  test('currentUserProvider emits null then the signed-in user', () async {
    final repo = MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    expect(container.read(currentUserProvider).value, isNull);

    await repo.signIn('u_imam_yusuf');
    await container.read(currentUserProvider.future);
    expect(container.read(currentUserProvider).value?.id, 'u_imam_yusuf');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/current_user_provider_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/providers/current_user_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user.dart';
import 'repository_providers.dart';

final currentUserProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchCurrentUser();
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/current_user_provider_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/current_user_provider.dart test/providers/current_user_provider_test.dart
git commit -m "feat(providers): add currentUserProvider"
```

---

### Task 19c: currentMasjidProvider

**Files:**
- Create: `lib/providers/current_masjid_provider.dart`
- Create: `test/providers/current_masjid_provider_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/providers/current_masjid_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  test('currentMasjidProvider is null when no user is signed in', () {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
    ]);
    addTearDown(container.dispose);
    expect(container.read(currentMasjidProvider), isNull);
  });

  test('currentMasjidProvider returns the Muadhin masjid', () async {
    final auth = MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
    ]);
    addTearDown(container.dispose);

    await auth.signIn('u_imam_yusuf');
    // Force the stream to emit.
    await container.read(currentMasjidProvider.notifier as Object?);
    // Easier: wait a microtask so the StreamProvider settles.
    await Future<void>.delayed(Duration.zero);

    final m = container.read(currentMasjidProvider);
    expect(m?.id, 'm_al_abrar');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/current_masjid_provider_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/providers/current_masjid_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/masjid.dart';
import 'current_user_provider.dart';
import 'repository_providers.dart';

final currentMasjidProvider = Provider<Masjid?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.masjidId == null) return null;
  return ref.watch(masjidRepositoryProvider).findById(user.masjidId!);
});
```

- [ ] **Step 4: Fix the test (replace the awkward `notifier as Object?` line)**

Replace the second test's body with the simpler version:

```dart
  test('currentMasjidProvider returns the Muadhin masjid', () async {
    final auth = MockAuthRepository();
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
    ]);
    addTearDown(container.dispose);

    await auth.signIn('u_imam_yusuf');
    // Wait one microtask for the StreamProvider behind currentUserProvider to emit.
    await Future<void>.delayed(Duration.zero);
    container.read(currentMasjidProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentMasjidProvider)?.id, 'm_al_abrar');
  });
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/providers/current_masjid_provider_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/current_masjid_provider.dart test/providers/current_masjid_provider_test.dart
git commit -m "feat(providers): add currentMasjidProvider"
```

---

### Task 19d: prayerTimesProvider

**Files:**
- Create: `lib/providers/prayer_times_provider.dart`
- Create: `test/providers/prayer_times_provider_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/providers/prayer_times_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  test('prayerTimesProvider returns five-prayer schedule', () {
    final container = ProviderContainer(overrides: [
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
    ]);
    addTearDown(container.dispose);

    final times = container.read(
      prayerTimesProvider(PrayerTimesArg(
        date: DateTime(2026, 5, 13), masjidId: 'm_al_abrar',
      )),
    );
    expect(times.times.length, 5);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/prayer_times_provider_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/providers/prayer_times_provider.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/prayer_times.dart';
import 'repository_providers.dart';

@immutable
class PrayerTimesArg {
  const PrayerTimesArg({required this.date, required this.masjidId});
  final DateTime date;
  final String masjidId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerTimesArg &&
          other.date == date &&
          other.masjidId == masjidId);

  @override
  int get hashCode => Object.hash(date, masjidId);
}

final prayerTimesProvider =
    Provider.family<PrayerTimes, PrayerTimesArg>((ref, arg) {
  return ref
      .watch(scheduleRepositoryProvider)
      .forDate(arg.date, masjidId: arg.masjidId);
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/prayer_times_provider_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/prayer_times_provider.dart test/providers/prayer_times_provider_test.dart
git commit -m "feat(providers): add prayerTimesProvider family"
```

---

### Task 19e: liveStreamProvider

**Files:**
- Create: `lib/providers/live_stream_provider.dart`

- [ ] **Step 1: Create `lib/providers/live_stream_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/broadcast_stream.dart';
import 'repository_providers.dart';

final liveStreamProvider =
    StreamProvider.family<BroadcastStream?, String>((ref, masjidId) {
  return ref.watch(broadcastRepositoryProvider).watchCurrentLiveStream(masjidId);
});
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/providers/live_stream_provider.dart
git commit -m "feat(providers): add liveStreamProvider family"
```

---

### Task 19f: recentBroadcastsProvider

**Files:**
- Create: `lib/providers/recent_broadcasts_provider.dart`

- [ ] **Step 1: Create `lib/providers/recent_broadcasts_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/broadcast_stream.dart';
import 'repository_providers.dart';

final recentBroadcastsProvider =
    Provider.family<List<BroadcastStream>, String>((ref, masjidId) {
  return ref.watch(broadcastRepositoryProvider).recentBroadcasts(masjidId);
});
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/providers/recent_broadcasts_provider.dart
git commit -m "feat(providers): add recentBroadcastsProvider family"
```

---

## Phase E — Routing and main wiring (Tasks 19g-21)

### Task 19g: Route name constants

**Files:**
- Create: `lib/core/router/route_names.dart`

- [ ] **Step 1: Create `lib/core/router/route_names.dart`**

```dart
abstract class RouteNames {
  static const root = '/';
  static const signIn = '/sign-in';

  static const broadcasterHome = '/broadcaster/home';
  static const broadcasterDashboard = '/broadcaster/dashboard';
  static const broadcasterNearby = '/broadcaster/nearby';
  static const broadcasterInbox = '/broadcaster/inbox';
  static const broadcasterMe = '/broadcaster/me';

  static const goLive = '/broadcaster/go-live';
  static const livePath = '/broadcaster/live'; // append /:streamId
  static const summaryPath = '/broadcaster/summary'; // append /:streamId

  static const listenerHome = '/listener/home';
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/router/route_names.dart
git commit -m "feat(router): add route name constants"
```

---

### Task 20: GoRouter with auth gate + role-based redirect

**Files:**
- Create: `lib/core/router/app_router.dart`
- Create: `test/core/router/app_router_test.dart`

This task installs a minimal shell with placeholder screens so the redirect logic can be tested in isolation. The real screens land in subsequent tasks and replace the placeholders without touching the router.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/router/app_router.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, MockAuthRepository auth) async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
    ]);
    addTearDown(container.dispose);

    final router = buildAppRouter(container);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('unauthenticated user lands on sign-in', (tester) async {
    await pumpApp(tester, MockAuthRepository());
    expect(find.text('Sign in (placeholder)'), findsOneWidget);
  });

  testWidgets('Muadhin lands on broadcaster home', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    await pumpApp(tester, auth);
    expect(find.text('Broadcaster Home (placeholder)'), findsOneWidget);
  });

  testWidgets('Listener lands on listener home', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_aisha');
    await pumpApp(tester, auth);
    expect(find.text('Listener Home (placeholder)'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/router/app_router_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/core/router/app_router.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user.dart';
import '../../providers/current_user_provider.dart';
import 'route_names.dart';

GoRouter buildAppRouter(ProviderContainer container) {
  return GoRouter(
    initialLocation: RouteNames.root,
    refreshListenable: _UserChangeNotifier(container),
    redirect: (context, state) {
      final user = container.read(currentUserProvider).value;
      final atSignIn = state.matchedLocation == RouteNames.signIn;

      if (user == null) {
        return atSignIn ? null : RouteNames.signIn;
      }

      final target = _homeForRole(user.role);
      if (state.matchedLocation == RouteNames.root || atSignIn) {
        return target;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.root,
        builder: (_, __) => const _BootingPlaceholder(),
      ),
      GoRoute(
        path: RouteNames.signIn,
        builder: (_, __) => const _PlaceholderScreen('Sign in (placeholder)'),
      ),
      GoRoute(
        path: RouteNames.broadcasterHome,
        builder: (_, __) => const _PlaceholderScreen('Broadcaster Home (placeholder)'),
      ),
      GoRoute(
        path: RouteNames.broadcasterDashboard,
        builder: (_, __) => const _PlaceholderScreen('Broadcaster Dashboard (placeholder)'),
      ),
      GoRoute(
        path: RouteNames.listenerHome,
        builder: (_, __) => const _PlaceholderScreen('Listener Home (placeholder)'),
      ),
      GoRoute(
        path: RouteNames.goLive,
        builder: (_, __) => const _PlaceholderScreen('Go Live (placeholder)'),
      ),
      GoRoute(
        path: '${RouteNames.livePath}/:streamId',
        builder: (_, state) => _PlaceholderScreen(
          'Live (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
      GoRoute(
        path: '${RouteNames.summaryPath}/:streamId',
        builder: (_, state) => _PlaceholderScreen(
          'Summary (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
    ],
  );
}

String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.muadhin:
    case UserRole.admin:
      return RouteNames.broadcasterHome;
    case UserRole.listener:
      return RouteNames.listenerHome;
  }
}

class _UserChangeNotifier extends ChangeNotifier {
  _UserChangeNotifier(this._container) {
    _sub = _container.listen<AsyncValue<User?>>(
      currentUserProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }
  final ProviderContainer _container;
  late final ProviderSubscription<AsyncValue<User?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

class _BootingPlaceholder extends StatelessWidget {
  const _BootingPlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/router/app_router_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/router/app_router.dart test/core/router/app_router_test.dart
git commit -m "feat(router): add GoRouter with auth gate and role-based redirect"
```

---

### Task 21: Wire router and repository overrides into main.dart

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/app.dart`
- Modify: `test/app_test.dart`

- [ ] **Step 1: Update the boot smoke test**

Replace `test/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/app.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('App boots into the sign-in placeholder', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
        scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      ],
      child: const MuslimGuiderProApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Sign in (placeholder)'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app_test.dart`
Expected: FAIL — `MuslimGuiderProApp` still hardcodes a `home:` instead of using the router.

- [ ] **Step 3: Replace `lib/app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MuslimGuiderProApp extends ConsumerStatefulWidget {
  const MuslimGuiderProApp({super.key});

  @override
  ConsumerState<MuslimGuiderProApp> createState() => _MuslimGuiderProAppState();
}

class _MuslimGuiderProAppState extends ConsumerState<MuslimGuiderProApp> {
  late final _router = buildAppRouter(ProviderScope.containerOf(context));

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Muslim Guider Pro',
      theme: AppTheme.dark,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
```

- [ ] **Step 4: Add `flutter_localizations` to pubspec**

Add under `dependencies:` (between `cupertino_icons` and `flutter_riverpod`):

```yaml
  flutter_localizations:
    sdk: flutter
```

Then run: `flutter pub get`
Expected: `Got dependencies!`

- [ ] **Step 5: Replace `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/repositories/mock/mock_auth_repository.dart';
import 'data/repositories/mock/mock_broadcast_repository.dart';
import 'data/repositories/mock/mock_masjid_repository.dart';
import 'data/repositories/mock/mock_schedule_repository.dart';
import 'providers/repository_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
    ],
    child: const MuslimGuiderProApp(),
  ));
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/app_test.dart`
Expected: PASS, 1 test.

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/app.dart test/app_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(app): wire GoRouter and mock-repository overrides into main"
```

---

## Phase F — Sign-in screen (Task 22)

### Task 22: SignInController + SignInScreen + MockUserTile

**Files:**
- Create: `lib/features/auth/sign_in_controller.dart`
- Create: `lib/features/auth/widgets/mock_user_tile.dart`
- Create: `lib/features/auth/sign_in_screen.dart`
- Create: `test/features/auth/sign_in_screen_test.dart`
- Modify: `lib/core/router/app_router.dart` (swap placeholder for real screen)

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/features/auth/sign_in_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('SignInScreen lists three mock users', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Imam Yusuf Abdullah'), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('Platform Admin'), findsOneWidget);
  });

  testWidgets('tapping a tile signs in via the auth repository', (tester) async {
    final repo = MockAuthRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Imam Yusuf Abdullah'));
    await tester.pumpAndSettle();

    expect(repo.currentUser?.id, 'u_imam_yusuf');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/sign_in_screen_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/auth/sign_in_controller.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../providers/repository_providers.dart';

class SignInState {
  const SignInState({this.busyUserId, this.error});
  final String? busyUserId;
  final String? error;

  SignInState copyWith({String? busyUserId, String? error}) =>
      SignInState(busyUserId: busyUserId, error: error);
}

class SignInController extends StateNotifier<SignInState> {
  SignInController(this._ref) : super(const SignInState());
  final Ref _ref;

  Future<User?> selectUser(String mockUserId) async {
    state = SignInState(busyUserId: mockUserId);
    try {
      final u = await _ref.read(authRepositoryProvider).signIn(mockUserId);
      state = const SignInState();
      return u;
    } on Object catch (e) {
      state = SignInState(error: e.toString());
      return null;
    }
  }
}

final signInControllerProvider =
    StateNotifierProvider<SignInController, SignInState>((ref) {
  return SignInController(ref);
});
```

- [ ] **Step 4: Create `lib/features/auth/widgets/mock_user_tile.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';

class MockUserTile extends StatelessWidget {
  const MockUserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.busy = false,
  });

  final User user;
  final VoidCallback onTap;
  final bool busy;

  String _roleLabel() {
    switch (user.role) {
      case UserRole.muadhin:
        return user.masjidId != null
            ? 'Muadhin · ${user.masjidId}'
            : 'Muadhin';
      case UserRole.listener:
        return 'Listener';
      case UserRole.admin:
        return 'Platform Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: busy ? null : onTap,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceInset,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(user.displayName,
            style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(_roleLabel(),
            style: Theme.of(context).textTheme.bodyMedium),
        trailing: busy
            ? const SizedBox.square(
                dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right, color: AppColors.inkMuted),
      ),
    );
  }
}
```

- [ ] **Step 5: Create `lib/features/auth/sign_in_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_users.dart';
import 'sign_in_controller.dart';
import 'widgets/mock_user_tile.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text('Muslim Guider',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Choose a profile',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(state.error!,
                      style: const TextStyle(color: AppColors.liveRed),
                      textAlign: TextAlign.center),
                ),
              for (final user in kMockUsers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MockUserTile(
                    user: user,
                    busy: state.busyUserId == user.id,
                    onTap: () => ref
                        .read(signInControllerProvider.notifier)
                        .selectUser(user.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
      GoRoute(
        path: RouteNames.signIn,
        builder: (_, __) => const _PlaceholderScreen('Sign in (placeholder)'),
      ),
```

Replace with:

```dart
      GoRoute(
        path: RouteNames.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
```

And add the import at the top of the file:

```dart
import '../../features/auth/sign_in_screen.dart';
```

- [ ] **Step 7: Update the router test for the real sign-in screen**

In `test/core/router/app_router_test.dart`, change the first test's expectation:

```dart
    expect(find.text('Muslim Guider'), findsOneWidget);
    expect(find.text('Choose a profile'), findsOneWidget);
```

(replacing the previous `expect(find.text('Sign in (placeholder)'), findsOneWidget);`).

Also update `test/app_test.dart`:

```dart
    expect(find.text('Choose a profile'), findsOneWidget);
```

(replacing the previous `expect(find.text('Sign in (placeholder)'), findsOneWidget);`).

- [ ] **Step 8: Run all tests**

Run: `flutter test`
Expected: all PASS.

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add lib/features/auth/ lib/core/router/app_router.dart test/features/auth/ test/core/router/app_router_test.dart test/app_test.dart
git commit -m "feat(auth): add SignInScreen with mock-user tiles"
```

---

## Phase G — Shell, stubs, and listener home (Tasks 23-24)

### Task 23: StubScreen + AppBottomNav + ShellRoute

**Files:**
- Create: `lib/core/widgets/stub_screen.dart`
- Create: `lib/core/widgets/app_bottom_nav.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/core/widgets/app_bottom_nav_test.dart`

- [ ] **Step 1: Create `lib/core/widgets/stub_screen.dart`**

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StubScreen extends StatelessWidget {
  const StubScreen({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(label, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Coming soon',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write the failing AppBottomNav test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('AppBottomNav exposes 5 destinations', (tester) async {
    int tapped = -1;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
      ),
    ));
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);

    await tester.tap(find.text('Dashboard'));
    expect(tapped, 1);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/core/widgets/app_bottom_nav_test.dart`
Expected: FAIL — import error.

- [ ] **Step 4: Create `lib/core/widgets/app_bottom_nav.dart`**

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surfaceCard,
      indicatorColor: AppColors.primaryContainer,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.near_me_outlined),
          selectedIcon: Icon(Icons.near_me),
          label: 'Nearby',
        ),
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Me',
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Refactor `lib/core/router/app_router.dart` to add the ShellRoute**

Replace the `routes:` list with a ShellRoute that wraps the broadcaster tabs. Add these imports at the top:

```dart
import '../widgets/app_bottom_nav.dart';
import '../widgets/stub_screen.dart';
```

Replace the routes list inside `buildAppRouter` with:

```dart
    routes: [
      GoRoute(
        path: RouteNames.root,
        builder: (_, __) => const _BootingPlaceholder(),
      ),
      GoRoute(
        path: RouteNames.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _BroadcasterShell(
          location: state.matchedLocation, child: child,
        ),
        routes: [
          GoRoute(
            path: RouteNames.broadcasterHome,
            builder: (_, __) => const _PlaceholderScreen('Broadcaster Home (placeholder)'),
          ),
          GoRoute(
            path: RouteNames.broadcasterDashboard,
            builder: (_, __) => const _PlaceholderScreen('Broadcaster Dashboard (placeholder)'),
          ),
          GoRoute(
            path: RouteNames.broadcasterNearby,
            builder: (_, __) => const StubScreen(label: 'Nearby', icon: Icons.near_me_outlined),
          ),
          GoRoute(
            path: RouteNames.broadcasterInbox,
            builder: (_, __) => const StubScreen(label: 'Inbox', icon: Icons.inbox_outlined),
          ),
          GoRoute(
            path: RouteNames.broadcasterMe,
            builder: (_, __) => const StubScreen(label: 'Me', icon: Icons.person_outline),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.listenerHome,
        builder: (_, __) => const _PlaceholderScreen('Listener Home (placeholder)'),
      ),
      GoRoute(
        path: RouteNames.goLive,
        builder: (_, __) => const _PlaceholderScreen('Go Live (placeholder)'),
      ),
      GoRoute(
        path: '${RouteNames.livePath}/:streamId',
        builder: (_, state) => _PlaceholderScreen(
          'Live (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
      GoRoute(
        path: '${RouteNames.summaryPath}/:streamId',
        builder: (_, state) => _PlaceholderScreen(
          'Summary (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
    ],
```

Add the shell widget at the bottom of `app_router.dart`:

```dart
class _BroadcasterShell extends StatelessWidget {
  const _BroadcasterShell({required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = [
    RouteNames.broadcasterHome,
    RouteNames.broadcasterDashboard,
    RouteNames.broadcasterNearby,
    RouteNames.broadcasterInbox,
    RouteNames.broadcasterMe,
  ];

  int get _currentIndex {
    final i = _tabs.indexOf(location);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => GoRouter.of(context).go(_tabs[i]),
      ),
    );
  }
}
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test`
Expected: all PASS (the router test still finds the broadcaster home placeholder since the ShellRoute wraps it transparently).

- [ ] **Step 7: Commit**

```bash
git add lib/core/widgets/ lib/core/router/app_router.dart test/core/widgets/
git commit -m "feat(shell): add bottom nav and ShellRoute around broadcaster tabs"
```

---

### Task 24: StubListenerHome with sign-out

**Files:**
- Create: `lib/features/listener/stub_listener_home.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/features/listener/stub_listener_home_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/features/listener/stub_listener_home.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('StubListenerHome shows the coming-soon message', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      child: const MaterialApp(home: StubListenerHome()),
    ));
    expect(find.textContaining('Listener experience'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('Sign out clears the current user', (tester) async {
    final repo = MockAuthRepository();
    await repo.signIn('u_aisha');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: StubListenerHome()),
    ));

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(repo.currentUser, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/listener/stub_listener_home_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/listener/stub_listener_home.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/repository_providers.dart';

class StubListenerHome extends ConsumerWidget {
  const StubListenerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.headphones, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Listener experience is coming soon',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
      GoRoute(
        path: RouteNames.listenerHome,
        builder: (_, __) => const _PlaceholderScreen('Listener Home (placeholder)'),
      ),
```

Replace with:

```dart
      GoRoute(
        path: RouteNames.listenerHome,
        builder: (_, __) => const StubListenerHome(),
      ),
```

Add the import:

```dart
import '../../features/listener/stub_listener_home.dart';
```

Update the corresponding test expectation in `test/core/router/app_router_test.dart`:

```dart
    expect(find.textContaining('Listener experience'), findsOneWidget);
```

(replacing the previous `expect(find.text('Listener Home (placeholder)'), findsOneWidget);`).

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/listener/ lib/core/router/app_router.dart test/features/listener/ test/core/router/app_router_test.dart
git commit -m "feat(listener): add stub listener home with sign-out"
```

---

## Phase H — Home (Muadhin prayer widget) (Tasks 25-27)

### Task 25: AnalogClock + AnalogClockPainter

**Files:**
- Create: `lib/features/broadcaster/home/widgets/analog_clock_painter.dart`
- Create: `lib/features/broadcaster/home/widgets/analog_clock.dart`
- Create: `test/features/broadcaster/home/widgets/analog_clock_test.dart`

> **Note for the engineer:** the reference implementation lives at `C:\Users\almos\Projects\muslimguider-flutter\lib\presentation\screens\home\widgets\analog_clock.dart` (and `analog_clock_painter.dart`). Read those for the cosmic-centerpiece geometry, then adapt to our color tokens. The painter is the fiddly bit; the widget is just an `AnimatedBuilder` driving a slow rotation.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/analog_clock.dart';

void main() {
  testWidgets('AnalogClock renders at the given size', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: SizedBox.square(
        dimension: 240, child: AnalogClock(),
      ))),
    ));
    expect(find.byType(AnalogClock), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/home/widgets/analog_clock_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/home/widgets/analog_clock_painter.dart`**

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AnalogClockPainter extends CustomPainter {
  AnalogClockPainter({required this.rotation});

  final double rotation; // 0..2π for slow gold-ring rotation

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.borderMedium;
    canvas.drawCircle(center, radius - 4, outerRing);

    final goldArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.primary;
    final arcRect = Rect.fromCircle(center: center, radius: radius - 12);
    canvas.drawArc(arcRect, rotation, math.pi / 4, false, goldArc);

    final tickPaint = Paint()..color = AppColors.inkMuted;
    for (var i = 0; i < 60; i++) {
      final angle = i * (math.pi * 2 / 60);
      final isHour = i % 5 == 0;
      final inner = radius - (isHour ? 18 : 12);
      final outer = radius - 6;
      final p1 = center + Offset(math.cos(angle), math.sin(angle)) * inner;
      final p2 = center + Offset(math.cos(angle), math.sin(angle)) * outer;
      canvas.drawLine(p1, p2, tickPaint..strokeWidth = isHour ? 2 : 1);
    }

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.primary, AppColors.bgDeepNight],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.25));
    canvas.drawCircle(center, radius * 0.22, corePaint);

    final planetAngle = rotation * 2;
    final planet = center +
        Offset(math.cos(planetAngle), math.sin(planetAngle)) * (radius * 0.18);
    canvas.drawCircle(planet, 4, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter old) =>
      old.rotation != rotation;
}
```

- [ ] **Step 4: Create `lib/features/broadcaster/home/widgets/analog_clock.dart`**

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'analog_clock_painter.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock({super.key});

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: AnalogClockPainter(
            rotation: _controller.value * math.pi * 2,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/broadcaster/home/widgets/analog_clock_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/home/widgets/analog_clock.dart lib/features/broadcaster/home/widgets/analog_clock_painter.dart test/features/broadcaster/home/widgets/analog_clock_test.dart
git commit -m "feat(home): port AnalogClock painter and widget"
```

---

### Task 26: RoleBadge + MaghribCountdown + MicLockIndicator

**Files:**
- Create: `lib/features/broadcaster/home/widgets/role_badge.dart`
- Create: `lib/features/broadcaster/home/widgets/maghrib_countdown.dart`
- Create: `lib/features/broadcaster/home/widgets/mic_lock_indicator.dart`
- Create: `test/features/broadcaster/home/widgets/role_badge_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/maghrib_countdown.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/mic_lock_indicator.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/widgets/role_badge.dart';

void main() {
  testWidgets('RoleBadge shows the role and masjid name', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RoleBadge(masjidName: 'MASJID AL-ABRAR')),
    ));
    expect(find.text('MUADHIN'), findsOneWidget);
    expect(find.text('MASJID AL-ABRAR'), findsOneWidget);
  });

  testWidgets('MaghribCountdown formats mm:ss', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MaghribCountdown(
        remaining: Duration(minutes: 58, seconds: 20),
      )),
    ));
    expect(find.text('58:20'), findsOneWidget);
  });

  testWidgets('MicLockIndicator shows idle when not active', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MicLockIndicator(active: false)),
    ));
    expect(find.text('IDLE'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/home/widgets/role_badge_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/home/widgets/role_badge.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.masjidName});
  final String masjidName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cell_tower, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('MUADHIN', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: AppColors.inkMuted)),
          const SizedBox(width: 6),
          Text(masjidName,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create `lib/features/broadcaster/home/widgets/maghrib_countdown.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MaghribCountdown extends StatelessWidget {
  const MaghribCountdown({super.key, required this.remaining, this.label});

  final Duration remaining;
  final String? label;

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '${hh.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (label != null)
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        Text(_format(remaining),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  shadows: const [
                    Shadow(color: Color(0x66F2C050), blurRadius: 18),
                  ],
                )),
      ],
    );
  }
}
```

- [ ] **Step 5: Create `lib/features/broadcaster/home/widgets/mic_lock_indicator.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MicLockIndicator extends StatelessWidget {
  const MicLockIndicator({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colour = active ? AppColors.liveRed : AppColors.primary;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colour, width: 2),
        color: AppColors.surfaceInset,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? Icons.mic : Icons.mic_none, color: colour, size: 18),
          Text(active ? 'LIVE' : 'IDLE',
              style: TextStyle(color: colour, fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/broadcaster/home/widgets/role_badge_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 7: Commit**

```bash
git add lib/features/broadcaster/home/widgets/ test/features/broadcaster/home/widgets/role_badge_test.dart
git commit -m "feat(home): add RoleBadge, MaghribCountdown, and MicLockIndicator"
```

---

### Task 27: HomePrayerWidgetMuadhinScreen + golden test

**Files:**
- Create: `lib/features/broadcaster/home/home_prayer_widget_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/features/broadcaster/home/home_prayer_widget_screen_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/home/home_prayer_widget_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Home screen renders MUADHIN badge and slide pill for a signed-in Muadhin', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      ],
      child: const MaterialApp(home: HomePrayerWidgetMuadhinScreen()),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('MUADHIN'), findsOneWidget);
    expect(find.text('SLIDE TO BROADCAST'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/home/home_prayer_widget_screen_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/home/home_prayer_widget_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import 'widgets/analog_clock.dart';
import 'widgets/maghrib_countdown.dart';
import 'widgets/mic_lock_indicator.dart';
import 'widgets/role_badge.dart';

class HomePrayerWidgetMuadhinScreen extends ConsumerStatefulWidget {
  const HomePrayerWidgetMuadhinScreen({super.key});

  @override
  ConsumerState<HomePrayerWidgetMuadhinScreen> createState() =>
      _HomePrayerWidgetMuadhinScreenState();
}

class _HomePrayerWidgetMuadhinScreenState
    extends ConsumerState<HomePrayerWidgetMuadhinScreen> {
  @override
  Widget build(BuildContext context) {
    final masjid = ref.watch(currentMasjidProvider);
    final today = DateTime.now();
    final times = masjid == null
        ? null
        : ref.watch(prayerTimesProvider(
            PrayerTimesArg(date: today, masjidId: masjid.id)));
    final now = DateTime.now();
    final remaining = times?.toNextAt(now) ?? Duration.zero;
    final hijri = HijriCalendar.fromDate(now);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  RoleBadge(masjidName: (masjid?.name ?? '').toUpperCase()),
                  const Spacer(),
                  const MicLockIndicator(active: false),
                ],
              ),
              const SizedBox(height: 24),
              Text(DateFormat('hh:mm a').format(now),
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, d MMMM y').format(now),
                  style: Theme.of(context).textTheme.bodyLarge),
              Text(hijri.toFormat('dd MMMM yyyy'),
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              SizedBox.square(
                dimension: 260,
                child: const AnalogClock(),
              ),
              const SizedBox(height: 16),
              MaghribCountdown(
                  remaining: remaining,
                  label: 'TIME UNTIL NEXT PRAYER'),
              const SizedBox(height: 24),
              _SlidePillEntry(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _GoLivePlaceholder()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidePillEntry extends StatelessWidget {
  const _SlidePillEntry({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Center(
        child: TextButton(
          onPressed: onTap,
          child: Text('SLIDE TO BROADCAST',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(letterSpacing: 2)),
        ),
      ),
    );
  }
}

class _GoLivePlaceholder extends StatelessWidget {
  const _GoLivePlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('go-live route — Task 32')));
}
```

> The slide-pill is a tap-to-navigate stub here; Task 28 replaces it with the real `SlideToBroadcast` widget and routes via go_router (`context.push(RouteNames.goLive)`).

- [ ] **Step 4: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
          GoRoute(
            path: RouteNames.broadcasterHome,
            builder: (_, __) => const _PlaceholderScreen('Broadcaster Home (placeholder)'),
          ),
```

Replace with:

```dart
          GoRoute(
            path: RouteNames.broadcasterHome,
            builder: (_, __) => const HomePrayerWidgetMuadhinScreen(),
          ),
```

Add import:

```dart
import '../../features/broadcaster/home/home_prayer_widget_screen.dart';
```

Update the router test:

```dart
    expect(find.text('MUADHIN'), findsOneWidget);
```

(replacing `expect(find.text('Broadcaster Home (placeholder)'), findsOneWidget);`).

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/home/home_prayer_widget_screen.dart lib/core/router/app_router.dart test/features/broadcaster/home/home_prayer_widget_screen_test.dart test/core/router/app_router_test.dart
git commit -m "feat(home): assemble Muadhin home prayer-widget screen"
```

---

## Phase I — SlideToBroadcast (Task 28)

### Task 28: SlideToBroadcast swipe-to-confirm widget + use it in Home

**Files:**
- Create: `lib/features/broadcaster/shared/slide_to_broadcast.dart`
- Create: `lib/features/broadcaster/shared/broadcast_status_banner.dart`
- Modify: `lib/features/broadcaster/home/home_prayer_widget_screen.dart`
- Create: `test/features/broadcaster/shared/slide_to_broadcast_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/shared/slide_to_broadcast.dart';

void main() {
  testWidgets('full drag fires onConfirmed', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox(
        width: 300,
        child: SlideToBroadcast(onConfirmed: () => confirmed = true),
      )),
    ));

    final pill = tester.getRect(find.byType(SlideToBroadcast));
    await tester.dragFrom(
      pill.centerLeft + const Offset(32, 0),
      Offset(pill.width - 64, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('partial drag springs back without firing', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox(
        width: 300,
        child: SlideToBroadcast(onConfirmed: () => confirmed = true),
      )),
    ));

    final pill = tester.getRect(find.byType(SlideToBroadcast));
    await tester.dragFrom(
      pill.centerLeft + const Offset(32, 0),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/shared/slide_to_broadcast_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/shared/slide_to_broadcast.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SlideToBroadcast extends StatefulWidget {
  const SlideToBroadcast({
    super.key,
    required this.onConfirmed,
    this.label = 'SLIDE TO BROADCAST',
    this.confirmThreshold = 0.8,
  });

  final VoidCallback onConfirmed;
  final String label;
  final double confirmThreshold;

  @override
  State<SlideToBroadcast> createState() => _SlideToBroadcastState();
}

class _SlideToBroadcastState extends State<SlideToBroadcast> {
  double _drag = 0;
  double _maxDrag = 0;
  bool _fired = false;

  void _onUpdate(DragUpdateDetails d) {
    setState(() {
      _drag = (_drag + d.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _onEnd(DragEndDetails _) {
    if (_fired) return;
    if (_maxDrag > 0 && _drag / _maxDrag >= widget.confirmThreshold) {
      _fired = true;
      widget.onConfirmed();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const thumbSize = 56.0;
      _maxDrag = constraints.maxWidth - thumbSize - 8;
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceInset,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(letterSpacing: 2),
            ),
            Positioned(
              left: 4 + _drag,
              child: GestureDetector(
                onHorizontalDragUpdate: _onUpdate,
                onHorizontalDragEnd: _onEnd,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic,
                      color: AppColors.bgDeepNight, size: 28),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
```

- [ ] **Step 4: Create `lib/features/broadcaster/shared/broadcast_status_banner.dart`**

```dart
import 'package:flutter/material.dart';

// Reserved: empty stub kept for re-introduction in a later sprint.
class BroadcastStatusBanner extends StatelessWidget {
  const BroadcastStatusBanner({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

- [ ] **Step 5: Use `SlideToBroadcast` in Home**

In `lib/features/broadcaster/home/home_prayer_widget_screen.dart`:

- Add import at the top:

```dart
import 'package:go_router/go_router.dart';
import '../shared/slide_to_broadcast.dart';
```

- Remove the entire `_SlidePillEntry` and `_GoLivePlaceholder` classes at the bottom of the file.
- Replace the `_SlidePillEntry(onTap: ...)` line in the `build` method with:

```dart
              SlideToBroadcast(
                onConfirmed: () => context.push(RouteNames.goLive),
              ),
```

- [ ] **Step 6: Update the Home widget test to match the new label**

In `test/features/broadcaster/home/home_prayer_widget_screen_test.dart`:

```dart
    expect(find.text('SLIDE TO BROADCAST'), findsOneWidget);
```

(already matches — no change needed, the label is identical).

- [ ] **Step 7: Run tests**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/broadcaster/shared/ lib/features/broadcaster/home/home_prayer_widget_screen.dart test/features/broadcaster/shared/slide_to_broadcast_test.dart
git commit -m "feat(broadcaster): add SlideToBroadcast swipe-to-confirm widget"
```

---

## Phase J — Dashboard (Tasks 29-31)

### Task 29: GoldGlowCard + LiveIndicator core widgets

**Files:**
- Create: `lib/core/widgets/gold_glow_card.dart`
- Create: `lib/core/widgets/live_indicator.dart`
- Create: `test/core/widgets/gold_glow_card_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/core/widgets/gold_glow_card.dart';
import 'package:muslim_guider_pro/core/widgets/live_indicator.dart';

void main() {
  testWidgets('GoldGlowCard renders its child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: GoldGlowCard(child: Text('inside'))),
    ));
    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('LiveIndicator shows the LIVE label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LiveIndicator()),
    ));
    expect(find.text('LIVE'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/gold_glow_card_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/core/widgets/gold_glow_card.dart`**

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GoldGlowCard extends StatelessWidget {
  const GoldGlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 4: Create `lib/core/widgets/live_indicator.dart`**

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});
  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.liveRedBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 8 + _pulse.value * 4,
              height: 8 + _pulse.value * 4,
              decoration: const BoxDecoration(
                color: AppColors.liveRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text('LIVE',
              style: TextStyle(
                color: AppColors.liveRed,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/widgets/gold_glow_card_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/gold_glow_card.dart lib/core/widgets/live_indicator.dart test/core/widgets/gold_glow_card_test.dart
git commit -m "feat(core): add GoldGlowCard and pulsing LiveIndicator"
```

---

### Task 30: Dashboard widgets (KpiTile + NextBroadcastCard + RecentBroadcastsList)

**Files:**
- Create: `lib/features/broadcaster/dashboard/widgets/kpi_tile.dart`
- Create: `lib/features/broadcaster/dashboard/widgets/next_broadcast_card.dart`
- Create: `lib/features/broadcaster/dashboard/widgets/recent_broadcasts_list.dart`
- Create: `test/features/broadcaster/dashboard/widgets/dashboard_widgets_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/kpi_tile.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/next_broadcast_card.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/widgets/recent_broadcasts_list.dart';

void main() {
  testWidgets('KpiTile shows value and label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: KpiTile(label: "Today's Broadcasts", value: '3')),
    ));
    expect(find.text('3'), findsOneWidget);
    expect(find.text("Today's Broadcasts"), findsOneWidget);
  });

  testWidgets('NextBroadcastCard shows prayer name and time', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: NextBroadcastCard(
        prayerName: 'Maghrib',
        at: DateTime(2026, 5, 13, 19, 30),
      )),
    ));
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('19:30'), findsOneWidget);
  });

  testWidgets('RecentBroadcastsList renders one row per entry', (tester) async {
    final entries = [
      BroadcastStream(
        id: 's1', masjidId: 'm1', muadhinId: 'u1',
        startedAt: DateTime(2026, 5, 13, 4, 30),
        endedAt: DateTime(2026, 5, 13, 4, 33),
        peakListenerCount: 47, currentListenerCount: 0,
        status: StreamStatus.ended, endReason: EndReason.normal,
      ),
      BroadcastStream(
        id: 's2', masjidId: 'm1', muadhinId: 'u1',
        startedAt: DateTime(2026, 5, 12, 21, 0),
        endedAt: DateTime(2026, 5, 12, 21, 4),
        peakListenerCount: 52, currentListenerCount: 0,
        status: StreamStatus.ended, endReason: EndReason.normal,
      ),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RecentBroadcastsList(entries: entries)),
    ));
    expect(find.textContaining('47'), findsOneWidget);
    expect(find.textContaining('52'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/dashboard/widgets/dashboard_widgets_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/dashboard/widgets/kpi_tile.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gold_glow_card.dart';

class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GoldGlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create `lib/features/broadcaster/dashboard/widgets/next_broadcast_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/gold_glow_card.dart';

class NextBroadcastCard extends StatelessWidget {
  const NextBroadcastCard({
    super.key,
    required this.prayerName,
    required this.at,
  });

  final String prayerName;
  final DateTime at;

  @override
  Widget build(BuildContext context) {
    return GoldGlowCard(
      child: Row(
        children: [
          const Icon(Icons.cell_tower, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT BROADCAST',
                    style: Theme.of(context).textTheme.labelLarge),
                Text(prayerName,
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          Text(DateFormat('HH:mm').format(at),
              style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Create `lib/features/broadcaster/dashboard/widgets/recent_broadcasts_list.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gold_glow_card.dart';
import '../../../../data/models/broadcast_stream.dart';

class RecentBroadcastsList extends StatelessWidget {
  const RecentBroadcastsList({super.key, required this.entries});
  final List<BroadcastStream> entries;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return GoldGlowCard(
        child: Text('No recent broadcasts',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GoldGlowCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEE, d MMM · HH:mm')
                                .format(e.startedAt),
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text('${e.peakListenerCount} listeners · ${_format(e.duration)}',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(e.endReason?.name.toUpperCase() ?? 'ENDED',
                        style: const TextStyle(
                          fontSize: 10, letterSpacing: 1,
                          color: AppColors.successGreen,
                        )),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/broadcaster/dashboard/widgets/dashboard_widgets_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 7: Commit**

```bash
git add lib/features/broadcaster/dashboard/widgets/ test/features/broadcaster/dashboard/widgets/dashboard_widgets_test.dart
git commit -m "feat(dashboard): add KpiTile, NextBroadcastCard, RecentBroadcastsList"
```

---

### Task 31: MasjidDashboardScreen

**Files:**
- Create: `lib/features/broadcaster/dashboard/masjid_dashboard_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/features/broadcaster/dashboard/masjid_dashboard_screen_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/dashboard/masjid_dashboard_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Dashboard shows the masjid name, KPI grid, and recent list',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
        scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      ],
      child: const MaterialApp(home: MasjidDashboardScreen()),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Masjid Al-Abrar'), findsOneWidget);
    expect(find.text("Today's Broadcasts"), findsOneWidget);
    expect(find.text('Avg Listeners'), findsOneWidget);
    expect(find.text('Stream Quality'), findsOneWidget);
    expect(find.text('Uptime'), findsOneWidget);
    expect(find.text('SLIDE TO BROADCAST'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/dashboard/masjid_dashboard_screen_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/dashboard/masjid_dashboard_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import '../../../providers/recent_broadcasts_provider.dart';
import '../shared/slide_to_broadcast.dart';
import 'widgets/kpi_tile.dart';
import 'widgets/next_broadcast_card.dart';
import 'widgets/recent_broadcasts_list.dart';

class MasjidDashboardScreen extends ConsumerWidget {
  const MasjidDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjid = ref.watch(currentMasjidProvider);
    if (masjid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final today = DateTime.now();
    final times = ref.watch(prayerTimesProvider(
      PrayerTimesArg(date: today, masjidId: masjid.id),
    ));
    final recent = ref.watch(recentBroadcastsProvider(masjid.id));
    final next = times.nextAt(today);
    final nextAt = times.times[next]!;
    final todayCount =
        recent.where((s) => _sameDay(s.startedAt, today)).length;
    final avgListeners = recent.isEmpty
        ? 0
        : (recent.map((s) => s.peakListenerCount).reduce((a, b) => a + b) /
                recent.length)
            .round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(masjid.name,
                style: Theme.of(context).textTheme.headlineLarge),
            Text(masjid.city,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SlideToBroadcast(
              onConfirmed: () => context.push(RouteNames.goLive),
            ),
            const SizedBox(height: 16),
            NextBroadcastCard(prayerName: _prayerLabel(next), at: nextAt),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                KpiTile(label: "Today's Broadcasts", value: '$todayCount'),
                KpiTile(label: 'Avg Listeners', value: '$avgListeners'),
                const KpiTile(label: 'Stream Quality', value: 'Excellent'),
                const KpiTile(label: 'Uptime', value: '99.2%'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Recent broadcasts',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            RecentBroadcastsList(entries: recent),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _prayerLabel(Object prayer) {
    final name = prayer.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }
}
```

- [ ] **Step 4: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
          GoRoute(
            path: RouteNames.broadcasterDashboard,
            builder: (_, __) => const _PlaceholderScreen('Broadcaster Dashboard (placeholder)'),
          ),
```

Replace with:

```dart
          GoRoute(
            path: RouteNames.broadcasterDashboard,
            builder: (_, __) => const MasjidDashboardScreen(),
          ),
```

Add the import:

```dart
import '../../features/broadcaster/dashboard/masjid_dashboard_screen.dart';
```

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/dashboard/masjid_dashboard_screen.dart lib/core/router/app_router.dart test/features/broadcaster/dashboard/masjid_dashboard_screen_test.dart
git commit -m "feat(dashboard): assemble Masjid dashboard screen"
```

---

## Phase K — Go-Live Pre-Check (Tasks 32-33)

### Task 32: GoLivePreCheckController + CheckCard widget

**Files:**
- Create: `lib/features/broadcaster/go_live/go_live_controller.dart`
- Create: `lib/features/broadcaster/go_live/widgets/check_card.dart`
- Create: `test/features/broadcaster/go_live/go_live_controller_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_controller.dart';

void main() {
  test('initial state is all idle and not ready', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(goLiveControllerProvider);
    expect(state.mic, CheckStatus.idle);
    expect(state.network, CheckStatus.idle);
    expect(state.geofence, CheckStatus.idle);
    expect(state.allOk, isFalse);
  });

  test('runFakeChecks moves network and geofence to ok', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(goLiveControllerProvider.notifier).runFakeChecks();
    final state = container.read(goLiveControllerProvider);
    expect(state.network, CheckStatus.ok);
    expect(state.geofence, CheckStatus.ok);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/go_live/go_live_controller_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/go_live/go_live_controller.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CheckStatus { idle, checking, ok, failed }

class GoLiveState {
  const GoLiveState({
    this.mic = CheckStatus.idle,
    this.network = CheckStatus.idle,
    this.geofence = CheckStatus.idle,
  });

  final CheckStatus mic;
  final CheckStatus network;
  final CheckStatus geofence;

  bool get allOk =>
      mic == CheckStatus.ok &&
      network == CheckStatus.ok &&
      geofence == CheckStatus.ok;

  GoLiveState copyWith({
    CheckStatus? mic,
    CheckStatus? network,
    CheckStatus? geofence,
  }) {
    return GoLiveState(
      mic: mic ?? this.mic,
      network: network ?? this.network,
      geofence: geofence ?? this.geofence,
    );
  }
}

class GoLiveController extends StateNotifier<GoLiveState> {
  GoLiveController() : super(const GoLiveState());

  void setMic(CheckStatus status) => state = state.copyWith(mic: status);

  Future<void> runFakeChecks() async {
    state = state.copyWith(network: CheckStatus.checking, geofence: CheckStatus.checking);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(network: CheckStatus.ok, geofence: CheckStatus.ok);
  }
}

final goLiveControllerProvider =
    StateNotifierProvider.autoDispose<GoLiveController, GoLiveState>((ref) {
  return GoLiveController();
});
```

- [ ] **Step 4: Create `lib/features/broadcaster/go_live/widgets/check_card.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gold_glow_card.dart';
import '../go_live_controller.dart';

class CheckCard extends StatelessWidget {
  const CheckCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    this.onRetry,
  });

  final String title;
  final String subtitle;
  final CheckStatus status;
  final IconData icon;
  final VoidCallback? onRetry;

  Color _statusColor() {
    switch (status) {
      case CheckStatus.idle: return AppColors.inkSubtle;
      case CheckStatus.checking: return AppColors.warningAmber;
      case CheckStatus.ok: return AppColors.successGreen;
      case CheckStatus.failed: return AppColors.liveRed;
    }
  }

  Widget _trailing() {
    switch (status) {
      case CheckStatus.checking:
        return const SizedBox.square(
          dimension: 20, child: CircularProgressIndicator(strokeWidth: 2));
      case CheckStatus.ok:
        return const Icon(Icons.check_circle, color: AppColors.successGreen);
      case CheckStatus.failed:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error, color: AppColors.liveRed),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]);
      case CheckStatus.idle:
        return const Icon(Icons.radio_button_unchecked, color: AppColors.inkSubtle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoldGlowCard(
      child: Row(
        children: [
          Icon(icon, color: _statusColor()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          _trailing(),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/broadcaster/go_live/go_live_controller_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/go_live/go_live_controller.dart lib/features/broadcaster/go_live/widgets/check_card.dart test/features/broadcaster/go_live/go_live_controller_test.dart
git commit -m "feat(go-live): add pre-check controller and CheckCard widget"
```

---

### Task 33: GoLivePreCheckScreen with permission flow

**Files:**
- Create: `lib/features/broadcaster/go_live/go_live_pre_check_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/features/broadcaster/go_live/go_live_pre_check_screen_test.dart`

> **Note:** `permission_handler` doesn't trigger real platform code in unit tests, so the test uses a mocked permission status by reading the controller's `mic` state directly. The screen also exposes a "Force mic OK" debug button under `kDebugMode` so the test (and you, manually) can drive the happy path without an actual permission grant.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_controller.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_pre_check_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Pre-Check screen renders three checks and Continue button',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      ],
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Microphone'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('Inside masjid radius'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Continue is disabled until allOk', (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      ],
      child: const MaterialApp(home: GoLivePreCheckScreen()),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final continueBtn = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(continueBtn.onPressed, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/go_live/go_live_pre_check_screen_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/go_live/go_live_pre_check_screen.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/repository_providers.dart';
import 'go_live_controller.dart';
import 'widgets/check_card.dart';

class GoLivePreCheckScreen extends ConsumerStatefulWidget {
  const GoLivePreCheckScreen({super.key});

  @override
  ConsumerState<GoLivePreCheckScreen> createState() =>
      _GoLivePreCheckScreenState();
}

class _GoLivePreCheckScreenState extends ConsumerState<GoLivePreCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goLiveControllerProvider.notifier).runFakeChecks();
      _requestMic();
    });
  }

  Future<void> _requestMic() async {
    final controller = ref.read(goLiveControllerProvider.notifier)
      ..setMic(CheckStatus.checking);
    try {
      final status = await Permission.microphone.request();
      controller.setMic(
        status.isGranted ? CheckStatus.ok : CheckStatus.failed,
      );
    } catch (_) {
      controller.setMic(CheckStatus.failed);
    }
  }

  Future<void> _onContinue() async {
    final user = ref.read(currentUserProvider).value;
    final masjid = ref.read(currentMasjidProvider);
    if (user == null || masjid == null) return;
    final stream = ref
        .read(broadcastRepositoryProvider)
        .startBroadcast(masjidId: masjid.id, muadhinId: user.id);
    if (!mounted) return;
    context.pushReplacement('${RouteNames.livePath}/${stream.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goLiveControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Broadcast Check')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckCard(
                icon: Icons.mic,
                title: 'Microphone',
                subtitle: state.mic == CheckStatus.failed
                    ? 'Permission denied — open Settings to enable'
                    : 'Required for the ambient meter',
                status: state.mic,
                onRetry: state.mic == CheckStatus.failed ? openAppSettings : null,
              ),
              const SizedBox(height: 12),
              CheckCard(
                icon: Icons.wifi,
                title: 'Network',
                subtitle: 'Connectivity to AWS Chime SFU',
                status: state.network,
              ),
              const SizedBox(height: 12),
              CheckCard(
                icon: Icons.place,
                title: 'Inside masjid radius',
                subtitle: 'Geofence verification will be real once GPS lands',
                status: state.geofence,
              ),
              const Spacer(),
              if (kDebugMode && state.mic != CheckStatus.ok)
                TextButton(
                  onPressed: () => ref
                      .read(goLiveControllerProvider.notifier)
                      .setMic(CheckStatus.ok),
                  child: const Text('Debug: force mic OK'),
                ),
              FilledButton(
                onPressed: state.allOk ? _onContinue : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
      GoRoute(
        path: RouteNames.goLive,
        builder: (_, __) => const _PlaceholderScreen('Go Live (placeholder)'),
      ),
```

Replace with:

```dart
      GoRoute(
        path: RouteNames.goLive,
        builder: (_, __) => const GoLivePreCheckScreen(),
      ),
```

Add import:

```dart
import '../../features/broadcaster/go_live/go_live_pre_check_screen.dart';
```

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/go_live/go_live_pre_check_screen.dart lib/core/router/app_router.dart test/features/broadcaster/go_live/go_live_pre_check_screen_test.dart
git commit -m "feat(go-live): add pre-broadcast check screen with permission flow"
```

---

## Phase L — Microphone level provider (Task 34)

### Task 34: micLevelProvider with platform-aware fallback

**Files:**
- Create: `lib/providers/mic_level_provider.dart`
- Create: `test/providers/mic_level_provider_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';

void main() {
  test('Fallback sine emits values between 0 and 1', () async {
    final container = ProviderContainer(overrides: [
      useFallbackMicProvider.overrideWithValue(true),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen<AsyncValue<double>>(micLevelProvider, (_, __) {});

    final value = await container.read(micLevelProvider.future);
    expect(value, inInclusiveRange(0.0, 1.0));
    sub.close();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/mic_level_provider_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/providers/mic_level_provider.dart`**

```dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_meter/noise_meter.dart';

final useFallbackMicProvider = Provider<bool>((_) {
  if (kIsWeb) return true;
  return !(Platform.isAndroid || Platform.isIOS);
});

final micLevelProvider = StreamProvider.autoDispose<double>((ref) {
  final useFallback = ref.watch(useFallbackMicProvider);
  if (useFallback) return _sineFallback();
  return _noiseMeterStream();
});

Stream<double> _sineFallback() async* {
  final start = DateTime.now();
  while (true) {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final t = DateTime.now().difference(start).inMilliseconds / 1000.0;
    yield ((math.sin(t * 2 * math.pi / 3) + 1) / 2).clamp(0.0, 1.0);
  }
}

Stream<double> _noiseMeterStream() async* {
  try {
    final meter = NoiseMeter();
    await for (final r in meter.noise) {
      const minDb = -60.0;
      const maxDb = 0.0;
      final norm = ((r.meanDecibel - minDb) / (maxDb - minDb)).clamp(0.0, 1.0);
      yield norm;
    }
  } catch (_) {
    yield* _sineFallback();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/mic_level_provider_test.dart`
Expected: PASS, 1 test.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/mic_level_provider.dart test/providers/mic_level_provider_test.dart
git commit -m "feat(providers): add micLevelProvider with sine fallback on web/desktop"
```

---

## Phase M — Live Broadcast (Tasks 35-36)

### Task 35: LiveBroadcastController + LiveTimer + VolumeMeter + ListenerCounter

**Files:**
- Create: `lib/features/broadcaster/live/live_broadcast_controller.dart`
- Create: `lib/features/broadcaster/live/widgets/live_timer.dart`
- Create: `lib/features/broadcaster/live/widgets/volume_meter.dart`
- Create: `lib/features/broadcaster/live/widgets/listener_counter.dart`
- Create: `test/features/broadcaster/live/live_broadcast_widgets_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/widgets/listener_counter.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/widgets/live_timer.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/widgets/volume_meter.dart';

void main() {
  testWidgets('LiveTimer formats elapsed as mm:ss', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LiveTimer(elapsed: Duration(minutes: 2, seconds: 7))),
    ));
    expect(find.text('02:07'), findsOneWidget);
  });

  testWidgets('VolumeMeter renders bars and uses level', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: VolumeMeter(level: 0.5, barCount: 8)),
    ));
    expect(find.byType(VolumeMeter), findsOneWidget);
  });

  testWidgets('ListenerCounter shows current count', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ListenerCounter(count: 42)),
    ));
    expect(find.textContaining('42'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/live/live_broadcast_widgets_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/live/live_broadcast_controller.dart`**

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveTickState {
  const LiveTickState({required this.elapsed, required this.listenerCount});
  final Duration elapsed;
  final int listenerCount;
}

class LiveBroadcastController extends StateNotifier<LiveTickState> {
  LiveBroadcastController(this.startedAt)
      : super(LiveTickState(elapsed: Duration.zero, listenerCount: 0)) {
    _start();
  }

  final DateTime startedAt;
  final _rng = Random();
  Timer? _timer;
  int _count = 0;

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = (_count + (_rng.nextInt(3) == 0 ? 1 : 0)).clamp(0, 80);
      _count = next;
      state = LiveTickState(
        elapsed: DateTime.now().difference(startedAt),
        listenerCount: next,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final liveBroadcastControllerProvider =
    StateNotifierProvider.autoDispose.family<LiveBroadcastController, LiveTickState, DateTime>(
        (ref, startedAt) {
  return LiveBroadcastController(startedAt);
});
```

- [ ] **Step 4: Create `lib/features/broadcaster/live/widgets/live_timer.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LiveTimer extends StatelessWidget {
  const LiveTimer({super.key, required this.elapsed});
  final Duration elapsed;

  String _format(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hh > 0 ? '${hh.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_format(elapsed),
        style: Theme.of(context).textTheme.displayLarge
            ?.copyWith(color: AppColors.primary));
  }
}
```

- [ ] **Step 5: Create `lib/features/broadcaster/live/widgets/volume_meter.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class VolumeMeter extends StatelessWidget {
  const VolumeMeter({super.key, required this.level, this.barCount = 16});
  final double level;
  final int barCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barCount, (i) {
          final threshold = (i + 1) / barCount;
          final on = level >= threshold * 0.6;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: on ? 16 + level * 100 * (threshold + 0.2) : 8,
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.surfaceInset,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 6: Create `lib/features/broadcaster/live/widgets/listener_counter.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ListenerCounter extends StatelessWidget {
  const ListenerCounter({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.headphones, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$count listening',
            style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
```

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/broadcaster/live/live_broadcast_widgets_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 8: Commit**

```bash
git add lib/features/broadcaster/live/ test/features/broadcaster/live/live_broadcast_widgets_test.dart
git commit -m "feat(live): add LiveTimer, VolumeMeter, ListenerCounter, controller"
```

---

### Task 36: LiveBroadcastScreen

**Files:**
- Create: `lib/features/broadcaster/live/live_broadcast_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/features/broadcaster/live/live_broadcast_screen_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/live/live_broadcast_screen.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Live screen shows LIVE badge, listener count, and End button',
      (tester) async {
    final auth = MockAuthRepository();
    await auth.signIn('u_imam_yusuf');
    final broadcast = MockBroadcastRepository();
    final stream = broadcast.startBroadcast(
        masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
        broadcastRepositoryProvider.overrideWithValue(broadcast),
        useFallbackMicProvider.overrideWithValue(true),
      ],
      child: MaterialApp(home: LiveBroadcastScreen(streamId: stream.id)),
    ));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('End Broadcast'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/live/live_broadcast_screen_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/live/live_broadcast_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/live_indicator.dart';
import '../../../data/models/broadcast_stream.dart';
import '../../../providers/current_masjid_provider.dart';
import '../../../providers/mic_level_provider.dart';
import '../../../providers/repository_providers.dart';
import 'live_broadcast_controller.dart';
import 'widgets/listener_counter.dart';
import 'widgets/live_timer.dart';
import 'widgets/volume_meter.dart';

class LiveBroadcastScreen extends ConsumerWidget {
  const LiveBroadcastScreen({super.key, required this.streamId});
  final String streamId;

  Future<void> _endBroadcast(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End broadcast?'),
        content: const Text('Listeners will be disconnected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(broadcastRepositoryProvider).endBroadcast(streamId, EndReason.normal);
    if (!context.mounted) return;
    context.pushReplacement('${RouteNames.summaryPath}/$streamId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.read(broadcastRepositoryProvider).findById(streamId);
    if (stream == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.broadcasterDashboard);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final masjid = ref.watch(currentMasjidProvider);
    final tick = ref.watch(liveBroadcastControllerProvider(stream.startedAt));
    final micLevel = ref.watch(micLevelProvider).value ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.topLeft, child: LiveIndicator()),
              const SizedBox(height: 16),
              Text(masjid?.name ?? '',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Center(child: LiveTimer(elapsed: tick.elapsed)),
              const SizedBox(height: 8),
              Center(child: ListenerCounter(count: tick.listenerCount)),
              const SizedBox(height: 24),
              VolumeMeter(level: micLevel),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.liveRed,
                  foregroundColor: AppColors.inkPrimary,
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () => _endBroadcast(context, ref),
                child: const Text('End Broadcast'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
      GoRoute(
        path: '${RouteNames.livePath}/:streamId',
        builder: (_, state) => _PlaceholderScreen(
          'Live (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
```

Replace with:

```dart
      GoRoute(
        path: '${RouteNames.livePath}/:streamId',
        builder: (_, state) => LiveBroadcastScreen(
          streamId: state.pathParameters['streamId']!,
        ),
      ),
```

Add import:

```dart
import '../../features/broadcaster/live/live_broadcast_screen.dart';
```

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/live/live_broadcast_screen.dart lib/core/router/app_router.dart test/features/broadcaster/live/live_broadcast_screen_test.dart
git commit -m "feat(live): assemble live broadcast screen"
```

---

## Phase N — Broadcast Summary (Task 37)

### Task 37: BroadcastSummaryScreen

**Files:**
- Create: `lib/features/broadcaster/summary/broadcast_summary_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `test/features/broadcaster/summary/broadcast_summary_screen_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guider_pro/data/models/broadcast_stream.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/summary/broadcast_summary_screen.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  testWidgets('Summary screen shows stats and a Done button', (tester) async {
    final broadcast = MockBroadcastRepository();
    final started = broadcast.startBroadcast(
        masjidId: 'm_al_abrar', muadhinId: 'u_imam_yusuf');
    broadcast.endBroadcast(started.id, EndReason.normal);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        broadcastRepositoryProvider.overrideWithValue(broadcast),
      ],
      child: MaterialApp(home: BroadcastSummaryScreen(streamId: started.id)),
    ));
    expect(find.text('Broadcast Ended'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/broadcaster/summary/broadcast_summary_screen_test.dart`
Expected: FAIL — import error.

- [ ] **Step 3: Create `lib/features/broadcaster/summary/broadcast_summary_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gold_glow_card.dart';
import '../../../providers/repository_providers.dart';

class BroadcastSummaryScreen extends ConsumerWidget {
  const BroadcastSummaryScreen({super.key, required this.streamId});
  final String streamId;

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours.toString().padLeft(2, '0')}:$mm:$ss'
        : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.read(broadcastRepositoryProvider).findById(streamId);
    if (stream == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.broadcasterDashboard);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final peak = stream.peakListenerCount;
    final avg = (peak * 0.7).round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: AppColors.successGreen, size: 56),
              const SizedBox(height: 8),
              Text('Broadcast Ended',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GoldGlowCard(
                child: Column(
                  children: [
                    _row(context, 'Duration', _format(stream.duration)),
                    const Divider(),
                    _row(context, 'Peak listeners', '$peak'),
                    const Divider(),
                    _row(context, 'Average listeners', '$avg'),
                    const Divider(),
                    _row(context, 'Audio quality', 'Excellent'),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(RouteNames.broadcasterDashboard),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                child: const Text('Done'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing not yet wired')),
                ),
                child: const Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Swap the placeholder in `lib/core/router/app_router.dart`**

Find:

```dart
      GoRoute(
        path: '${RouteNames.summaryPath}/:streamId',
        builder: (_, state) => _PlaceholderScreen(
          'Summary (placeholder) streamId=${state.pathParameters['streamId']}',
        ),
      ),
```

Replace with:

```dart
      GoRoute(
        path: '${RouteNames.summaryPath}/:streamId',
        builder: (_, state) => BroadcastSummaryScreen(
          streamId: state.pathParameters['streamId']!,
        ),
      ),
```

Add import:

```dart
import '../../features/broadcaster/summary/broadcast_summary_screen.dart';
```

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/broadcaster/summary/broadcast_summary_screen.dart lib/core/router/app_router.dart test/features/broadcaster/summary/broadcast_summary_screen_test.dart
git commit -m "feat(summary): assemble broadcast summary screen"
```

---

## Phase O — Integration test + final analyze (Tasks 38-39)

### Task 38: Happy-path integration test

**Files:**
- Create: `integration_test/broadcaster_happy_path_test.dart`

- [ ] **Step 1: Write the integration test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim_guider_pro/app.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_auth_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_broadcast_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_masjid_repository.dart';
import 'package:muslim_guider_pro/data/repositories/mock/mock_schedule_repository.dart';
import 'package:muslim_guider_pro/features/broadcaster/go_live/go_live_controller.dart';
import 'package:muslim_guider_pro/providers/mic_level_provider.dart';
import 'package:muslim_guider_pro/providers/repository_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Muadhin completes the broadcast loop end to end', (tester) async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      masjidRepositoryProvider.overrideWithValue(MockMasjidRepository()),
      broadcastRepositoryProvider.overrideWithValue(MockBroadcastRepository()),
      scheduleRepositoryProvider.overrideWithValue(MockScheduleRepository()),
      useFallbackMicProvider.overrideWithValue(true),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MuslimGuiderProApp(),
    ));
    await tester.pumpAndSettle();

    // 1. Sign in as Imam Yusuf.
    await tester.tap(find.text('Imam Yusuf Abdullah'));
    await tester.pumpAndSettle();
    expect(find.text('MUADHIN'), findsOneWidget);

    // 2. Navigate to Dashboard tab.
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Masjid Al-Abrar'), findsOneWidget);

    // 3. Slide-to-broadcast → Pre-Live.
    final pill = tester.getRect(find.text('SLIDE TO BROADCAST'));
    await tester.dragFrom(pill.centerLeft, Offset(pill.width + 60, 0));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Pre-Broadcast Check'), findsOneWidget);

    // 4. Force mic OK via debug button.
    await tester.tap(find.text('Debug: force mic OK'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 5. Continue → Live.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('LIVE'), findsOneWidget);

    // 6. End → confirm → Summary.
    await tester.tap(find.text('End Broadcast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End'));
    await tester.pumpAndSettle();
    expect(find.text('Broadcast Ended'), findsOneWidget);

    // 7. Done → back on Dashboard.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Masjid Al-Abrar'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the integration test on a device or emulator**

Run on a connected Android emulator or iOS simulator:
```
flutter test integration_test/broadcaster_happy_path_test.dart
```

Expected: PASS.

If running headless in CI, add a Flutter test driver step. For local development, the simulator path is sufficient.

- [ ] **Step 3: Commit**

```bash
git add integration_test/broadcaster_happy_path_test.dart
git commit -m "test: add broadcaster happy-path integration test"
```

---

### Task 39: Final analyze, coverage, and commit

**Files:** none (verification only)

- [ ] **Step 1: Run analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run all unit + widget tests with coverage**

Run: `flutter test --coverage`
Expected: all PASS.

Check the coverage line for `lib/data/` and `lib/features/broadcaster/` — both should be ≥70%. If not, add tests for the under-covered paths before moving on.

- [ ] **Step 3: Run the integration test**

Run: `flutter test integration_test/broadcaster_happy_path_test.dart` (on a simulator).
Expected: PASS.

- [ ] **Step 4: Validate the mock-isolation acceptance criterion**

Run: `grep -R "data/mock/" lib/ | grep -v "data/repositories/mock/"`
Expected: no output (only files inside `lib/data/repositories/mock/` import the fixtures).

If anything else imports `data/mock/`, fix it before declaring done.

- [ ] **Step 5: Final commit (only if you have uncommitted file changes from analyze cleanup)**

If `git status` shows changes:

```bash
git status
git add -A
git commit -m "chore: pre-merge cleanup after analyze and coverage"
```

Otherwise no commit needed.

---

## Self-review pass

When all 39 tasks are complete, walk the spec one more time and confirm:

- [ ] All 5 broadcaster screens exist (Home, Dashboard, Pre-Live, Live, Summary).
- [ ] Sign-in lists 3 mock users; tapping each routes to the correct landing screen.
- [ ] Bottom nav appears on Home, Dashboard, Nearby, Inbox, Me — NOT on Sign-In, Pre-Live, Live, Summary, Listener Home.
- [ ] Slide-to-broadcast requires ≥80% horizontal drag; partial drags spring back.
- [ ] Pre-Live's "Continue" button is disabled until mic permission is granted.
- [ ] Live screen's volume meter responds to ambient sound on a physical device.
- [ ] End Broadcast shows a confirmation dialog; confirming navigates to Summary; Done returns to Dashboard.
- [ ] Deleting `lib/data/mock/` causes a compile error in `lib/main.dart` only.
- [ ] `flutter analyze` is clean.
- [ ] `flutter test --coverage` is ≥70% across `lib/data/` and `lib/features/broadcaster/`.
- [ ] Integration happy-path passes on a simulator.

---

## Deferred follow-ups (optional, post-merge)

These items are referenced in the spec but not gated by §16 acceptance criteria, and they're best done once the design is visually locked in:

- **Golden tests for the 5 broadcaster screens** (spec §13.2). Add `test/goldens/*.png` baselines via `matchesGoldenFile` once the screens render correctly on a real device. Run `flutter test --update-goldens` to re-baseline.
- **CI workflow** (`.github/workflows/flutter.yml`) running `flutter analyze`, `flutter test --coverage`, and uploading the integration-test artefact. The spec's CI gates exist but the workflow file is not part of the v1 critical path.
- **Avatar / hero-image assets** (spec §17 open question). Decide whether to vendor 3 PNGs into `assets/images/` or use generated `CircleAvatar` placeholders; if vendoring, declare them under `flutter.assets:` in `pubspec.yaml`.

---

**END OF IMPLEMENTATION PLAN.** Ready to execute via `superpowers:subagent-driven-development` or `superpowers:executing-plans`.






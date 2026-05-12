# test/features/

Per-screen widget tests and golden tests, mirroring the `lib/features/` folder structure.

When you add a real screen test, place it at:
- `test/features/listener/home/home_listener_screen_test.dart` for the dashboard
- `test/features/listener/discovery/nearby_masjids_screen_test.dart` for nearby
- etc.

The top-level `test/widget_test.dart` is reserved for boot-the-app smoke tests; per-screen depth lives down here.

## Golden tests

When a screen's visual fidelity matters (any prototype-derived screen), prefer a golden test using `flutter_test`'s `matchesGoldenFile` matcher:

```dart
await expectLater(
  find.byType(HomeListenerScreen),
  matchesGoldenFile('goldens/home_listener.png'),
);
```

Update goldens with `flutter test --update-goldens`.

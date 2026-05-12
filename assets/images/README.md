# assets/images/

Bundled image assets — masjid hero photos, logos, fallback avatars, onboarding illustrations.

The prototype currently uses Google-hosted images. When we replace those with bundled assets, drop the PNG/JPG/SVG/WebP files in here, then add an `assets:` entry under `flutter:` in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

Naming convention: `kebab-case.png` matching the prototype HTML where the original lived (e.g. `masjid-al-abrar-hero.jpg`, `imam-yusuf-avatar.png`).

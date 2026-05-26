# Publishing checklist

## Before you publish

- Update `pubspec.yaml` metadata:
  - `description` (short)
  - add `homepage`, `repository`, `issue_tracker` (recommended)
  - confirm `version`
- Confirm `CHANGELOG.md` matches the version you’re publishing.
- Ensure `example/` runs (`flutter run`) and demonstrates the main features.

## Sanity checks

From the repo root:

```bash
dart format .
flutter analyze
dart pub publish --dry-run
```


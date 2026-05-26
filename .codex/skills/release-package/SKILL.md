# Skill: Release assistive_touch_overlay

Use this when preparing the package for a new release or pub.dev publish.

## Inputs to confirm

- Target version (e.g. `0.0.2`)
- Release notes bullets for `CHANGELOG.md`
- Repository/homepage URLs (for `pubspec.yaml`)

## Steps

1) Bump version in `pubspec.yaml`
2) Update `CHANGELOG.md` for the same version
3) Ensure `README.md` examples compile (keep imports correct)
4) Run checks:
   - `dart format .`
   - `flutter analyze`
   - `dart pub publish --dry-run`
5) Verify `example/` still runs: `cd example && flutter run`

## Output

- Report any analyzer errors or publish dry-run warnings.
- If checks pass, state the exact version and confirm the repo is publish-ready.


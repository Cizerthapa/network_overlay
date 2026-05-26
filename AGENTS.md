# Agent Notes (assistive_touch_overlay)

## Goal

This repo is a reusable Flutter package that provides:

- `AssistiveTouchOverlay`: draggable snap-to-edge floating bubble widget
- Optional Dio API inspector: interceptor + overlay bubble + list/detail UI

## Common commands

From repo root:

- Format: `dart format .`
- Analyze: `flutter analyze`
- Dry-run publish: `dart pub publish --dry-run`

Example app:

- Run: `cd example && flutter run`

## Where things live

- Public entrypoints: `lib/assistive_touch_overlay.dart`, `lib/api_inspector.dart`
- Overlay primitive: `lib/src/assistive_touch_overlay.dart`
- Inspector core: `lib/src/inspector/`
- Inspector UI: `lib/src/inspector/ui/`
- Docs: `README.md`, `doc/`

## Release checklist

See `doc/PUBLISHING.md`.


# Handoff: `assistive_touch_overlay`

## Goal

Turn our in-app “Assistive Touch” debug overlay + API Inspector into a reusable Flutter package that other projects can import.

This package should provide:

- A generic draggable/snap-to-edge floating bubble overlay (assistive touch style).
- A ready-to-use API Inspector built on Dio:
  - Dio interceptor to capture requests/responses/errors.
  - A floating overlay bubble that can be shown/hidden (toggle).
  - UI to view captured calls (list + detail).
  - Copy helpers (cURL + stack trace).
  - Error indication in the UI (bubble color + label + list title).
- Customization points (record duration, tick interval, label/badge behavior).

## Current State (Implemented)

### 1) Base overlay (reusable UI primitive)

- `lib/src/assistive_touch_overlay.dart`
  - `AssistiveTouchOverlay` (draggable + snap-to-edge + optional pulse animation passed to builder)
  - Does not depend on app-specific DI/navigation.

### 2) API Inspector (Dio + UI)

Entry exports:

- `lib/api_inspector.dart`

Core pieces:

- `lib/src/inspector/api_inspector_service.dart`
  - In-memory store for captured records.
  - Recording session semantics (accept in-flight calls by session id).
- `lib/src/inspector/api_inspector_interceptor.dart`
  - Records responses + errors (includes stack trace when available).
- `lib/src/inspector/api_inspector_controller.dart`
  - Manages “recording window” (timer), state updates, and opening the inspector UI.
  - Customization:
    - `recordingDurationSeconds`
    - `tickInterval`
    - `overlayVisibleListenable` and `setOverlayVisible(...)`

UI:

- `lib/src/inspector/ui/api_inspector_overlay.dart`
  - `ApiInspectorOverlay` that renders a bubble when `overlayVisibleListenable` is `true`.
  - Error indication:
    - Done-state turns orange/red if errors occurred.
    - Label shows `⚠ errorCount` when done.
  - Badge while recording:
    - `showRecordingBadge`, `badgeDiameter`, and `showRecordingErrorCountInBadge`.
  - Label customization:
    - `showSecondsInLabel`, `showRequestCountInLabel`, `showDoneErrorCountInLabel`.
- `lib/src/inspector/ui/api_calls_list_screen.dart`
  - Shows error count in the AppBar title.
- `lib/src/inspector/ui/api_call_detail_screen.dart`
  - “Copy cURL” button and “Copy stack trace” button when available.
  - Expandable sections include Request/Response/Error Message/Stack Trace.

Utility:

- `lib/src/inspector/util/curl_generator.dart`

## How to Use (in another app)

1) Create one shared store + controller:

- Create `final service = ApiInspectorService();`
- Create `final controller = ApiInspectorController(service: service, overlayVisible: true);`

2) Add interceptor to Dio:

- `dio.interceptors.add(ApiInspectorInterceptor(service));`

3) Add overlay bubble above the app:

- In `MaterialApp(builder: ...)` wrap `child` in a `Stack` and add:
  - `ApiInspectorOverlay(controller: controller)`

## Notes / Constraints

- Store is currently in-memory only (no persistence).
- Stack trace is only available when Dio provides it (e.g., errors thrown with stack trace).
- The inspector UI uses Material widgets and is intentionally dependency-light (no flutter_bloc/get_it).

## Next Work (Ideas / TODO)

- Provide an optional “settings” UI (toggle overlay on/off + set duration) inside the package.
- Allow customizing bubble visuals (colors, icons, label formatting) via callbacks.
- Add filters/search in list screen (status code, method, url contains).
- Add an explicit “Copy full debug info” (URL + error + cURL + bodies + stack trace) helper.
- Add tests for:
  - session id acceptance logic
  - interceptor records onResponse/onError behavior
- Add pub publishing metadata (homepage/repository, topics, screenshots) when ready.


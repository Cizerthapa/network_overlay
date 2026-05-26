# API Inspector (Dio)

The API inspector is a small, dependency-light debug UI for inspecting captured Dio calls.

## Pieces

- `ApiInspectorService`: in-memory store for captured `ApiCallRecord`s and capture session semantics.
- `ApiInspectorInterceptor`: Dio interceptor that records responses/errors.
- `ApiInspectorController`: manages capture windows + provides a simple tap-driven UX for the bubble.
- `ApiInspectorOverlay`: floating bubble UI (draggable/snap-to-edge).

## Basic setup

```dart
final service = ApiInspectorService();
final controller = ApiInspectorController(service: service, overlayVisible: true);

dio.interceptors.add(ApiInspectorInterceptor(service));
```

Render it above your app:

```dart
MaterialApp(
  builder: (context, child) => Stack(
    children: [
      if (child != null) child,
      ApiInspectorOverlay(controller: controller),
    ],
  ),
);
```

## Capture UX

- Tap bubble:
  - idle/done → starts recording
  - recording → stops recording
- If a capture has finished, tapping opens the list UI.

## Customization

Controller:

- `recordingDurationSeconds`: capture window length
- `tickInterval`: label update tick
- `initialPosition`: bubble starting position

Overlay:

- `bubbleSize`, `edgePadding`
- Label toggles: `showSecondsInLabel`, `showRequestCountInLabel`, `showDoneErrorCountInLabel`
- Recording badge: `showRecordingBadge`, `badgeDiameter`, `showRecordingErrorCountInBadge`

## Notes / limitations

- Storage is in-memory only (no persistence).
- Stack traces are captured only when Dio provides them.


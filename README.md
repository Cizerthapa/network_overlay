# assistive_touch_overlay

Assistive Touch-style draggable floating bubble overlay for Flutter (snap-to-edge + optional pulse), plus an optional Dio API inspector (interceptor + overlay UI).

📖 **[What is this & Why is it useful? (INTRO.md)](INTRO.md)**  
🛠️ **[Full Setup & Integration Guide (SETUP_GUIDE.md)](SETUP_GUIDE.md)**

- `AssistiveTouchOverlay`: reusable overlay primitive (no app-specific DI required)
- API inspector (Dio): `ApiInspectorService` + `ApiInspectorInterceptor` + `ApiInspectorController` + `ApiInspectorOverlay`


## Install

```yaml
dependencies:
  assistive_touch_overlay: ^0.0.1
```

## Example app

```bash
cd example
flutter pub get
flutter run
```

## AssistiveTouchOverlay (standalone)

`AssistiveTouchOverlay` must be placed under a `Stack` (it uses `AnimatedPositioned`).

```dart
import 'package:assistive_touch_overlay/assistive_touch_overlay.dart';
import 'package:flutter/material.dart';

Stack(
  children: [
    const MyScreen(),
    AssistiveTouchOverlay(
      isPulsing: true,
      onTap: () => debugPrint('tap'),
      builder: (context, pulseAnimation) {
        return ScaleTransition(
          scale: pulseAnimation,
          child: const _MyBubble(),
        );
      },
    ),
  ],
);
```

More: `doc/OVERLAY.md`.

## API Inspector (Dio)

1) Create one shared store + controller:

```dart
import 'package:assistive_touch_overlay/api_inspector.dart';

final service = ApiInspectorService();
final inspector = ApiInspectorController(service: service, overlayVisible: true);
```

2) Add the interceptor to Dio:

```dart
import 'package:dio/dio.dart';
import 'package:assistive_touch_overlay/api_inspector.dart';

final dio = Dio();
dio.interceptors.add(ApiInspectorInterceptor(service));
```

3) Render the overlay above your app:

```dart
import 'package:assistive_touch_overlay/api_inspector.dart';
import 'package:flutter/material.dart';

MaterialApp(
  builder: (context, child) {
    return Stack(
      children: [
        if (child != null) child,
        ApiInspectorOverlay(controller: inspector),
      ],
    );
  },
);
```

How it works:

- Tap the bubble to start capture (it pulses while recording).
- Make your API calls.
- When capture finishes (or you tap again to stop), tap once more to open the captured call list.

More: `doc/API_INSPECTOR.md`.

## Notes

- Storage is in-memory only (no persistence).
- Stack traces are captured only when Dio provides them.

## Credits & Special Thanks

A huge thank you to **Safal Shrestha** for his invaluable guidance, inspiration, and co-authoring contributions that helped bring this library to life!



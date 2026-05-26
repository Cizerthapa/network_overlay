# 🛠️ Full Setup & Integration Guide

This guide will walk you through the full setup for both the standalone **AssistiveTouch Floating Bubble** and the **Dio API Inspector**.

---

## 📦 Step 1: Install the Dependency

Add `assistive_touch_overlay` to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  assistive_touch_overlay: ^0.0.1
  dio: ^5.0.0 # Required for the network inspector
```

Run `flutter pub get` in your terminal to fetch the package.

---

## 🎨 Feature 1: Standalone Floating Bubble (`AssistiveTouchOverlay`)

If you want to use the raw draggable, snap-to-edge floating bubble for custom features (e.g. quick actions, feedback triggers, custom diagnostic menus), use `AssistiveTouchOverlay`.

### Implementation Example

Wrap your main screen or stack inside a `Stack` and place `AssistiveTouchOverlay` at the bottom of the children list:

```dart
import 'package:assistive_touch_overlay/assistive_touch_overlay.dart';
import 'package:flutter/material.dart';

class MyCustomDashboard extends StatelessWidget {
  const MyCustomDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your main application UI goes here
          const Center(
            child: Text('Main App Interface'),
          ),

          // Draggable snap-to-edge AssistiveTouch bubble
          AssistiveTouchOverlay(
            bubbleSize: 60.0,
            edgePadding: -15.0, // negative value lets the bubble sit slightly off-screen like iOS
            isPulsing: true, // Enables a gentle, beautiful scaling pulse animation
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bubble tapped!')),
              );
            },
            builder: (context, pulseAnimation) {
              return ScaleTransition(
                scale: pulseAnimation,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Tools',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 📡 Feature 2: Complete Dio API Inspector Integration

Setting up the network inspector requires connecting the **Dio Interceptor**, the **Controller**, and the **Overlay UI**.

### Step 2.1: Initialize the Controller & Service

Create a single instance of the Service and Controller. It is recommended to place this in your global state or near your dependency injection root.

```dart
import 'package:assistive_touch_overlay/api_inspector.dart';

// Create the backend store and state manager
final apiInspectorService = ApiInspectorService();
final apiInspectorController = ApiInspectorController(
  service: apiInspectorService,
  overlayVisible: true, // Show the bubble by default
);
```

### Step 2.2: Add the Interceptor to your Dio Instance

Register the `ApiInspectorInterceptor` with your shared `Dio` instance:

```dart
import 'package:dio/dio';
import 'package:assistive_touch_overlay/api_inspector.dart';

final dio = Dio();

// Attach the interceptor to collect requests
dio.interceptors.add(ApiInspectorInterceptor(apiInspectorService));
```

### Step 2.3: Place the Overlay in your MaterialApp Builder

Mount the `ApiInspectorOverlay` globally above your entire navigation tree using the `builder` parameter of `MaterialApp`. This keeps the bubble floating on top of all pages in your app.

```dart
import 'package:assistive_touch_overlay/api_inspector.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Network App',
      home: const HomeScreen(),
      
      // Global overlay builder
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            
            // The API Inspector floating bubble
            ApiInspectorOverlay(
              controller: apiInspectorController,
              showRecordingBadge: true, // Show a badge with error counts while recording
              badgeDiameter: 16.0,
            ),
          ],
        );
      },
    );
  }
}
```

---

## 🛡️ Release-Mode Hardening (Safety & Performance)

We have built safety directly into the package:
1. **The Interceptor** automatically bypasses network recording in release mode (`kReleaseMode`), ensuring zero performance overhead in production.
2. **The Overlay UI** automatically renders an empty `SizedBox.shrink()` in release mode so it completely disappears from production builds.

For maximum clean code hygiene, you can also avoid instantiating the controller and interceptor entirely in release mode:

```dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio';
import 'package:assistive_touch_overlay/api_inspector.dart';

final dio = Dio();

if (!kReleaseMode) {
  final apiInspectorService = ApiInspectorService();
  dio.interceptors.add(ApiInspectorInterceptor(apiInspectorService));
}
```

---

## ⚙️ Customization Options

You can customize almost all characteristics of the overlay and session through `ApiInspectorController` and `ApiInspectorOverlay`:

| Configuration Property | Location | Description | Default |
| :--- | :--- | :--- | :--- |
| `recordingDurationSeconds` | `ApiInspectorController` | How long the recording window lasts before auto-stopping | `20` |
| `initialPosition` | `ApiInspectorController` | Starting screen offset of the bubble | `Offset(-20, 200)` |
| `bubbleSize` | `ApiInspectorOverlay` | Size of the floating circle in pixels | `60.0` |
| `showSecondsInLabel` | `ApiInspectorOverlay` | Displays the remaining countdown time in the bubble | `true` |
| `showRequestCountInLabel` | `ApiInspectorOverlay` | Displays the total request count inside the bubble | `true` |

## 🚀 Advanced Integration Patterns

### 1. State Management & DI Integration (GetIt / Riverpod)
In larger production applications, instead of global variables, you should manage your inspector using standard dependency injection or state management architectures:

#### GetIt Setup (Highly Recommended)
```dart
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:assistive_touch_overlay/api_inspector.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (!kReleaseMode) {
    getIt.registerSingleton<ApiInspectorService>(ApiInspectorService());
    getIt.registerSingleton<ApiInspectorController>(
      ApiInspectorController(service: getIt<ApiInspectorService>()),
    );
  }
}
```

#### Riverpod Setup
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistive_touch_overlay/api_inspector.dart';

final apiInspectorServiceProvider = Provider<ApiInspectorService>((ref) {
  return ApiInspectorService();
});

final apiInspectorControllerProvider = Provider<ApiInspectorController>((ref) {
  final service = ref.watch(apiInspectorServiceProvider);
  return ApiInspectorController(service: service);
});
```

---

### 2. Gesture-Triggered Visibility (Shake or Multi-tap)
If you don't want the floating bubble to be permanently visible in your dev builds, you can hide it by default and toggle its visibility using custom gestures (like a shake or a secret double-tap on your logo):

```dart
import 'package:flutter/material.dart';

// Example: Secret triple-tap to toggle visibility
GestureDetector(
  onTapDown: (details) {
    if (details.kind == PointerDeviceKind.touch) {
      // Logic for tracking triple taps or custom gestures
    }
  },
  child: MyLogoWidget(),
);

// Toggle visibility programmatically from anywhere:
apiInspectorController.toggleOverlayVisible();
```

---

### 3. Flavor-Based Environments
For apps using build flavors (e.g. `dev`, `staging`, `prod`), configure the overlay to only instantiate and render on `dev` and `staging` pipelines:

```dart
import 'package:flutter/material.dart';
import 'my_app_config.dart'; // Contains environment config (e.g. AppEnvironment.prod)

// Global overlay builder
builder: (context, child) {
  final showDebugTools = AppConfig.environment != AppEnvironment.prod;

  return Stack(
    children: [
      if (child != null) child,
      if (showDebugTools)
        ApiInspectorOverlay(controller: apiInspectorController),
    ],
  );
}
```

---

## 💡 How to Use the UI (On-Device Flow)

1. **Start Capture**: Tap the floating bubble (it will turn **red** and begin **pulsing** to show it is actively capturing requests).
2. **Make Requests**: Perform your actions or tap buttons in your app to trigger API requests.
3. **Finish Capture**: Wait for the countdown timer to expire, or tap the bubble again to manually stop recording.
4. **Open Logs**: Once stopped, the bubble will turn **green** (or **orange/red** if errors occurred). Tap it once more to open the scrollable **API Calls List Screen**.
5. **Inspect & Copy**: Tap any request card to see full query params, headers, response bodies, and generated **cURL** command strings.

### 🌟 Credits
Special thanks to **Safal Shrestha** for the design and co-creation of these interactive flows!

# Introduction to AssistiveTouch Overlay & API Inspector 🚀

Welcome to `assistive_touch_overlay`! This Flutter library was designed to solve a very common and painful problem in mobile app development: **how to easily debug network requests and UI shortcuts directly on-device without tethering to a laptop or setting up complex proxy tools.**

Co-authored and inspired by **Safal Shrestha**, this package provides a premium, interactive, and zero-overhead solution for developers and QA engineers.

---

## 🧐 What is this?

This library contains two core, highly reusable features:

1. **`AssistiveTouchOverlay`**: A premium, draggable, snap-to-edge floating bubble widget modeled after the classic iOS AssistiveTouch. It has smooth drag-and-drop physics, snaps seamlessly to the nearest screen edge, and supports dynamic micro-animations (like pulsing scale transitions).
2. **Dio API Inspector**: A zero-setup, on-device network logger. It pairs the floating overlay bubble with a Dio interceptor. You tap the bubble to start recording network traffic, and tap it again when finished to instantly view detailed logs of headers, request/response bodies, status codes, response durations, and even auto-generated `cURL` commands for quick replication.

---

## 🌟 Why is it incredibly useful?

### 1. On-Device Wireless Debugging (No Laptops, No Proxies)
Usually, to inspect API traffic, you need to plug your device into a computer, run a proxy tool like Charles, Proxyman, or Flipper, install SSL certificates, and configure Wi-Fi settings. 
With this library, **your debugging tool lives entirely inside your app.** QA testers, product managers, or you yourself can test the app on a device anywhere (like a café or during a meeting) and inspect network payloads on the spot.

### 2. Micro-Animations & Dynamic UI
Mobile debugging tools are notoriously ugly and dry. We wanted this tool to feel *alive*:
* The bubble pulses in scale and glows red when actively recording API calls.
* It snaps gracefully to the screen edge when dragged, just like the real iOS AssistiveTouch.
* It features error count badges to immediately alert you if an API call fails while recording.

### 3. Fail-Safe for Production (Zero Release Overhead)
You never want debugging utilities to slow down your production app or leak sensitive credentials to real users. 
* **The Interceptor**: Automatically becomes a transparent pass-through in Release Mode (`kReleaseMode`), ensuring **zero performance overhead** in production.
* **The Overlay UI**: Automatically intercepts the build tree and returns an empty `SizedBox.shrink()` in release mode, ensuring it never displays or consumes rendering resources for your real users.

### 4. Modular & Pure Dart/Flutter
Unlike other heavy network inspectors, `assistive_touch_overlay` is extremely lightweight. It depends only on `dio` and standard Flutter. It does not force you to use any state management library or heavy system overlays.

---

## 🛠️ Typical Use Cases

* **QA Bug Reporting**: A tester encounters a bug. Instead of describing "the screen failed," they tap the inspector bubble, copy the exact failed API response or cURL command, and paste it directly into Jira.
* **Offline/Field Testing**: Inspecting API status and payloads when you are away from your desk and don't have access to console logs.
* **Custom Floating Menus**: Using the raw `AssistiveTouchOverlay` to build custom floating widgets, floating support/chat bubbles, debug-menu triggers, or shortcuts.

---

### ➔ Next Steps
To integrate this into your project in minutes, check out the [Full Setup Guide (SETUP_GUIDE.md)](file:///Users/cizer/Downloads/assistive_touch_overlay/SETUP_GUIDE.md).

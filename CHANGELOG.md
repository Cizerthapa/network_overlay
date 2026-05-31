## 0.0.3

- **Auto-navigate to captured calls**: The inspector now automatically opens the API calls list screen when recording stops — whether the capture window times out or the user taps to stop manually. Previously, the list only appeared if the user knew to tap the bubble a second time after recording ended.

## 0.0.2

- **Release-Mode Protection**: Automatically hide the `ApiInspectorOverlay` in release mode (`kReleaseMode`) so it never renders or consumes overhead in production.
- **Dependency Tightening**: Tightened the lower bound of `dio` to `^5.9.2` to ensure complete compatibility with `DioException` under package downgrade testing.
- **Rich Documentation**: Added detailed `INTRO.md` and a comprehensive `SETUP_GUIDE.md` covering advanced patterns like Dependency Injection (GetIt, Riverpod), environment flavor integration, and secret gesture triggers.
- **Attribution & Credits**: Dedicated prominent credits and co-author headers to Safal Shrestha.

## 0.0.1

- Initial release.


## 1.4.0

- **Behaviour change (Android):** `free` is now the space available to apps (`StatFs.getAvailableBytes()`), matching iOS. It used to include blocks reserved for the system (`getFreeBytes()`), so `free` is now slightly lower, `used` slightly higher, and `lowOnSpace` can trigger a little sooner

## 1.3.0

- Add Swift Package Manager support for iOS (Flutter 3.44+). CocoaPods is still supported
- Add an iOS privacy manifest declaring the disk space required-reason APIs
- Add `getAppStorageUsage()` for the space used by the app itself (#10)
- Rewrite the Android plugin in Java, so it no longer depends on a Kotlin version
- Build against Android compileSdk 36, and support apps on AGP 8 and AGP 9
- iOS plugin is now pure Swift
- Clean up the podspec: real metadata, and replace the legacy x86_64-only simulator setting
- Fix human-readable sizes losing zeros when `fractionDigits` is 0 (10 B was shown as "1 B")
- Requires Flutter 3.24+ / Dart 3.5+ and iOS 13+

## 1.2.0

- Update namespace, jvm version and compile sdk version to support latest Android versions
- Fix for incorrect reporting of total space in iOS

## 1.1.0

- Update kotlin version to 1.5.31

## 1.0.1+4

Typo in example

## 1.0.1+3

Renaming some things

## 1.0.1

Fix for incorrect reporting of total space in android

## 1.0.0+2

Better readme

## 1.0.0+1

Better documentation

## 1.0.0

Initial Release

- Null-Safe
- Full DartDoc Comments
- Utility helpers

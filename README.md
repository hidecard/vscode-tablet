# VS Code Tablet

A Flutter Android shell that runs **openvscode-server locally inside a standalone APK**—without requiring Termux. The app embeds an Android `arm64-v8a` Node.js runtime, extracts the server bundle on first launch, starts it in a background thread, and opens it at `127.0.0.1:8080` inside an in-app WebView.

> **Status: experimental starter.** This repository contains the integration source and build wiring. It does not include `libnode.so` or the openvscode-server distribution. Those artifacts must be built, licensed, and copied locally before an APK can be produced.

## Features

- Flutter tablet UI with a VS Code-style dark loading screen
- Embedded Node.js entry point through JNI/C++
- First-run extraction with a version marker
- Localhost server readiness polling before WebView launch
- Android storage permission request for user workspaces
- arm64-only baseline configuration

## Project layout

```text
android/app/src/main/
├── cpp/CMakeLists.txt
├── cpp/native-lib.cpp
├── jniLibs/arm64-v8a/libnode.so       # provide locally; ignored by Git
└── kotlin/com/example/tablet_vscode/MainActivity.kt
assets/vscode/                          # provide server bundle; ignored by Git
lib/main.dart
```

## Prerequisites

- Flutter 3.x and Android SDK/NDK with CMake
- An Android arm64 device or emulator
- An Android-compatible `libnode.so` exporting `node::Start`
- An openvscode-server bundle whose `out/server-main.js` and native addons work with Android Bionic

## Setup

1. Create a Flutter project or copy these files into an existing Flutter Android project.
2. Put `libnode.so` at `android/app/src/main/jniLibs/arm64-v8a/libnode.so`.
3. Put the openvscode-server files under `assets/vscode/`, including `out/server-main.js`.
4. Add the CMake `externalNativeBuild` block and `arm64-v8a` ABI filter to `android/app/build.gradle(.kts)`.
5. Add the Gradle and manifest snippets in [`docs/android-config.md`](docs/android-config.md), only where your Android distribution policy permits it.
6. Run `flutter pub get` and `flutter build apk --target-platform android-arm64`.

## Important compatibility notes

- Linux x64/arm64 glibc native addons such as `node-pty` or `@vscode/spdlog` can crash on Android Bionic. Rebuild them with the Android NDK or replace them with Android-compatible modules.
- `MANAGE_EXTERNAL_STORAGE` is restricted by Google Play policy. Prefer the Storage Access Framework for a Play-distributed app.
- The default workspace is `/storage/emulated/0/Documents`; change it if your app uses a scoped-storage design.
- The JNI symbol includes `_1` for the underscore in `tablet_vscode`. If you change the package name, update the exported JNI function name too.
- The app currently supports one ABI. Add matching `libnode.so` builds and ABI filters before supporting more devices.

## License and third-party software

This integration source is provided under the MIT License. openvscode-server, Node.js, Flutter packages, and native modules remain subject to their own licenses. Review and ship their license notices with any release.

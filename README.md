# VS Code Tablet

A Flutter Android shell that runs **openvscode-server locally inside a standalone APK**—without requiring Termux. The app embeds an Android `arm64-v8a` Node.js runtime, extracts the server bundle on first launch, starts it in a background thread, and opens it at `127.0.0.1:8080` inside an in-app WebView.

> **Status: experimental starter.** This repository contains the integration source and build wiring. It does not include `libnode.so` or the openvscode-server distribution. Those artifacts must be built, licensed, and copied locally before an APK can be produced.

## Features

- Flutter tablet UI with a VS Code-style dark loading screen
- Embedded Node.js entry point through JNI/C++
- First-run extraction with a version marker
- Localhost server readiness polling before WebView launch
- App-private workspace that works without broad storage permission
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
2. Run `bash scripts/fetch-nodejs-mobile.sh` to download the official Node.js Mobile Android package and stage its `arm64-v8a` `libnode.so` plus headers.
3. Run `bash scripts/fetch-openvscode-assets.sh` to download the pinned OpenVSCode Server release and stage `out/server-main.js` plus UI assets.
4. Add the CMake `externalNativeBuild` block and `arm64-v8a` ABI filter to `android/app/build.gradle(.kts)`.
5. Add the Gradle and manifest snippets in [`docs/android-config.md`](docs/android-config.md), only where your Android distribution policy permits it.
6. Run `flutter pub get` and `flutter build apk --target-platform android-arm64`.

## Automated APK build

Use the repository script to generate missing Flutter Android wrapper files, stage the official arm64 Node.js Mobile runtime, configure CMake/ABI settings, and build a release APK:

```bash
bash scripts/build-apk.sh
```

The output is written under `build/app/outputs/flutter-apk/`. The build script downloads both runtime packages automatically. Set `KEEP_RUNTIME=1` if you want to keep the downloaded runtime and assets after the build.

The app now starts with an app-private workspace under `filesDir/workspace`, so it does not block startup when broad storage permission is denied. A future Storage Access Framework picker can grant access to user-selected folders without changing the startup flow. The OpenVSCode release still contains Linux arm64 native addons; `node-pty` and `@vscode/spdlog` must be rebuilt for Android Bionic before production use.

The build script also applies the temporary AGP 9 compatibility property required by the current `flutter_inappwebview_android` release plugin. It is written to `android/gradle.properties` only when missing.

GitHub Actions builds the same arm64 release APK when you push a `v*` tag or start **Build Android APK** manually from the Actions tab. The resulting APK is uploaded as a workflow artifact for 14 days.

The official Node.js Mobile Android package provides Android shared libraries and headers, but it does **not** provide an Android build of openvscode-server. The upstream OpenVSCode Server project documents Linux/Docker distributions; its Linux native addons cannot simply be copied into an Android APK. Building the server bundle and modules for Android Bionic remains a separate required step.

## Important compatibility notes

- Linux x64/arm64 glibc native addons such as `node-pty` or `@vscode/spdlog` can crash on Android Bionic. Rebuild them with the Android NDK or replace them with Android-compatible modules.
- `MANAGE_EXTERNAL_STORAGE` is restricted by Google Play policy. Prefer the Storage Access Framework for a Play-distributed app.
- The default workspace is `/storage/emulated/0/Documents`; change it if your app uses a scoped-storage design.
- The JNI symbol includes `_1` for the underscore in `tablet_vscode`. If you change the package name, update the exported JNI function name too.
- The app currently supports one ABI. Add matching `libnode.so` builds and ABI filters before supporting more devices.

## License and third-party software

This integration source is provided under the MIT License. openvscode-server, Node.js, Flutter packages, and native modules remain subject to their own licenses. Review and ship their license notices with any release.

## Upstream references

- [Node.js Mobile Android getting started](https://nodejs-mobile.github.io/docs/guide/guide-android/getting-started/)
- [Node.js Mobile Android releases](https://github.com/nodejs-mobile/nodejs-mobile/releases)
- [OpenVSCode Server](https://github.com/gitpod-io/openvscode-server)

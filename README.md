# VS Code Tablet

A Flutter Android shell that runs **openvscode-server locally inside a standalone APK**—without requiring Termux. The app embeds an Android `arm64-v8a` Node.js runtime, extracts the server bundle on first launch, starts it in a background thread, and opens it at `127.0.0.1:8080` inside an in-app WebView.

> **Status: experimental.** The editor server starts from a correctly built APK (see "Automated APK build" below). The integrated terminal and native file watcher do not work yet: their native modules are Linux glibc binaries, and rebuilding them for Android Bionic is still open work. Do not build with plain `flutter build apk` — that skips the asset fetch and produces an APK that fails on first launch with `Missing .../out/server-main.js`.

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

The output is written under `build/app/outputs/flutter-apk/`. The build script downloads both runtime packages automatically and verifies the staged server bundle (it must contain `assets/vscode/out/server-main.js` and more than 1000 files) **before** running `flutter build apk`, so a build can fail loudly instead of producing an APK that only fails on the tablet. Set `KEEP_RUNTIME=1` if you want to keep the downloaded runtime and assets after the build.

> Do not run `flutter build apk` directly: `assets/vscode/` is gitignored (only `.gitkeep` is in the repo), so a direct build bundles an empty folder. Always use `bash scripts/build-apk.sh`, which (re)stages the assets first.

The app now starts with an app-private workspace under `filesDir/workspace`, so it does not block startup when broad storage permission is denied. A future Storage Access Framework picker can grant access to user-selected folders without changing the startup flow. On first launch the app extracts the bundled server assets to `filesDir/vscode/` and only marks the extraction complete after verifying `out/server-main.js` exists; if extraction fails or the entry point is missing, the incomplete output is removed so Retry re-extracts instead of failing forever on a stale marker.

## What works without the Linux native modules

The bundled OpenVSCode Server v1.109.5 (linux-arm64, 3091 files) still contains Linux glibc native modules — `node-pty` (`pty.node`), `@vscode/spdlog` (`spdlog.node`), `@parcel/watcher` (`watcher.node`), `@vscode/native-watchdog` and `kerberos` all link `libc.so.6` / `libpthread.so.0`, which Android Bionic does not provide. Verified by running the staged `out/server-main.js` with a system Node on a Linux host: the server binds `127.0.0.1`, serves the workbench HTML (HTTP 200), and the `@vscode/spdlog` load failure is caught and logged (`ERR_DLOPEN_FAILED`) while the server keeps running. So the **editor starts without the native modules**; the **integrated terminal** (`node-pty`, loaded only when a terminal is opened) and the **native file watcher** (`@parcel/watcher`) will not work until those modules are rebuilt for Android Bionic with the NDK. That rebuild is still open work — do not expect terminal support from the current APK. (The host test was not an Android run: it used an x86_64 host Node, so the arm64 `.node` files could not load there either; on-device verification on an arm64 tablet is still needed.)

The build script also applies the temporary AGP 9 compatibility property required by the current `flutter_inappwebview_android` release plugin. It is written to `android/gradle.properties` only when missing.

GitHub Actions builds the same arm64 release APK when you push a `v*` tag or start **Build Android APK** manually from the Actions tab. The resulting APK is uploaded as a workflow artifact for 14 days.

The official Node.js Mobile Android package provides Android shared libraries and headers, but it does **not** provide an Android build of openvscode-server. The upstream OpenVSCode Server project documents Linux/Docker distributions; its Linux native addons cannot simply be copied into an Android APK. Building the server bundle and modules for Android Bionic remains a separate required step.

## Important compatibility notes

- Linux arm64 glibc native addons such as `node-pty`, `@vscode/spdlog` and `@parcel/watcher` cannot load on Android Bionic (they link `libc.so.6` / `libpthread.so.0`). The main server starts without them — the spdlog load is caught — but the integrated terminal and native file watcher will not work until they are rebuilt with the Android NDK or replaced with Android-compatible modules.
- `MANAGE_EXTERNAL_STORAGE` is restricted by Google Play policy. Prefer the Storage Access Framework for a Play-distributed app.
- The default workspace is the app-private `filesDir/workspace` folder (not `/storage/emulated/0/Documents`).
- The JNI symbol includes `_1` for the underscore in `tablet_vscode`. If you change the package name, update the exported JNI function name too.
- The app currently supports one ABI. Add matching `libnode.so` builds and ABI filters before supporting more devices.

## License and third-party software

This integration source is provided under the MIT License. openvscode-server, Node.js, Flutter packages, and native modules remain subject to their own licenses. Review and ship their license notices with any release.

## Upstream references

- [Node.js Mobile Android getting started](https://nodejs-mobile.github.io/docs/guide/guide-android/getting-started/)
- [Node.js Mobile Android releases](https://github.com/nodejs-mobile/nodejs-mobile/releases)
- [OpenVSCode Server](https://github.com/gitpod-io/openvscode-server)

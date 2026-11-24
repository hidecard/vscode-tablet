#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

command -v flutter >/dev/null 2>&1 || {
  echo "Flutter SDK is required. Install Flutter and ensure flutter is on PATH." >&2
  exit 1
}

PROJECT_NAME="tablet_vscode"
TEMP_PROJECT=""
KEEP_RUNTIME="${KEEP_RUNTIME:-0}"

cleanup() {
  if [[ -n "${TEMP_PROJECT}" && -d "${TEMP_PROJECT}" ]]; then rm -rf "${TEMP_PROJECT}"; fi
  if [[ "${KEEP_RUNTIME}" != "1" ]]; then
    rm -rf "${ROOT}/.runtime-cache" "${ROOT}/libnode"
    rm -f "${ROOT}/android/app/src/main/jniLibs/arm64-v8a/libnode.so"
  fi
}
trap cleanup EXIT

# The repository stores the custom Android sources but not generated Flutter wrapper files.
if [[ ! -f android/settings.gradle && ! -f android/settings.gradle.kts ]]; then
  TEMP_PROJECT="$(mktemp -d)"
  flutter create --platforms=android --org com.example --project-name "${PROJECT_NAME}" --no-pub "${TEMP_PROJECT}"
  cp -Rn "${TEMP_PROJECT}/android/." android/
fi

bash scripts/fetch-nodejs-mobile.sh
# Always (re)stage the server assets, not only when server-main.js is
# missing: a stale or partial assets/vscode/ directory would otherwise be
# bundled silently and only fail on the tablet with
# "Missing .../out/server-main.js". The fetch is cached (the archive is
# reused when already downloaded), so this is cheap on rebuilds.
bash scripts/fetch-openvscode-assets.sh

# Fail fast here, before `flutter pub get` / `flutter build apk`, if the
# staged bundle is incomplete. An APK must never be produced without the
# server assets it needs to start.
[[ -f assets/vscode/out/server-main.js ]] || { echo "OpenVSCode Server assets were not prepared: assets/vscode/out/server-main.js is missing after fetch." >&2; exit 1; }
ASSET_FILE_COUNT="$(find assets/vscode -type f | wc -l)"
[[ "${ASSET_FILE_COUNT}" -gt 1000 ]] || { echo "OpenVSCode Server assets look incomplete: only ${ASSET_FILE_COUNT} files in assets/vscode/." >&2; exit 1; }

# Add the native build wiring once, supporting both Flutter Gradle dialects.
if [[ -f android/app/build.gradle.kts ]]; then
  if ! grep -q 'src/main/cpp/CMakeLists.txt' android/app/build.gradle.kts; then
    cat >> android/app/build.gradle.kts <<'KOTLIN'

// VS Code Tablet native Node.js bridge.
android {
    defaultConfig {
        ndk {
            abiFilters.clear()
            abiFilters += listOf("arm64-v8a")
        }
        externalNativeBuild {
            cmake { arguments += "-DANDROID_STL=c++_shared" }
        }
    }
    externalNativeBuild {
        cmake { path = file("src/main/cpp/CMakeLists.txt") }
    }
}
KOTLIN
  fi
elif [[ -f android/app/build.gradle ]]; then
  if ! grep -q 'src/main/cpp/CMakeLists.txt' android/app/build.gradle; then
    cat >> android/app/build.gradle <<'GROOVY'

// VS Code Tablet native Node.js bridge.
android {
    defaultConfig {
        ndk {
            abiFilters.clear()
            abiFilters.add("arm64-v8a")
        }
        externalNativeBuild {
            cmake { arguments "-DANDROID_STL=c++_shared" }
        }
    }
    externalNativeBuild {
        cmake { path "src/main/cpp/CMakeLists.txt" }
    }
}
GROOVY
  fi
else
  echo "Flutter Android Gradle file was not generated." >&2
  exit 1
fi

# flutter_inappwebview_android 1.1.3 still references the legacy
# proguard-android.txt file, which AGP 9 rejects by default. This is the
# documented temporary escape hatch until the plugin migrates to the
# optimized default file.
touch android/gradle.properties
if ! grep -q '^android\.r8\.proguardAndroidTxt\.disallowed=' android/gradle.properties; then
  printf '\nandroid.r8.proguardAndroidTxt.disallowed=false\n' >> android/gradle.properties
fi

flutter pub get

[[ -f assets/vscode/out/server-main.js ]] || { echo "OpenVSCode Server assets were not prepared." >&2; exit 1; }

flutter build apk --release --target-platform android-arm64
APK="$(find build/app/outputs/flutter-apk -maxdepth 1 -type f -name '*.apk' | head -1)"
[[ -n "${APK}" ]] || { echo "APK output was not found." >&2; exit 1; }
printf '\nAPK built successfully: %s\n' "${APK}"

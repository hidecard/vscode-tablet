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

# Add the native build wiring once, supporting both Flutter Gradle dialects.
if [[ -f android/app/build.gradle.kts ]]; then
  if ! grep -q 'src/main/cpp/CMakeLists.txt' android/app/build.gradle.kts; then
    cat >> android/app/build.gradle.kts <<'KOTLIN'

// VS Code Tablet native Node.js bridge.
android {
    defaultConfig {
        ndk { abiFilters += listOf("arm64-v8a") }
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
        ndk { abiFilters "arm64-v8a" }
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

flutter pub get

if [[ ! -f assets/vscode/out/server-main.js ]]; then
  echo "WARNING: assets/vscode/out/server-main.js is missing. The APK can build, but the app will show a server error until an Android-compatible OpenVSCode Server bundle is added." >&2
fi

flutter build apk --release --target-platform android-arm64
APK="$(find build/app/outputs/flutter-apk -maxdepth 1 -type f -name '*.apk' | head -1)"
[[ -n "${APK}" ]] || { echo "APK output was not found." >&2; exit 1; }
printf '\nAPK built successfully: %s\n' "${APK}"

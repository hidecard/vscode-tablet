#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
  "pubspec.yaml"
  "lib/main.dart"
  "android/app/src/main/cpp/CMakeLists.txt"
  "android/app/src/main/cpp/native-lib.cpp"
  "android/app/src/main/kotlin/com/example/tablet_vscode/MainActivity.kt"
  "scripts/fetch-nodejs-mobile.sh"
  "scripts/fetch-openvscode-assets.sh"
  "scripts/build-apk.sh"
  ".github/workflows/build-apk.yml"
)
for file in "${required[@]}"; do
  [[ -s "${ROOT}/${file}" ]] || { echo "Missing or empty: ${file}" >&2; exit 1; }
done

grep -q "com.example.tablet_vscode/server" "${ROOT}/lib/main.dart"
grep -q "com.example.tablet_vscode/server" "${ROOT}/android/app/src/main/kotlin/com/example/tablet_vscode/MainActivity.kt"
grep -q "Java_com_example_tablet_1vscode_MainActivity_startNodeWithArguments" "${ROOT}/android/app/src/main/cpp/native-lib.cpp"
grep -q "arm64-v8a" "${ROOT}/scripts/fetch-nodejs-mobile.sh"
grep -q "out/server-main.js" "${ROOT}/android/app/src/main/kotlin/com/example/tablet_vscode/MainActivity.kt"
grep -q "WillPopScope" "${ROOT}/lib/main.dart"
grep -q "Retry" "${ROOT}/lib/main.dart"
grep -q "proguardAndroidTxt.disallowed=false" "${ROOT}/scripts/build-apk.sh"
# Regression checks for the missing-server-main.js failure (2026-11-24):
# the extraction marker must only be created after server-main.js is
# verified, a stale marker must trigger re-extraction, and the build
# must verify the staged assets before producing an APK.
grep -q '!marker.exists() || !entry.isFile' "${ROOT}/android/app/src/main/kotlin/com/example/tablet_vscode/MainActivity.kt"
grep -q 'copyAssetFolder.*: Int' "${ROOT}/android/app/src/main/kotlin/com/example/tablet_vscode/MainActivity.kt"
grep -q 'tar --no-same-owner' "${ROOT}/scripts/fetch-openvscode-assets.sh"
grep -q 'fetch-openvscode-assets.sh' "${ROOT}/.github/workflows/build-apk.yml"
grep -q 'test -f assets/vscode/out/server-main.js' "${ROOT}/.github/workflows/build-apk.yml"
grep -q 'ASSET_FILE_COUNT' "${ROOT}/scripts/build-apk.sh"
grep -q 'ASSET_FILE_COUNT' "${ROOT}/scripts/fetch-openvscode-assets.sh"

bash -n "${ROOT}/scripts/fetch-nodejs-mobile.sh"
bash -n "${ROOT}/scripts/fetch-openvscode-assets.sh"
bash -n "${ROOT}/scripts/build-apk.sh"
bash -n "${ROOT}/scripts/verify-source.sh"
printf '%s\n' 'Source verification passed.'

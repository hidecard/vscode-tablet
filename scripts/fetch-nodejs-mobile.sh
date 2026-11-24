#!/usr/bin/env bash
set -euo pipefail

VERSION="${NODEJS_MOBILE_VERSION:-v18.20.4}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${ROOT}/.runtime-cache"
ZIP="${WORK}/nodejs-mobile-${VERSION}-android.zip"
URL="https://github.com/nodejs-mobile/nodejs-mobile/releases/download/${VERSION}/nodejs-mobile-${VERSION}-android.zip"

mkdir -p "${WORK}"
if [[ ! -f "${ZIP}" ]]; then
  curl --fail --location --retry 3 --output "${ZIP}" "${URL}"
fi
rm -rf "${WORK}/unpacked"
unzip -q "${ZIP}" -d "${WORK}/unpacked"

LIB="${WORK}/unpacked/bin/arm64-v8a/libnode.so"
INCLUDE="${WORK}/unpacked/include/node"
[[ -f "${LIB}" ]] || { echo "Missing ${LIB}" >&2; exit 1; }
[[ -d "${INCLUDE}" ]] || { echo "Missing ${INCLUDE}" >&2; exit 1; }

mkdir -p "${ROOT}/android/app/src/main/jniLibs/arm64-v8a" "${ROOT}/libnode"
cp "${LIB}" "${ROOT}/android/app/src/main/jniLibs/arm64-v8a/libnode.so"
rm -rf "${ROOT}/libnode/include"
mkdir -p "${ROOT}/libnode/include"
cp -R "${WORK}/unpacked/include/node" "${ROOT}/libnode/include/"

echo "Installed Node.js Mobile ${VERSION} arm64 runtime."
echo "Next: provide an Android-compatible openvscode-server bundle under assets/vscode/."

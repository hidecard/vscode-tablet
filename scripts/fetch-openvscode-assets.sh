#!/usr/bin/env bash
set -euo pipefail

VERSION="${OPENVSCODE_SERVER_VERSION:-openvscode-server-v1.109.5}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${ROOT}/.runtime-cache/openvscode"
ARCHIVE="${WORK}/${VERSION}-linux-arm64.tar.gz"
URL="https://github.com/gitpod-io/openvscode-server/releases/download/${VERSION}/${VERSION}-linux-arm64.tar.gz"
DEST="${ROOT}/assets/vscode"

mkdir -p "${WORK}"
if [[ ! -f "${ARCHIVE}" ]]; then
  curl --fail --location --retry 3 --output "${ARCHIVE}" "${URL}"
fi
rm -rf "${WORK}/unpacked"
mkdir -p "${WORK}/unpacked"
tar -xzf "${ARCHIVE}" -C "${WORK}/unpacked"
SOURCE="$(find "${WORK}/unpacked" -mindepth 1 -maxdepth 1 -type d -print -quit)"
[[ -n "${SOURCE}" ]] || { echo "OpenVSCode Server archive has no root directory" >&2; exit 1; }
[[ -f "${SOURCE}/out/server-main.js" ]] || { echo "OpenVSCode Server archive has no out/server-main.js" >&2; exit 1; }

rm -rf "${DEST}"
mkdir -p "${DEST}"
cp -R "${SOURCE}/." "${DEST}/"
# The APK starts Node through libnode.so, not the release's Linux launcher.
rm -f "${DEST}/bin/openvscode-server"
rm -rf "${DEST}/bin/remote-cli"

printf 'Prepared OpenVSCode Server %s assets at %s\n' "${VERSION}" "${DEST}"
printf '%s\n' 'Warning: bundled native .node modules are Linux arm64 artifacts. Rebuild node-pty/spdlog for Android Bionic before production use.'

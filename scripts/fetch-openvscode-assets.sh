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
# --no-same-owner: the release tarball records uid/gid 1001, and restoring
# ownership fails (and, under `set -e`, aborts the script before the assets
# are copied) when run as a different user, e.g. root in a container.
tar --no-same-owner -xzf "${ARCHIVE}" -C "${WORK}/unpacked"
SOURCE="$(find "${WORK}/unpacked" -mindepth 1 -maxdepth 1 -type d -print -quit)"
[[ -n "${SOURCE}" ]] || { echo "OpenVSCode Server archive has no root directory" >&2; exit 1; }
[[ -f "${SOURCE}/out/server-main.js" ]] || { echo "OpenVSCode Server archive has no out/server-main.js" >&2; exit 1; }

rm -rf "${DEST}"
mkdir -p "${DEST}"
# Keep the tracked .gitkeep: wiping DEST above would otherwise delete it
# from the working copy on every fetch/build.
touch "${DEST}/.gitkeep"
cp -R "${SOURCE}/." "${DEST}/"
# The APK starts Node through libnode.so, not the release's Linux launcher.
rm -f "${DEST}/bin/openvscode-server"
rm -rf "${DEST}/bin/remote-cli"

# Fail loudly here, at fetch time, if the staged bundle is incomplete --
# otherwise the failure only surfaces on the tablet as
# "Missing .../out/server-main.js" after the APK is built and installed.
[[ -f "${DEST}/out/server-main.js" ]] || { echo "Staged OpenVSCode Server assets are missing out/server-main.js" >&2; exit 1; }
ASSET_FILE_COUNT="$(find "${DEST}" -type f | wc -l)"
[[ "${ASSET_FILE_COUNT}" -gt 1000 ]] || { echo "Staged OpenVSCode Server assets look incomplete: only ${ASSET_FILE_COUNT} files in ${DEST}" >&2; exit 1; }

printf 'Prepared OpenVSCode Server %s assets at %s (%s files)\n' "${VERSION}" "${DEST}" "${ASSET_FILE_COUNT}"
printf '%s\n' 'Warning: bundled native .node modules are Linux arm64 glibc artifacts (they link libc.so.6 / libpthread.so.0, which Android Bionic does not provide). The main server still starts without them -- the spdlog logger load is caught and falls back -- but the integrated terminal (node-pty) and the native file watcher (@parcel/watcher) will not work until those modules are rebuilt for Android Bionic. The editor itself is unaffected.'

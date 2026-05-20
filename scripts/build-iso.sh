#!/usr/bin/env bash
# Build Velvet OS ISO on Fedora using Docker or Podman.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/output"
VERSION="${VELVET_VERSION:-1.0}"
ISO_NAME="velvet-os-${VERSION}-x86_64.iso"
IMAGE="quay.io/fedora/fedora:41"

if [ -n "${CONTAINER_ENGINE:-}" ]; then
  ENGINE="${CONTAINER_ENGINE}"
elif command -v docker >/dev/null 2>&1; then
  ENGINE="docker"
elif command -v podman >/dev/null 2>&1; then
  ENGINE="podman"
else
  echo "Install Docker or Podman first." >&2
  exit 1
fi

# SELinux :Z only for local Podman; breaks on GitHub Actions / Docker Desktop
VOL_SUFFIX=""
if [ "${CI:-}" != "true" ] && [ "$ENGINE" = "podman" ]; then
  VOL_SUFFIX=":Z"
fi

mkdir -p "${OUT}"

echo "==> Using ${ENGINE}"
echo "==> Pulling builder image ${IMAGE}"
"${ENGINE}" pull "${IMAGE}"

echo "==> Building ISO (this takes 45-90 minutes)..."
"${ENGINE}" run --rm --privileged \
  -v "${ROOT}:/velvet${VOL_SUFFIX}" \
  -v "${OUT}:/out${VOL_SUFFIX}" \
  -e VELVET_VERSION="${VERSION}" \
  "${IMAGE}" bash -ec "
    set -euxo pipefail
    dnf install -y lorax pykickstart git curl wget unzip
    mkdir -p /run/velvet-branding
    cp -a /velvet/branding/* /run/velvet-branding/
    sed 's/\r$//' /velvet/kickstart/velvet-fedora.ks > /tmp/velvet.ks
    livemedia-creator \
      --make-iso \
      --ks=/tmp/velvet.ks \
      --resultdir=/out/build \
      --project=Velvet \
      --releasever=41 \
      --iso-only \
      --iso-name=${ISO_NAME} \
      --volid=VELVET_OS \
      --no-virt
    ISO=\$(find /out/build -name '*.iso' | head -1)
    test -n \"\${ISO}\"
    cp -f \"\${ISO}\" /out/${ISO_NAME}
    ls -lh /out/${ISO_NAME}
  "

echo ""
echo "Done: ${OUT}/${ISO_NAME}"

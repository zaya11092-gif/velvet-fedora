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

VOL_SUFFIX=""
if [ "${CI:-}" != "true" ] && [ "$ENGINE" = "podman" ]; then
  VOL_SUFFIX=":Z"
fi

mkdir -p "${OUT}"
sudo mkdir -p /run/velvet-branding 2>/dev/null || true
sudo cp -a "${ROOT}/branding/." /run/velvet-branding/ 2>/dev/null || cp -a "${ROOT}/branding/." /tmp/velvet-branding/

BRANDING_MOUNT=()
if [ -d /run/velvet-branding ]; then
  BRANDING_MOUNT=(-v /run/velvet-branding:/run/velvet-branding:ro)
fi

echo "==> Using ${ENGINE}"
"${ENGINE}" pull "${IMAGE}"

echo "==> Building ISO (45-90 minutes)..."
"${ENGINE}" run --rm --privileged \
  -v "${ROOT}:/velvet${VOL_SUFFIX}" \
  -v "${OUT}:/out${VOL_SUFFIX}" \
  "${BRANDING_MOUNT[@]}" \
  -w /velvet \
  "${IMAGE}" bash -ecx "
    dnf install -y lorax pykickstart git curl wget dos2unix
    dos2unix kickstart/velvet-fedora.ks
    mkdir -p output/build
    livemedia-creator \
      --make-iso \
      --no-virt \
      --ks=kickstart/velvet-fedora.ks \
      --resultdir=output/build \
      --project=Velvet \
      --releasever=41 \
      --iso-only \
      --iso-name=${ISO_NAME} \
      --volid=VELVET_OS \
      --logfile=output/lmc.log
    cp -f output/build/${ISO_NAME} /out/${ISO_NAME}
    ls -lh /out/${ISO_NAME}
  "

echo "Done: ${OUT}/${ISO_NAME}"

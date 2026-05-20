#!/usr/bin/env bash
# Build Velvet OS ISO on Fedora using Podman (works on Fedora host or WSL2 with podman).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KS="${ROOT}/kickstart/velvet-fedora.ks"
OUT="${ROOT}/output"
BRANDING="${ROOT}/branding"
VERSION="${VELVET_VERSION:-1.0}"
ISO_NAME="velvet-os-${VERSION}-x86_64.iso"
IMAGE="quay.io/fedora/fedora:41"

mkdir -p "${OUT}"
command -v podman >/dev/null || { echo "Install podman first."; exit 1; }

echo "==> Pulling builder image ${IMAGE}"
podman pull "${IMAGE}"

echo "==> Building ISO (this takes 45–90 minutes)..."
podman run --rm --privileged \
  -v "${ROOT}:/velvet:Z" \
  -v "${OUT}:/out:Z" \
  -e VELVET_VERSION="${VERSION}" \
  "${IMAGE}" bash -ec "
    set -euxo pipefail
    dnf install -y lorax lorax-lmc-novirt pykickstart git curl wget
    mkdir -p /run/velvet-branding
    cp -a /velvet/branding/* /run/velvet-branding/
    cp /velvet/kickstart/velvet-fedora.ks /tmp/velvet.ks
    # Inject branding path for %post
    sed -i 's|cp -f /root/velvet-branding|cp -f /run/velvet-branding|g' /tmp/velvet.ks || true
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
    cp -f \"\${ISO}\" /out/${ISO_NAME}
    ls -lh /out/${ISO_NAME}
  "

echo ""
echo "Done: ${OUT}/${ISO_NAME}"
echo "Flash with: sudo dd if=${OUT}/${ISO_NAME} of=/dev/sdX bs=4M status=progress"

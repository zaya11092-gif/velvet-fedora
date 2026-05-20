# Velvet OS

A Fedora-based desktop Linux spin with a dark, minimal GNOME look—custom wallpaper, Orchis GTK theme, Papirus icons, Inter typography, and tuned shell settings.

## Download the ISO

**Option A — GitHub Actions (recommended on Windows)**  
Push this repo to GitHub, open **Actions → Build Velvet ISO → Run workflow**, then download the `velvet-os-*-x86_64.iso` artifact when the job finishes (~45–90 minutes).

**Option B — Build locally (Linux or WSL2)**  
From the repo root:

```bash
./scripts/build-iso.sh
```

The ISO is written to `output/velvet-os-<version>-x86_64.iso`.

## Install

1. Flash the ISO with [Fedora Media Writer](https://fedoraproject.org/workstation/download/), [Rufus](https://rufus.ie), or `dd`.
2. Boot the USB drive (UEFI recommended).
3. Use **Install to Hard Drive** on the live desktop, or try Velvet from the live session.

## What's customized

- GNOME 47+ dark mode and accent `#7C6AF7`
- Orchis Dark Compact GTK + libadwaita theme
- Papirus-Dark icons
- Inter UI + JetBrains Mono
- Blur-friendly panel and dock layout via dconf
- Plymouth "moon" splash (dark)
- `/etc/os-release` branding as **Velvet OS** (Fedora base)

## Requirements to build

- ~30 GB free disk, 8 GB+ RAM
- Root or passwordless sudo (local build)
- Fedora 41+ host, or Podman/Docker with `--privileged` as in `scripts/build-iso.sh`

## Legal

Velvet OS is an unofficial remix. Fedora® is a trademark of Red Hat, Inc. This project is not affiliated with Fedora Project or Red Hat.

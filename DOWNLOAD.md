# Get your Velvet OS ISO

Velvet OS is built from this repo — there is no pre-hosted ISO until you run a build (or GitHub Actions produces one).

## Fastest path on your PC (Windows)

Your machine has **WSL enabled but no Linux distro yet**. Install one, then build:

### 1. Install Ubuntu (Admin PowerShell)

```powershell
wsl --install Ubuntu-24.04
```

Restart if prompted, create a Linux username/password when Ubuntu opens.

### 2. Build the ISO (~45–90 minutes, ~30 GB disk)

In **PowerShell**:

```powershell
cd C:\Users\user\Projects\velvet-fedora
.\scripts\build-iso.ps1
```

### 3. Your download

When the build finishes, the ISO is here:

```
C:\Users\user\Projects\velvet-fedora\output\velvet-os-1.0-x86_64.iso
```

Copy it anywhere, flash with [Rufus](https://rufus.ie) or [Fedora Media Writer](https://fedoraproject.org/workstation/download/), and boot.

---

## Build on GitHub (get a download link in the browser)

1. Create a new GitHub repo and push this folder.
2. Open **Actions → Build Velvet ISO → Run workflow**.
3. When the job completes, open the run and download artifact **velvet-os-1.0-x86_64-iso**.

That artifact **is** your `.iso` download link (valid 14 days per run).

---

## Build on a Fedora machine

```bash
git clone <your-repo-url> velvet-fedora && cd velvet-fedora
chmod +x scripts/build-iso.sh
./scripts/build-iso.sh
```

ISO: `output/velvet-os-1.0-x86_64.iso`

---

## Live USB default login

The live session user is `velvet` / password `velvet` (change after installing to disk).

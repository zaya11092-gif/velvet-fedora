# Build Velvet OS ISO on Windows via WSL2 + Fedora Podman
param(
    [string]$Version = "1.0"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$WslRoot = wsl wslpath -a $Root

Write-Host "Velvet OS ISO build"
Write-Host "Project: $Root"
Write-Host ""

$wslList = wsl -l -q 2>$null
if (-not $wslList) {
    Write-Host "WSL2 is required. Install: wsl --install -d FedoraLinux-41"
    exit 1
}

Write-Host "Starting build inside WSL (45-90 min)..."
wsl -e bash -lc "cd '$WslRoot' && chmod +x scripts/build-iso.sh && VELVET_VERSION='$Version' ./scripts/build-iso.sh"

$iso = Join-Path $Root "output\velvet-os-$Version-x86_64.iso"
if (Test-Path $iso) {
    Write-Host ""
    Write-Host "ISO ready: $iso"
    Write-Host "Size: $((Get-Item $iso).Length / 1GB) GB"
} else {
    Write-Host "Build finished but ISO not found at expected path. Check output/ folder."
}

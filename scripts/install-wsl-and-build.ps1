#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Installs Ubuntu 24.04 WSL, then builds Velvet OS ISO.
.NOTES
  Needs ~30 GB free space and 45-90 minutes for the ISO step.
#>
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Write-Host "Installing Ubuntu 24.04 for WSL..."
wsl --install Ubuntu-24.04

Write-Host ""
Write-Host "If Windows asked for a reboot, restart, open Ubuntu once to create your user, then run:"
Write-Host "  cd $Root"
Write-Host "  .\scripts\build-iso.ps1"

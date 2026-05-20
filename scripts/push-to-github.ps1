# Push Velvet OS to GitHub (run after creating empty repo on GitHub)
$git = "C:\Program Files\Git\cmd\git.exe"
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repo

$remote = "https://github.com/zaya11092-gif/velvet-fedora.git"
& $git remote set-url origin $remote
Write-Host "Pushing to $remote ..."
Write-Host "If prompted, sign in to GitHub (browser or Personal Access Token)."
& $git push -u origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Done. Open: https://github.com/zaya11092-gif/velvet-fedora"
    Write-Host "Then: Actions -> Build Velvet ISO -> Run workflow"
}

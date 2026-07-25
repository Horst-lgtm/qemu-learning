# Read-only Windows-side environment check for QEMU/Firecracker learning.
[CmdletBinding()]
param()

$Ok = 0
$Info = 0

function Show-Section([string]$Name) { Write-Host "`n== $Name ==" }
function Show-Ok([string]$Message) {
    $script:Ok++
    Write-Host "[OK]   $Message" -ForegroundColor Green
}
function Show-Info([string]$Message) {
    $script:Info++
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}
function Get-FirstOutputLine([string]$Command, [string[]]$Arguments) {
    $output = & $Command @Arguments 2>&1
    return ($output | Select-Object -First 1)
}
function Test-Tool([string]$Name, [string[]]$VersionArguments) {
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        Show-Info "$Name not found on Windows PATH"
        return
    }
    $line = Get-FirstOutputLine $command.Source $VersionArguments
    Show-Ok "${Name}: $line"
}

Show-Section "Windows host"
Write-Host "OS:   $([System.Environment]::OSVersion.VersionString)"
Write-Host "arch: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"

Show-Section "WSL"
$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($null -eq $wsl) {
    Show-Info "wsl.exe not found; WSL appears unavailable"
} else {
    Show-Ok "wsl.exe is available"
    $status = & wsl.exe --status 2>&1
    if ($LASTEXITCODE -eq 0) {
        $status | ForEach-Object { Write-Host "  $_" }
    } else {
        Show-Info "WSL status could not be read; install/start a Linux distribution first"
    }
}

Show-Section "Windows-side tools"
Test-Tool "qemu-system-x86_64.exe" @("--version")
Test-Tool "rustc.exe" @("--version")
Test-Tool "cargo.exe" @("--version")
Test-Tool "firecracker.exe" @("--version")
Test-Tool "git.exe" @("--version")

Show-Section "Interpretation"
Write-Host @"
- Windows-native QEMU may use TCG or WHPX; WHPX is not Linux KVM.
- Firecracker targets Linux/KVM. A Windows firecracker.exe is normally not expected.
- WSL2 is recommended for source/build exercises, but /dev/kvm must be checked inside Linux.
- Run: wsl -- bash ./experiments/00-env-check/check-env.sh
- This script only reads versions and status; it changes no configuration.
"@

Write-Host "`nSummary: $Ok checks OK, $Info informational gaps."
exit 0

# Local helper for an existing, independently configured native Android build.
# Does not contain or fetch game data, and does not reconstruct missing sources.
[CmdletBinding()]
param(
    [switch]$Build,
    [switch]$Install,
    [switch]$Inspect,
    [switch]$Mods,
    [switch]$CaptureLog,
    [string]$OutputLog = $(Join-Path $env:TEMP "fnv-device-log.txt")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function RequiredEnv([string]$Name) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Set the environment variable $Name before running this operation."
    }
    return $value
}

function ADB([string[]]$Arguments) {
    & $script:AdbExecutable -s $script:DeviceSerial @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ADB failed: $($Arguments -join ' ')"
    }
}

if (-not ($Build -or $Install -or $Inspect -or $Mods -or $CaptureLog)) {
    Write-Host "Usage: ./tools/Local-Workflow.ps1 -Build | -Install | -Inspect | -Mods | -CaptureLog"
    Write-Host "Required for -Build: FNV_BUILD_SCRIPT, FNV_APK"
    Write-Host "Required for device operations: FNV_ADB, FNV_SERIAL (optional FNV_PACKAGE)"
    exit 0
}

if ($Build) {
    $buildScript = RequiredEnv "FNV_BUILD_SCRIPT"
    $apkPath = RequiredEnv "FNV_APK"
    if (-not (Test-Path -LiteralPath $buildScript -PathType Leaf)) {
        throw "Local build script does not exist: $buildScript"
    }

    # Back up the existing APK before the local build overwrites its output.
    if (Test-Path -LiteralPath $apkPath -PathType Leaf) {
        $dir = Split-Path -Parent $apkPath
        $backupDir = Join-Path $dir "Backups"
        New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $base = [IO.Path]::GetFileNameWithoutExtension($apkPath)
        $backup = Join-Path $backupDir "$base-$stamp.apk"
        Copy-Item -LiteralPath $apkPath -Destination $backup -ErrorAction Stop
        Write-Host "Previous APK backed up in the local Backups folder."
    }

    Write-Host "Running existing local native build..."
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $buildScript
    if ($LASTEXITCODE -ne 0) { throw "Native build failed. APK installation cancelled." }
    if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
        throw "Build completed but the expected APK was not found."
    }
    Write-Host "Build command finished. Gameplay verification is still required."
}

if ($Install -or $Inspect -or $Mods -or $CaptureLog) {
    $AdbExecutable = RequiredEnv "FNV_ADB"
    $DeviceSerial = RequiredEnv "FNV_SERIAL"
    $Package = [Environment]::GetEnvironmentVariable("FNV_PACKAGE")
    if ([string]::IsNullOrWhiteSpace($Package)) {
        $Package = "com.mojave.nativeedition"
    }
    if (-not (Test-Path -LiteralPath $AdbExecutable -PathType Leaf)) {
        throw "ADB executable not found."
    }
    ADB -Arguments @("get-state")
}

if ($Install) {
    $apkPath = RequiredEnv "FNV_APK"
    if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
        throw "Expected APK missing: $apkPath"
    }
    Write-Host "Installing update without clearing application data..."
    ADB -Arguments @("install", "-r", $apkPath)
    Write-Host "Install complete. Verify that the correct app opens and your saves work."
}

if ($Inspect) {
    Write-Host "Checking package and game-data directories..."
    ADB -Arguments @("shell", "pm", "path", $Package)
    ADB -Arguments @("shell", "run-as", $Package, "ls", "-ld", "files/game", "files/game/Data")
    Write-Host "A release build may deny run-as; that is not proof of missing game files."
}

if ($Mods) {
    Write-Host "Launcher mod order (+ is enabled):"
    ADB -Arguments @("shell", "run-as", $Package, "cat", "files/game/AndroidMods/order.txt")
    Write-Host "Mod files in store:"
    ADB -Arguments @("shell", "run-as", $Package, "find", "files/game/AndroidMods", "-type", "f")
    Write-Host "Deployed game Data listing:"
    ADB -Arguments @("shell", "run-as", $Package, "ls", "-la", "files/game/Data")
}

if ($CaptureLog) {
    $parent = Split-Path -Parent $OutputLog
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Write-Host "Capturing device logs privately. Start the game; press Ctrl+C to stop."
    & $AdbExecutable -s $DeviceSerial logcat -b main,system,crash -v threadtime |
        Out-File -FilePath $OutputLog -Encoding utf8
}

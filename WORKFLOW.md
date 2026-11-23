# Working development workflow — 2026-11-23

This is a **local development record**, not a complete buildable repository. The modified native source and tested APK remain on the developer's Windows PC.

## Local paths

| Purpose | Location |
|---|---|
| Modified independent source | `E:\FNVOwn` |
| Build scripts | `E:\New folder (2)\FalloutNewVegasAndroid\Build\Scripts` |
| Built test APK | `E:\FNVOwnOutput\NewVegasNative-Test.apk` |
| Game-data OBB (local only) | `E:\FNVOwnOutput\main.162.com.mojave.nativeedition.obb` |
| ADB | `E:\AndroidADB\platform-tools\adb.exe` |
| Android package ID | `com.mojave.nativeedition` |
| Honor test device | ADB serial `A9VUCP5715409006` |

## Preserve the working baseline

1. Copy the current APK to a timestamped local backup.
2. Save a backup/snapshot of the modified source, especially `InputOverlay.java`, `ProbeActivity.java`, `android/startup.c`, `recomp/host/android_graphics.c` and `recomp/host/sm2msl.c`.
3. Preserve the tested Stage 74 depth fix, custom Mojave HUD, menu mouse dragging, keyboard, `~` console, and working USE key.
4. Do **not** uninstall the app, wipe app data, or retransmit the ~9.2 GB OBB unnecessarily.
5. Modify only one cause at a time, retain an easy rollback APK, and measure the new build on the phone.

### Build

```powershell
$folder = "E:\New folder (2)\FalloutNewVegasAndroid\Build\Scripts"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$folder\Build-NewVegas-CustomLauncher.ps1"
if ($LASTEXITCODE -ne 0) { throw "Build failed; do not install." }
```

### Install over the existing application

```powershell
$adb = "E:\AndroidADB\platform-tools\adb.exe"
$serial = "A9VUCP5715409006"
& $adb -s $serial install -r "E:\FNVOwnOutput\NewVegasNative-Test.apk"
if ($LASTEXITCODE -ne 0) { throw "Installation failed." }
```

The package ID and signing key must match the installed APK to preserve its app data.

### Capture a live crash

Start logging **before** launching the game. Leave PowerShell open while playing; after the crash, press Ctrl+C and upload the saved log.

```powershell
$adb = "E:\AndroidADB\platform-tools\adb.exe"
$serial = "A9VUCP5715409006"
& $adb -s $serial logcat -c
& $adb -s $serial logcat -b main,system,crash -v threadtime |
    Out-File "E:\FNVOwnOutput\FNV-Full-Crash.txt" -Encoding utf8
```

Use unfiltered logs first; `FNVCall`, `FNVGraphics`, `FNVProbe`, `libc`, `DEBUG` and `AndroidRuntime` may all matter. A null-function-pointer message alone is not the caller/backtrace. Stage 27 needs both GL and EGL error codes to distinguish failures.

## Device regression checklist

- [ ] Main menu loads; mouse cursor can drag and select Continue.
- [ ] Load a save, move, aim, fire, jump, and USE/Activate.
- [ ] Pip-Boy opens and closes; MAP from TOOLS reaches DATA/map navigation.
- [ ] NPC conversation can scroll and exit via Goodbye normally.
- [ ] `~` console and `KB` are accessible during play.
- [ ] HIDE makes HUD art invisible without unintended menu presses; SHOW restores controls.
- [ ] Save and reload works.
- [ ] At least 10 minutes of gameplay without Stage 27 or null-function-pointer crashes.

## FPS measurement plan

Reported performance: about **7–10 FPS at 1920×1080 / High textures**; earlier scenes/builds sometimes ~15 FPS. These are not controlled comparisons.

For a credible comparison, benchmark the same outdoor saved location, camera angle, texture level and resolution. Compare 1920×1080/High with the lowest available resolution/Low, then profile the ARM64 game thread, Direct3D translation, OpenGL ES framebuffer copies and `eglSwapBuffers` latency. Instrument actual milliseconds; don't assume that lowering resolution will solve CPU/render-command overhead.

**Do not claim an FPS increase until it is reproduced on the Honor during gameplay.**

## Later GitHub source upload

This repository currently holds documentation only. Before uploading modified source, review the upstream license and required notices. Keep the original game assets and executables, the OBB, full APK, signing keys, crash logs, personal data and large build outputs out of GitHub.

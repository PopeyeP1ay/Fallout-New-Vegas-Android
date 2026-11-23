# Complete development workflow

**Status:** workflow for the customized local Android ARM64 build. The full modified source, required build tools and tested APK remain local; they are not currently in this repository. Commands shown here are reusable templates, not a claim that CI can compile the game.

## 1. Preserve the working version

- Keep a separate copy of the currently playable APK and its matching signing material.
- Back up modified source and your working launcher, touch HUD, graphics renderer and startup bridge.
- Preserve the tested control layout and menu cursor behavior, console/keyboard access, and working USE input.
- Back up user saves before experimenting with mods or content import.
- Never use `pm clear`, uninstall the game, or delete the original game archives as a routine update step.

## 2. Configure local tools without hard-coded paths

In Windows PowerShell 5.1, set these **for your current shell** to locations on your own computer:

```powershell
$env:FNV_BUILD_SCRIPT = Read-Host "Path to the existing build script"
$env:FNV_APK          = Read-Host "Path where the APK is or will be built"
$env:FNV_ADB          = Read-Host "Path to adb.exe"
$env:FNV_SERIAL       = Read-Host "Device serial from adb devices"
$env:FNV_PACKAGE      = "com.mojave.nativeedition"
```

Supply your actual local paths privately when prompted. The output APK does not have to exist before a build, but the build script must be present. Avoid publishing your serial, local paths, secrets or crash logs.

The wrapper `tools/Local-Workflow.ps1` does not replace the actual local native build script and does not reconstruct missing source. It invokes the already-working local build procedure.

## 3. Build and install

From the repository directory, use the helper when local prerequisites are configured:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -Build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -Install
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -Inspect
```

- The helper backs up the APK at the configured output path **before** invoking the build script if it already exists.
- A successful local build must produce the expected APK; the helper refuses to install a missing file.
- Installation uses `adb install -r`, not uninstall/reinstall. The package identity and signing certificate must match the existing installation to preserve app data.
- A successful build or installation **does not** prove gameplay works; device testing is required.

Do not replace the known-good APK until you have a backup and a recovery path.

## 4. Import game content once

The Android launcher imports a locally supplied game-data archive into app-private storage. The installed layout includes `files/game/FalloutNV.exe`, `files/game/Fallout_default.ini`, and required `files/game/Data/` assets.

After successful import and extraction, subsequent APK updates normally launch using those same installed game files. **Do not reimport the OBB/ZIP solely to activate a mod or change an APK.** Reimport only if the launcher reports missing/corrupt base files or if you intentionally update the asset dataset.

Game files belong to the user and are **never** included in this repository.

## 5. Install and test mods

See [MODS.md](MODS.md). Create a ZIP with compatible `Data/*.esm`, `Data/*.esp`, and associated supported assets, and import it using **Game Content → Mods → Import ZIP**. Enable the mod, select **Done**, then **Play**. Verify the deployment and enablement from the device before interpreting FPS.

Do not install alternative merged/modular variants of the same plugin together. Test one mod at a time and compare the same saved scene.

## 6. Verify the installed app without destructive commands

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -Inspect
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -Mods
```

The device can be accessible with `run-as` in a debuggable build. Release builds may not permit it. Use launcher or application logs if `run-as` is unavailable.

## 7. Capture failures and profile performance

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -CaptureLog
```

Run logging before launching the game. Press Ctrl+C to stop collection. The output contains device information and is for **private debugging**, not committing.

For FPS tests, keep the same save, location, camera angle, resolution, texture setting, and mod loadout. Log mean FPS, frame time, draw calls, game-thread CPU samples, driver CPU time, and any shader or texture-related synchronization. Test one change at a time.

**Known observations:** roughly 7–9 FPS outdoors in building-heavy areas, ~11 FPS in a cluttered interior, and ~30 FPS in a simpler interior. Earlier native traces showed heavy game-thread execution and driver overhead. Loose texture transfer and exterior occlusion have **not** produced observed FPS gains.

## 8. Regression checklist

- [ ] Launcher opens and the correct game assets are recognized.
- [ ] Existing save loads without another content import.
- [ ] Menu cursor can drag and activate buttons.
- [ ] Move, aim, fire, jump and USE work.
- [ ] Pip-Boy, MAP navigation, keyboard and console are usable.
- [ ] Conversation scrolling, selection and Goodbye work.
- [ ] HUD show/hide does not leave unwanted active hitboxes.
- [ ] Audio/music, world rendering, and save/reload work.
- [ ] At least 10 minutes of play without graphics or guest-execution crashes.
- [ ] Baseline and candidate FPS measured with controlled settings.

## 9. GitHub workflow and release boundary

`.github/workflows/verify-repository.yml` runs repository hygiene checks on commits and pull requests. It rejects tracked game assets, binaries, signing materials and machine-specific absolute paths in documentation/scripts. This is **not** a complete native APK CI pipeline: the private, locally modified code and build dependencies have not yet been published.

Before any future source upload, confirm redistribution rights, preserve all required licenses and notices, review for private paths/keys, and ensure builds are reproducible without uploading proprietary game files. Never publish OBBs or executable-derived private payloads.

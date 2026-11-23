# Mod installation and controlled performance testing

This customized launcher supports importing compatible game mods as ZIP archives. A successful import and a checked box are **not** proof of improved performance.

## Install workflow

1. Download a mod from its official distribution page and check its requirements and compatibility.
2. Extract it locally and inspect for `.esm`, `.esp`, `.bsa`, and extra assets.
3. Exclude Windows DLLs, native script-extender plugins, executables, or incompatible tool installers.
4. Create a ZIP with each plugin at the ZIP root or beneath `Data/`; matching assets must keep their relative paths.
5. On the Android launcher, open **Game Content → Mods → Import ZIP** and select the ZIP from device storage.
6. Enable the imported entry, tap **Done**, then **Play**. Do not reimport game content or the OBB as part of mod installation.
7. Check the same save/scene at the same resolution and graphics settings, and compare FPS before/after.
8. Disable a mod before testing the next one if you need to isolate its effect. Back up saves before mod experiments.

## Tested/assembled performance mods

| Local ZIP | Expected content | Observed state |
| --- | --- | --- |
| `01-PerformanceForThePeople.zip` | `Data/PFTP - Merged.esm` | Imported and shown enabled in launcher order. No observed FPS improvement. |
| `02-PerformanceOfTheTitans.zip` | `Data/PerformanceOfTheTitans.esm`, `Data/PerformanceOfTheTitans.bsa` | ZIP assembled; device activation and FPS result not verified. |
| `03-PerformanceOfTheGods.zip` | `Data/Performance Of The Gods.esp` | ZIP assembled; device activation and FPS result not verified. |

For PFTP, choose the full merged plugin **or** an alternative merged/modular selection, not overlapping variants in the same loadout. Verify the correct dependency masters before enabling any mod. Review conflicts before combining mods that touch identical cells or geometry.

## Verify imported and deployed plugins

With ADB configured, use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "./tools/Local-Workflow.ps1" -Mods
```

A `+` line in `AndroidMods/order.txt` means the launcher considers that pack enabled. After Play, the original mod deployment implementation may link plugin files into the game `Data` directory. Distinguish **imported**, **enabled**, **deployed**, and **actually affecting gameplay**; these are separate checks.

A filename containing spaces must be quoted as part of a single remote ADB shell command, for example:

```powershell
& $env:FNV_ADB -s $env:FNV_SERIAL shell "run-as $env:FNV_PACKAGE ls -l 'files/game/Data/PFTP - Merged.esm'"
```

`run-as` requires a debuggable app and can be unavailable in release builds.

## Notes about loose texture replacements

Two locally reduced DDS groups totalling 9,725 files were transferred into the app-private `Data/textures` folder. Their presence was verified, but the user reported **no visual or FPS difference**. Do not interpret a successful transfer as proof that the game uses loose overrides. Prefer a controlled asset-override test and native draw-call profiling before processing more textures.

## Rollback

Uncheck an imported mod in the launcher and tap Done, then restart the game. Keep original archives and installed content unchanged. To restore gameplay after a regression, return to the baseline load order or the saved APK and save backup. Do **not** clear app data to undo a mod.

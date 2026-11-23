# Release and verification checklist

This repository does not currently contain a redistributable, complete native build.

## Source and dependencies

- [ ] All source intended for publication has been reviewed for redistribution rights.
- [ ] All required license and notice files for included third-party code are retained intact.
- [ ] No original game executables, archives, media, saves or proprietary generated code are included.
- [ ] Build scripts refer to variables and documented prerequisites, not local absolute paths.
- [ ] No signing keys, tokens, device IDs, user data, full crash logs, private paths or credentials are tracked.
- [ ] Compiler/NDK/JDK/SDK versions and dependencies are pinned once a reproducible source build is available.

## Build integrity

- [ ] Current known-good APK and modified source are backed up.
- [ ] Local build exits successfully and produces the intended package.
- [ ] Signing certificate matches the installed app for non-destructive update.
- [ ] `adb install -r` succeeds without uninstalling or clearing data.
- [ ] Launching the app does not trigger unnecessary reimport of already-installed game content.
- [ ] Existing save games and imported game data remain readable.

## Gameplay

- [ ] Main menu, Continue and scene load work.
- [ ] Movement, aiming, firing, USE and menu cursor work.
- [ ] Custom HUD show/hide and input areas behave correctly.
- [ ] Keyboard, console, Pip-Boy, MAP, dialogue and save/load work.
- [ ] Audio/music, NPCs, DLC and mods have relevant smoke tests.
- [ ] At least ten minutes of gameplay without a repeatable graphics/guest runtime crash.

## Performance

- [ ] FPS baseline and candidate use the same scene/save, view, resolution and enabled mods.
- [ ] At least one repeatable outdoor and indoor measurement is recorded.
- [ ] CPU thread, draw-call, driver, shader and synchronization evidence is retained privately.
- [ ] FPS improvement claims reflect measured device data, not code inspection or archive shrinkage alone.

## Repository / publishing

- [ ] `python tools/verify_repository.py` passes.
- [ ] GitHub verification workflow passes.
- [ ] README describes the actual repository contents, not files available only on the developer's machine.
- [ ] No APK, game data, OBB, proprietary source, signing secrets or private device artifacts are uploaded to releases or commits.
- [ ] Any future downloadable component has a confirmed right to distribute.

**Do not label this a reproducible Android build or completed performance update until the full permitted source is present and the device checks pass.**

# Fallout: New Vegas — Native Android (Work in Progress)

**Development snapshot: 23 November 2026.** This is an experimental, independent native ARM64 Android port / launcher project, not an official release.

## Current state

Fallout: New Vegas has reached real gameplay on an Honor Android phone. The current local test APK has a customized **Mojave HUD** with touch controls, mouse-cursor dragging for menus, a working **USE / Activate** action, a `~` cheat-console button, and an Android keyboard. In the latest user test, the controls were reported working. Preserve that tested local version while investigating performance and stability.

The APK uses package `com.mojave.nativeedition`. The existing first-run game-data extraction flow uses a locally installed OBB; neither the original Fallout game data nor that OBB is stored in this repository.

**This repository currently records the workflow and status only.** The working APK and modified source code are still on the developer's PC and are planned for later review/upload.

## Known limitations

- **Gameplay FPS:** roughly **7–10 FPS at 1920×1080 with High textures** in the latest reported test, and ~15 FPS in some earlier tests. Settings, scene and build may differ; these are observations, not a controlled benchmark.
- **Intermittent crashes:** graphics stage 27 / OpenGL ES presentation failure, and a separate null-function-pointer / `TRAP_NOFN` failure. Both need better diagnostics.
- **NPC dialogue:** conversation exit, scroll navigation and selecting Goodbye still need reliable testing.
- **HUD HIDE mode:** touch areas can remain active when graphics are hidden; avoid unintended menu-button activation.
- **Performance:** no measured native C/C++ optimization gain has yet been confirmed.

## Planned next steps

1. Preserve and back up the current playable APK and source.
2. Profile native C/C++ CPU costs, draw-call overhead, OpenGL ES framebuffer work and sync/wait times.
3. Find and fix intermittent graphics and guest-execution crashes.
4. Improve and verify dialogue navigation, MAP in TOOLS and HIDE/SHOW behavior without regressing mouse controls.
5. Benchmark repeatable outdoor gameplay at identical resolution and settings before/after changes.
6. Later upload legally redistributable source, project files and build scripts.

See [WORKFLOW.md](WORKFLOW.md) and [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md).

## Project origins and licensing

This independent project uses the open-source [Impulse-FONV](https://github.com/ImpulsiveFun/Impulse-FONV) work as a technical starting point; licensing and attributions must be verified when source code is added. Fallout: New Vegas and its game content belong to their respective rights holders. **Do not commit proprietary game assets, executable binaries, OBBs, signing keys or private data.** Users must provide lawfully obtained game data.

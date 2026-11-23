# Fallout: New Vegas — Native Android

A customized native ARM64 Android port and launcher for Fallout: New Vegas, with a Mojave-style touchscreen interface and local game-data import.

**Project status: playable experimental build; optimization and compatibility remain in progress.** This repository is currently a development/workflow record. The modified engine source, executable-derived output, APK, and game assets have **not** been uploaded here. The GitHub checks validate repository hygiene and documentation; they do **not** build or certify a playable APK.

## Current features

- Android ARM64 execution through a native runtime and recompiled game code.
- Custom Mojave touchscreen HUD with movement, aim, interaction, keyboard, and console controls.
- Mouse-style touch dragging for menus; a working USE / Activate input in the tested build.
- Local game-data import; existing installed content does not need to be imported on every launch.
- Launcher mod ZIP import with `.esm`, `.esp`, and supported `.bsa` assets, subject to compatibility testing.
- Save/load gameplay on a tested Android device.

These describe tested local behavior, not a universal device compatibility guarantee.

## Requirements

- A legally obtained PC copy of Fallout: New Vegas and compatible game data.
- Windows build workstation with the required Android SDK, NDK, JDK, Gradle, CMake and other local build dependencies.
- A compatible ARM64 Android device with OpenGL ES 3.1 support and enough storage for imported game data.
- ADB for installation, diagnostics and testing.
- The **modified local source and build script**, which are not currently in this repository.

## Development workflow

1. Read [WORKFLOW.md](WORKFLOW.md) for local setup, building, safe APK replacement, content import, and device verification.
2. Use the optional helper in [tools/Local-Workflow.ps1](tools/Local-Workflow.ps1) with environment variables rather than machine-specific paths.
3. Use [MODS.md](MODS.md) for mod ZIP packaging, enablement and A/B FPS tests.
4. Record test outcomes and unresolved issues in [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md).
5. Check [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) before sharing any distributable material.

The GitHub Actions workflow checks that sensitive or proprietary files are not accidentally committed. **It is not an Android APK build workflow yet**: a reproducible build requires review and addition of permitted source, scripts and dependencies.

## Current performance observations

- Complex outdoor views: approximately **7–9 FPS** in user tests.
- A cluttered indoor area: approximately **11 FPS**.
- A simpler interior: approximately **30 FPS**.
- Native profiling previously showed heavy main-thread execution and substantial CPU time in the Mali graphics driver, with roughly **600–700 draws per frame** in complex scenes.
- Two ultra-low loose-texture packs were transferred successfully, but **visual changes and FPS gains were not observed**, so actual texture override loading is unverified.
- A merged exterior-occlusion mod was imported and enabled, but **no FPS increase was observed** in the tested scene.

Different builds, scenes and settings can affect these numbers. Do not present them as controlled benchmarks or claim a performance fix without a repeatable before/after test.

## Repository and distribution policy

Keep game executables, archives, imported game content, APKs containing proprietary content, saves, diagnostics, personal device identifiers, and signing material out of GitHub. Review redistribution rights before uploading any source derived from external projects or third-party components. Preserve legally required license and notice files even though this repository does not maintain a personal credits section.

See [LICENSES_AND_DISTRIBUTION.md](LICENSES_AND_DISTRIBUTION.md) for the distribution boundary.

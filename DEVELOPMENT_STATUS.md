# Development status

**Snapshot:** 23 November 2026. This is an experimental native Android build. Results below are user-observed local tests, not claims of general compatibility.

| Component | Status / evidence |
| --- | --- |
| Native gameplay | Reached playable gameplay on an ARM64 Android device |
| Package | `com.mojave.nativeedition` |
| Game content | Installed privately on the device; base BSA/ESM archives present |
| Custom Mojave HUD | Working local controls, menu dragging, USE, keyboard and console previously reported |
| Dialogue / HUD hide | Some edge cases not fully verified; preserve known-good controls |
| Graphics / guest runtime | Intermittent stage-related graphics and null-call crashes have been reported; not declared fixed |
| Exterior FPS | About **7–9 FPS** with building-heavy views |
| Cluttered interior FPS | About **11 FPS** |
| Simpler interior FPS | About **30 FPS** |
| Native profiling | Main-thread and driver CPU costs prominent; complex scenes reached approximately 600–700 draw calls/frame |
| Native optimization attempts | Several renderer/dispatch experiments; no reproducible FPS improvement confirmed |
| World texture set 1 | 3,064 DDS; selected source files reduced from 596.68 MiB to 67.76 MiB on PC |
| World texture set 2 | 6,661 DDS; selected source files reduced from 264.98 MiB to 250.19 MiB on PC |
| Texture deployment | 9,725 loose DDS files transferred to the device, ~334 MiB on disk; **no visible texture change or FPS improvement**, override usage unverified |
| Exterior occlusion mod | Merged ESM imported; mod order showed enabled; **FPS unchanged** in user test; in-game/deployed plugin usage not fully verified |
| Hidden-geometry mod | Local install ZIP assembled with matching ESM+BSA; successful device activation/test not yet reported |
| Clutter-removal mod | Local install ZIP assembled with ESP; successful device activation/test not yet reported |
| Lighting/shadows | No verified native lighting/shadow optimization |
| Mesh/prop culling | No verified native geometry simplification or new renderer culling implementation |
| GitHub state | Documentation and workflow helpers only. Modified native source/APK not present |

## Technical findings

- Previous frame timing observed roughly 95 ms mean frame time in a short device profile and approximately 603 draw calls/frame; the test windows and settings were not a controlled benchmark.
- A later main-thread CPU sample profile showed a substantial fraction of time in recompiled guest code and Mali driver routines. This makes reducing CPU-side scene work and draw submissions more promising than only reducing texture disk size.
- Installing loose files in `files/game/Data/textures` proves transfer, **not** override use. The lack of visual difference requires a deliberate asset-loading test before attributing FPS results to texture quality.
- Mod order showing a `+` entry proves the launcher marked a pack enabled, **not** conclusively that its occlusion data affected the rendered scene.
- No source update in this repository currently changes the runtime, HUD, lighting or actual APK.

## Safe future priorities

1. Retain the known-good APK, source copy, saves, and app-private assets.
2. Verify active mod deployment and loose asset-loading behavior using controlled, reversible checks.
3. Fix reproducible crashes and regressions before broad modifications.
4. Profile draw submissions, visibility decisions, per-object work, and graphics-driver CPU overhead in a repeatable scene.
5. Evaluate culling/lighting/mesh optimizations individually; benchmark rather than assume gains.
6. Add redistributable build sources and a genuinely reproducible Android CI build only after legal and functional review.

**Rule:** no new FPS or feature claim without a reproducible on-device test.
